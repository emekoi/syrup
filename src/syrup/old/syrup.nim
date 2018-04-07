##
##  Copyright (c) 2017 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

# when not defined(MODE_RGBA):
  # {.fatal: "compile syrup with the flag MODE_RGBA".}
import
  sdl2/sdl, suffer, os, tables,
  syrup/[timer, embed, shader, gl, mixer],
  syrup/[system, input]
  
export
  suffer,
  timer,
  shader,
  mixer,
  system
  # gifwriter

type
  GLHandle = ref object
    context*: sdl.GLContext
    vbo*: gl.BufferId
    vao*: gl.VertexArrayId
    ebo*: gl.BufferId
    tex*: gl.TextureId
    shader*: Shader

  Context = ref object
    running*: bool
    window*: sdl.Window
    context: sdl.GLContext
    handle: GLHandle
    canvas*: Buffer

type Config* = tuple
  title: string
  width, height: int
  fullscreen: bool
  resizable: bool
  bordered: bool
  clear: Pixel
  fps: float

let
  VERTICIES = [
    #  Position                Texcoords
    -1.0f,  1.0f, 1.0f, 1.0f,   0.0f, 0.0f, 1.0f, 1.0f, # Top-left
      1.0f,  1.0f, 1.0f, 1.0f,   1.0f, 0.0f, 1.0f, 1.0f, # Top-right
      1.0f, -1.0f, 1.0f, 1.0f,   1.0f, 1.0f, 1.0f, 1.0f, # Bottom-right
    -1.0f, -1.0f, 1.0f, 1.0f,   0.0f, 1.0f, 1.0f, 1.0f, # Bottom-left
  ]
  ELEMENTS = [
    0, 1, 2, 3,
  ]

let DEFAULT_FONT = newFontString(DEFAULT_FONT_DATA, DEFAULT_FONT_SIZE)

var
  CORE: Context
  SETTINGS: Config = (
    "syrup", 512, 512,
    false, false, true,
    color(255, 255, 255), 60.0,
  )
  
proc finalize(ctx: Context) =
  mixer.deinit()
  ctx.window.destroyWindow()
  when defined(SYRUP_GL):
    ctx.context.glDeleteContext()
  sdl.quit()

proc finalize(handle: GLHandle) =
  gl.deleteBuffers([handle.ebo, handle.vbo])
  gl.deleteVertexArray(handle.vao)
  gl.deleteTexture(handle.tex)

proc setup() =
  new(CORE, finalize)
  new(CORE.handle, finalize)

  var flags = 0'u32

  if sdl.init(sdl.INIT_VIDEO) != 0:
    quit "ERROR: can't initialize SDL video: " & $sdl.getError()

  if sdl.glSetAttribute(sdl.GL_CONTEXT_MAJOR_VERSION, 2) != 0:
    quit "ERROR: unable set GL_CONTEXT_MAJOR_VERSION attribute: " & $sdl.getError()

  if sdl.glSetAttribute(sdl.GL_CONTEXT_MINOR_VERSION, 1) != 0:
    quit "ERROR: unable set GL_CONTEXT_MINOR_VERSION attribute: " & $sdl.getError()

  if sdl.glSetAttribute(sdl.GL_DOUBLEBUFFER, GL_TRUE.cint) != 0:
    quit "ERROR: unable set GL_DOUBLEBUFFER attribute: " & $sdl.getError()
  
  if sdl.glSetAttribute(sdl.GL_ACCELERATED_VISUAL, 1) != 0:
    quit "ERROR: unable set GL_ACCELERATED_VISUAL attribute: " & $sdl.getError()
  
  flags = sdl.WINDOW_OPENGL

  # Create window
  CORE.window = sdl.createWindow(
    SETTINGS.title,
    sdl.WindowPosUndefined,
    sdl.WindowPosUndefined,
    SETTINGS.width, SETTINGS.height,
    flags)

  if CORE.window == nil:
    quit "ERROR: can't create window: " & $sdl.getError()

  CORE.context = sdl.glCreateContext(CORE.window)

  if CORE.context == nil:
    quit "ERROR: can't create OpenGL context: " & $sdl.getError()

  loadExtensions()

  gl.disable(CULL_FACE)
  gl.disable(DEPTH_TEST)

  CORE.handle.vao = gl.genBindVertexArray()
  
  CORE.handle.vbo = gl.genBindBufferData(BufferTarget.ARRAY_BUFFER, VERTICIES, BufferDataUsage.STATIC_DRAW)
  CORE.handle.ebo = gl.genBindBufferData(BufferTarget.ELEMENT_ARRAY_BUFFER, ELEMENTS, BufferDataUsage.STATIC_DRAW);
  
  CORE.handle.shader = newShaderFromMem(DEFAULT_FRAG_DATA)
  CORE.handle.shader.use()

  CORE.handle.tex = gl.genBindTexture(TextureTarget.TEXTURE_2D)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_BASE_LEVEL, 0)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MAX_LEVEL, 0)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MIN_FILTER, GL_NEAREST)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MAG_FILTER, GL_NEAREST)

  CORE.canvas = newBuffer(SETTINGS.width, SETTINGS.height)

  mixer.init()
  CORE.running = true

proc run*(update: proc(dt: float), draw: proc()) =
  var last = 0.0

  var updateFunc = update
  var drawFunc = draw

  while CORE.running:
    for e in system.poll():
      if e.id == system.QUIT:
        CORE.running = false
      input.onEvent(e)

    timer.step()

    if updateFunc != nil:
      updateFunc(timer.getDelta())

    # clear the screen
    gl.clearColor(0.0f, 0.0f, 0.0f, 1.0f);    
    gl.clear(BufferMask.DEPTH_BUFFER_BIT, BufferMask.COLOR_BUFFER_BIT);
    CORE.canvas.clear(SETTINGS.clear)

    # run the draw callback
    if drawFunc != nil:
      drawFunc()

    input.reset()

    # draw the buffer to the screen
    # let buf = CORE.canvas
    # gl.texImage2D(TexImageTarget.TEXTURE_2D, 0, TextureInternalFormat.RGBA, buf.w, buf.h,
    #   PixelDataFormat.RGBA, PixelDataType.UNSIGNED_BYTE, buf.pixels)
    gl.drawElements(gl.DrawMode.QUADS, 4, IndexType.UNSIGNED_INT, 0)
    sdl.glSwapWindow(CORE.window)

    # wait for next frame
    let step = 1.0 / SETTINGS.fps
    let now = sdl.getTicks().float / 1000.0
    let wait = step - (now - last);
    last += step
    if wait > 0:
      sleep((wait * 1000.0).int)
    else:
      last = now

proc exit*() =
  CORE.running = false

include globals
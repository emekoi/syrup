##
##  Copyright (c) 2017 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

# when not defined(MODE_RGBA):
  # {.fatal: "compile syrup with the flag MODE_RGBA".}
import
  glfw, glfw/wrapper, os, tables,
  syrup/[embed, shader, gl]
  

type
  GLHandle = ref object
    vbo*: gl.BufferId
    vao*: gl.VertexArrayId
    ebo*: gl.BufferId
    tex*: gl.TextureId
    shader*: Shader

  Context = ref object
    running*: bool
    window*: glfw.Window
    handle: GLHandle

type Config* = tuple
  title: string
  width, height: int
  fullscreen: bool
  resizable: bool
  bordered: bool
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

var
  CORE: Context
  SETTINGS: Config = (
    "syrup", 512, 512,
    false, false, true,
    60.0
  )
  
proc finalize(ctx: Context) =
  ctx.window.destroy()
  glfw.terminate()

proc finalize(handle: GLHandle) =
  gl.deleteBuffers([handle.ebo, handle.vbo])
  gl.deleteVertexArray(handle.vao)
  gl.deleteTexture(handle.tex)

proc setup() =
  new(CORE, finalize)
  new(CORE.handle, finalize)

  glfw.initialize()

  var c = glfw.DefaultOpenglWindowConfig
  c.title = SETTINGS.title
  c.version = glv21
  c.doubleBuffer = true

  # Create window
  CORE.window = glfw.newWindow(c)

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
  
  gl.clearColor(0.0f, 0.0f, 0.0f, 1.0f)

  CORE.running = true

proc run*(update: proc(dt: float), draw: proc()) =
  var last = 0.0

  var updateFunc = update
  var drawFunc = draw

  while CORE.running and not glfw.shouldClose(CORE.window):
    glfw.pollEvents()

    if updateFunc != nil:
      updateFunc(0.0)

    # clear the screen
    gl.clear(BufferMask.DEPTH_BUFFER_BIT, BufferMask.COLOR_BUFFER_BIT)

    # run the draw callback
    if drawFunc != nil:
      drawFunc()

    # draw the buffer to the screen
    # let buf = CORE.canvas
    # gl.texImage2D(TexImageTarget.TEXTURE_2D, 0, TextureInternalFormat.RGBA, buf.w, buf.h,
    #   PixelDataFormat.RGBA, PixelDataType.UNSIGNED_BYTE, buf.pixels)
    # gl.drawElements(gl.DrawMode.QUADS, 4, IndexType.UNSIGNED_INT, 0)
    glfw.swapBuffers(CORE.window)

    # wait for next frame
    let step = 1.0 / SETTINGS.fps
    
    let now = glfw.getTime()
    let wait = step - (now - last)
    last += step
    if wait > 0:
      sleep((wait * 1000.0).int)
    else:
      last = now

proc exit*() =
  CORE.running = false



setup()
run(nil, nil)
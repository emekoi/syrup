##
##  Copyright (c) 2017 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import
  sdl2/sdl,
  suffer,
  os, tables

export suffer

import
  syrup/config,
  syrup/timer,
  syrup/embed,
  syrup/shader,
  syrup/gl,
  syrup/mixer,
  syrup/system,
  syrup/input

export config, timer, shader, mixer, system

type
  GLHandle = ref object
    context*: sdl.GLContext
    vbo*: gl.BufferId
    vao*: gl.VertexArrayId
    ebo*: gl.BufferId
    tex*: gl.TextureId
    shader*: Shader

  Context* = ref object
    running*: bool
    window*: sdl.Window
    context: sdl.GLContext
    handle: GLHandle
    canvas*: Buffer

let
  DEFAULT_FONT = newFontString(DEFAULT_FONT_DATA, DEFAULT_FONT_SIZE)
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
  clearOnStep = true

converter toCString*(str: string): cstring = str.cstring
converter toCInt*(num: int): cint = num.cint

proc finalize(ctx: Context) =
  mixer.deinit()
  ctx.window.destroyWindow()
  ctx.context.glDeleteContext()
  sdl.quit()

proc finalize(handle: GLHandle) =
  gl.deleteBuffers([handle.ebo, handle.vbo])
  gl.deleteVertexArray(handle.vao)
  gl.deleteTexture(handle.tex)

proc setup*() =
  new(CORE, finalize)
  new(CORE.handle, finalize)

  if sdl.init(sdl.INIT_VIDEO) != 0:
    quit "ERROR: can't initialize SDL video: " & $sdl.getError()

  # if sdl.glSetAttribute(sdl.GL_CONTEXT_PROFILE_MASK, sdl.GL_CONTEXT_PROFILE_CORE) != 0:
  #   quit "ERROR: unable set GL_CONTEXT_PROFILE_MASK attribute: " & $sdl.getError()

  # if sdl.glSetAttribute(sdl.GL_CONTEXT_MAJOR_VERSION, 3) != 0:
  #   quit "ERROR: unable set GL_CONTEXT_MAJOR_VERSION attribute: " & $sdl.getError()

  # if sdl.glSetAttribute(sdl.GL_CONTEXT_MINOR_VERSION, 0) != 0:
  #   quit "ERROR: unable set GL_CONTEXT_MINOR_VERSION attribute: " & $sdl.getError()

  # if sdl.glSetAttribute(sdl.GL_STENCIL_SIZE, 8) != 0:
  #   quit "ERROR: unable set GL_STENCIL_SIZE attribute: " & $sdl.getError()

  if sdl.glSetAttribute(sdl.GL_DOUBLEBUFFER, GL_TRUE.cint) != 0:
    quit "ERROR: unable set GL_DOUBLEBUFFER attribute: " & $sdl.getError()

  # Create window
  CORE.window = sdl.createWindow(
    SETTINGS.title,
    sdl.WindowPosUndefined,
    sdl.WindowPosUndefined,
    SETTINGS.width, SETTINGS.height,
    sdl.WINDOW_OPENGL)

  if CORE.window == nil:
    quit "ERROR: can't create window: " & $sdl.getError()

  CORE.context = sdl.glCreateContext(CORE.window)

  if CORE.context == nil:
    quit "ERROR: can't create OpenGL context: " & $sdl.getError()

  loadExtensions()

  gl.disable(CULL_FACE)
  gl.disable(DEPTH_TEST)

  CORE.handle.vao = gl.genVertexArray()
  gl.bindVertexArray(CORE.handle.vao)

  CORE.handle.vbo = gl.genBuffer()
  gl.bindBuffer(BufferTarget.ARRAY_BUFFER, CORE.handle.vbo)
  gl.bufferData(BufferTarget.ARRAY_BUFFER, VERTICIES, BufferDataUsage.STATIC_DRAW)

  CORE.handle.ebo = gl.genBuffer();
  gl.bindBuffer(BufferTarget.ELEMENT_ARRAY_BUFFER, CORE.handle.ebo)
  gl.bufferData(BufferTarget.ELEMENT_ARRAY_BUFFER, ELEMENTS, BufferDataUsage.STATIC_DRAW)

  CORE.handle.shader = shader_from_mem(DEFAULT_FRAG_DATA)
  CORE.handle.shader.use()

  CORE.handle.tex = gl.genTexture()
  gl.bindTexture(TextureTarget.TEXTURE_2D, CORE.handle.tex)

  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_BASE_LEVEL, 0)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MAX_LEVEL, 0)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MIN_FILTER, GL_NEAREST)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MAG_FILTER, GL_NEAREST)

  mixer.init()

  CORE.canvas = newBuffer(SETTINGS.width, SETTINGS.height)

  CORE.running = true


proc run*(init: proc(), update: proc(dt: float), draw: proc()) =
  var last = 0.0

  var initFunc = init
  var updateFunc = update
  var drawFunc = draw

  setup()

  if initFunc != nil:
    initFunc()

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
    let buf = CORE.canvas
    gl.texImage2D(TexImageTarget.TEXTURE_2D, 0, TextureInternalFormat.RGBA, buf.w, buf.h,
      PixelDataFormat.RGBA, PixelDataType.UNSIGNED_BYTE, buf.pixels)
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

  # shutdown sdl
  sdl.quit()

proc exit*() =
  CORE.running = false

# INPUT
proc key_down*(keys: varargs[string]): bool =
  result = false
  for k in keys:
    if input.keysDown.hasKey(k) and input.keysDown[k]:
      return true

proc key_pressed*(keys: varargs[string]): bool =
  result = false
  for k in keys:
    if input.keysPressed.hasKey(k) and input.keysPressed[k]:
      return true

proc key_released*(keys: varargs[string]): bool =
  key_pressed(keys) and not key_down(keys)

proc mouse_down*(buttons: varargs[string]): bool =
  result = false
  for b in buttons:
    if input.buttonsDown.hasKey(b) and input.buttonsDown[b]:
      return true

proc mouse_pressed*(buttons: varargs[string]): bool =
  result = false
  for b in buttons:
    if input.buttonsPressed.hasKey(b) and input.buttonsPressed[b]:
      return true

proc mouse_released*(buttons: varargs[string]): bool =
  mouse_down(buttons) and not mouse_pressed(buttons)

proc mouse_position*(): (int32, int32) =
  (input.mousePos.x, input.mousePos.y)

# GRAPHICS
proc buffer_blank*(width, height: int): Buffer = suffer.newBuffer(width, height)
proc buffer_clone*(): Buffer = CORE.canvas.cloneBuffer()
proc load_pixels*(src: openarray[uint32], fmt: suffer.PixelFormat) = CORE.canvas.loadPixels(src, fmt)
proc load_pixels8*(src: openarray[uint8], pal: openarray[Pixel]) = CORE.canvas.loadPixels8(src, pal)
proc load_pixels8*(src: openarray[uint8]) = CORE.canvas.loadPixels8(src)
proc set_blend*(blend: suffer.BlendMode) = CORE.canvas.setBlend(blend)
proc set_alpha*[T](alpha: T) = CORE.canvas.setAlpha(alpha)
proc set_color*(c: Pixel) = CORE.canvas.setColor(c)
proc set_clip*(r: suffer.Rect) = CORE.canvas.setClip(r)
proc reset*() = CORE.canvas.reset()
proc clear*(c: Pixel) = CORE.canvas.clear(c)
proc get_pixel*(x: int, y: int): Pixel = CORE.canvas.getPixel(x, y)
proc set_pixel*(c: Pixel, x: int, y: int) = CORE.canvas.setPixel(c, x, y)
proc copy_pixels*(src: Buffer, x, y: int, sub: suffer.Rect, sx, sy: float) = CORE.canvas.copyPixels(src, x, y, sub, sx, sy)
proc copy_pixels*(src: Buffer, x, y: int, sx, sy: float) = CORE.canvas.copyPixels(src, x, y, sx, sy)
proc noise*(seed: uint, low, high: int, grey: bool) = CORE.canvas.noise(seed, low, high, grey)
proc flood_fill*(c: Pixel, x, y: int) = CORE.canvas.floodFill(c, x, y)
proc draw_pixel*(c: Pixel, x, y: int) = CORE.canvas.drawPixel(c, x, y)
proc draw_line*(c: Pixel, x0, y0, x1, y1: int) = CORE.canvas.drawLine(c, x0, y0, x1, y1)
proc draw_rect*(c: Pixel, x, y, w, h: int) = CORE.canvas.drawRect(c, x, y, w, h)
proc draw_box*(c: Pixel, x, y, w, h: int) = CORE.canvas.drawBox(c, x, y, w, h)
proc draw_circle*(c: Pixel, x, y, r: int) = CORE.canvas.drawCircle(c, x, y, r)
proc draw_ring*(c: Pixel, x, y, r: int) = CORE.canvas.drawRing(c, x, y, r)
proc draw_text*(font: Font, c: Pixel, txt: string, x, y: int, width: int=0) = CORE.canvas.drawText(font, c, txt, x, y, width)
proc draw_text*(c: Pixel, txt: string, x, y: int, width: int=0) = CORE.canvas.drawText(DEFAULT_FONT, c, txt, x, y, width)
proc draw_buffer*(src: Buffer, x, y: int, sub: suffer.Rect, t: Transform) = CORE.canvas.drawBuffer(src, x, y, sub, t)
proc draw_buffer*(src: Buffer, x, y: int, sub: suffer.Rect) = CORE.canvas.drawBuffer(src, x, y, sub)
proc draw_buffer*(src: Buffer, x, y: int, t: Transform) = CORE.canvas.drawBuffer(src, x, y, t)
proc draw_buffer*(src: Buffer, x, y: int) = CORE.canvas.drawBuffer(src, x, y)
proc desaturate*(amount: int) = CORE.canvas.desaturate(amount)
proc mask*(mask: Buffer, channel: char) = CORE.canvas.mask(mask, channel)
proc palette*(palette: openarray[Pixel]) = CORE.canvas.palette(palette)
proc dissolve*(amount: int, seed: uint) = CORE.canvas.dissolve(amount, seed)
proc wave*(src: Buffer, amountX, amountY, scaleX, scaleY, offsetX, offsetY: int) = CORE.canvas.wave(src, amountX, amountY, scaleX, scaleY, offsetX, offsetY)
proc displace*(src, map: Buffer, channelX, channelY: char, scaleX, scaleY: int) = CORE.canvas.displace(src, map, channelX, channelY, scaleX, scaleY)
proc blur*(src: Buffer, radiusx, radiusy: int) = CORE.canvas.blur(src, radiusx, radiusy)

import 
  sdl2/sdl,
  suffer,
  os

import
  syrup/timer,
  syrup/embed,
  syrup/shader,
  syrup/gl

type
  Config* = tuple
    title: string
    w, h: int
    clear: Pixel
    fps: float

  GLHandle* = ref object
    context*: sdl.GLContext
    vbo*: gl.BufferId
    vao*: gl.VertexArrayId
    ebo*: gl.BufferId
    tex*: gl.TextureId
    shader*: Shader

  Context* = ref object
    running*: bool
    window*: sdl.Window
    context*: sdl.GLContext
    handle*: GLHandle
    canvas*: Buffer
    cfg*: Config


let
  DEFAULT_FONT = newFontString(DEFAULT_FONT_DATA, DEFAULT_FONT_SIZE)
  VERTICIES = [
    -1.0f,  1.0f, 1.0f, 1.0f,   0.0f, 0.0f, 1.0f, 1.0f,
     1.0f,  1.0f, 1.0f, 1.0f,   1.0f, 0.0f, 1.0f, 1.0f,
     1.0f, -1.0f, 1.0f, 1.0f,   1.0f, 1.0f, 1.0f, 1.0f,
    -1.0f, -1.0f, 1.0f, 1.0f,   0.0f, 1.0f, 1.0f, 1.0f,
  ]
  ELEMENTS = [
    0, 1, 2, 3,
  ]

var
  MAIN_CONTEXT: Context

export suffer, timer, shader

proc cloneBuffer*(): Buffer = MAIN_CONTEXT.canvas.cloneBuffer()
proc loadPixels*(src: openarray[uint32], fmt: suffer.PixelFormat) = MAIN_CONTEXT.canvas.loadPixels(src, fmt)
proc loadPixels8*(src: openarray[uint8], pal: openarray[Pixel]) = MAIN_CONTEXT.canvas.loadPixels8(src, pal)
proc loadPixels8*(src: openarray[uint8]) = MAIN_CONTEXT.canvas.loadPixels8(src)
proc setBlend*(blend: suffer.BlendMode) = MAIN_CONTEXT.canvas.setBlend(blend)
proc setAlpha*[T](alpha: T) = MAIN_CONTEXT.canvas.setAlpha(alpha)
proc setColor*(c: Pixel) = MAIN_CONTEXT.canvas.setColor(c)
proc setClip*(r: suffer.Rect) = MAIN_CONTEXT.canvas.setClip(r)
proc reset*() = MAIN_CONTEXT.canvas.reset()
proc clear*(c: Pixel) = MAIN_CONTEXT.canvas.clear(c)
proc getPixel*(x: int, y: int): Pixel = MAIN_CONTEXT.canvas.getPixel(x, y)
proc setPixel*(c: Pixel, x: int, y: int) = MAIN_CONTEXT.canvas.setPixel(c, x, y)
proc copyPixels*(src: Buffer, x, y: int, sub: suffer.Rect, sx, sy: float) = MAIN_CONTEXT.canvas.copyPixels(src, x, y, sub, sx, sy)
proc copyPixels*(src: Buffer, x, y: int, sx, sy: float) = MAIN_CONTEXT.canvas.copyPixels(src, x, y, sx, sy)
proc noise*(seed: uint, low, high: int, grey: bool) = MAIN_CONTEXT.canvas.noise(seed, low, high, grey)
proc floodFill*(c: Pixel, x, y: int) = MAIN_CONTEXT.canvas.floodFill(c, x, y)
proc drawPixel*(c: Pixel, x, y: int) = MAIN_CONTEXT.canvas.drawPixel(c, x, y)
proc drawLine*(c: Pixel, x0, y0, x1, y1: int) = MAIN_CONTEXT.canvas.drawLine(c, x0, y0, x1, y1)
proc drawRect*(c: Pixel, x, y, w, h: int) = MAIN_CONTEXT.canvas.drawRect(c, x, y, w, h)
proc drawBox*(c: Pixel, x, y, w, h: int) = MAIN_CONTEXT.canvas.drawBox(c, x, y, w, h)
proc drawCircle*(c: Pixel, x, y, r: int) = MAIN_CONTEXT.canvas.drawCircle(c, x, y, r)
proc drawRing*(c: Pixel, x, y, r: int) = MAIN_CONTEXT.canvas.drawRing(c, x, y, r)
proc drawText*(font: Font, c: Pixel, txt: string, x, y: int, width: int=0) = MAIN_CONTEXT.canvas.drawText(font, c, txt, x, y, width)
proc drawText*(c: Pixel, txt: string, x, y: int, width: int=0) = MAIN_CONTEXT.canvas.drawText(DEFAULT_FONT, c, txt, x, y, width)
proc drawBuffer*(src: Buffer, x, y: int, sub: suffer.Rect, t: Transform) = MAIN_CONTEXT.canvas.drawBuffer(src, x, y, sub, t)
proc drawBuffer*(src: Buffer, x, y: int, sub: suffer.Rect) = MAIN_CONTEXT.canvas.drawBuffer(src, x, y, sub)
proc drawBuffer*(src: Buffer, x, y: int, t: Transform) = MAIN_CONTEXT.canvas.drawBuffer(src, x, y, t)
proc drawBuffer*(src: Buffer, x, y: int) = MAIN_CONTEXT.canvas.drawBuffer(src, x, y)
proc desaturate*(amount: int) = MAIN_CONTEXT.canvas.desaturate(amount)
proc mask*(mask: Buffer, channel: char) = MAIN_CONTEXT.canvas.mask(mask, channel)
proc palette*(palette: openarray[Pixel]) = MAIN_CONTEXT.canvas.palette(palette)
proc dissolve*(amount: int, seed: uint) = MAIN_CONTEXT.canvas.dissolve(amount, seed)
proc wave*(src: Buffer, amountX, amountY, scaleX, scaleY, offsetX, offsetY: int) = MAIN_CONTEXT.canvas.wave(src, amountX, amountY, scaleX, scaleY, offsetX, offsetY)
proc displace*(src, map: Buffer, channelX, channelY: char, scaleX, scaleY: int) = MAIN_CONTEXT.canvas.displace(src, map, channelX, channelY, scaleX, scaleY)
proc blur*(src: Buffer, radiusx, radiusy: int) = MAIN_CONTEXT.canvas.blur(src, radiusx, radiusy)

proc finalize(ctx: Context) =
  ctx.window.destroyWindow()
  ctx.context.glDeleteContext()
  sdl.quit()
  
proc finalize(handle: GLHandle) =
  gl.deleteBuffers([handle.ebo, handle.vbo])
  gl.deleteVertexArray(handle.vao)
  gl.deleteTexture(handle.tex)

proc setupGraphics*(cfg: Config): Context =
  new(result, finalize)
  new(result.handle, finalize)

  if sdl.init(sdl.InitVideo) != 0:
    quit "ERROR: can't initialize SDL: " & $sdl.getError()
  
  if sdl.glSetAttribute(sdl.GL_CONTEXT_PROFILE_MASK, sdl.GL_CONTEXT_PROFILE_CORE) != 0:
    quit "ERROR: unable set GL_CONTEXT_PROFILE_MASK attribute: " & $sdl.getError()

  # if sdl.glSetAttribute(sdl.GL_CONTEXT_MAJOR_VERSION, 3) != 0:
  #   quit "ERROR: unable set GL_CONTEXT_MAJOR_VERSION attribute: " & $sdl.getError()

  # if sdl.glSetAttribute(sdl.GL_CONTEXT_MINOR_VERSION, 0) != 0:
  #   quit "ERROR: unable set GL_CONTEXT_MINOR_VERSION attribute: " & $sdl.getError()

  # if sdl.glSetAttribute(sdl.GL_STENCIL_SIZE, 8) != 0:
  #   quit "ERROR: unable set GL_STENCIL_SIZE attribute: " & $sdl.getError()

  if sdl.glSetAttribute(sdl.GL_DOUBLEBUFFER, GL_TRUE.cint) != 0:
    quit "ERROR: unable set GL_STENCIL_SIZE attribute: " & $sdl.getError()

  # Create window
  result.window = sdl.createWindow(
    cfg.title,
    sdl.WindowPosUndefined,
    sdl.WindowPosUndefined,
    cfg.w, cfg.h, 
    sdl.WINDOW_OPENGL)

  if result.window == nil:
    quit "ERROR: can't create window: " & $sdl.getError()

  result.context = sdl.glCreateContext(result.window)

  if result.context == nil:
    quit "ERROR: can't create OpenGL context: " & $sdl.getError()

  loadExtensions()

  gl.disable(CULL_FACE)
  gl.disable(DEPTH_TEST)

  result.handle.vao = gl.genVertexArray()
  gl.bindVertexArray(result.handle.vao)

  result.handle.vbo = gl.genBuffer()
  gl.bindBuffer(BufferTarget.ARRAY_BUFFER, result.handle.vbo)
  gl.bufferData(BufferTarget.ARRAY_BUFFER, VERTICIES, BufferDataUsage.STATIC_DRAW)

  result.handle.ebo = gl.genBuffer();
  gl.bindBuffer(BufferTarget.ELEMENT_ARRAY_BUFFER, result.handle.ebo)
  gl.bufferData(BufferTarget.ELEMENT_ARRAY_BUFFER, ELEMENTS, BufferDataUsage.STATIC_DRAW)

  result.handle.shader = newShaderString(DEFAULT_VERT_DATA, DEFAULT_FRAG_DATA)
  result.handle.shader.use()

  result.handle.tex = gl.genTexture()
  gl.bindTexture(TextureTarget.TEXTURE_2D, result.handle.tex)

  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_BASE_LEVEL, 0)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MAX_LEVEL, 0)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MIN_FILTER, GL_NEAREST)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MAG_FILTER, GL_NEAREST)


  result.canvas = newBuffer(cfg.w, cfg.h)
  result.cfg = cfg
  result.running = true


proc run*(init: proc(): Config, update: proc(dt: float), draw: proc(buf: Buffer)) =
  var
    last = 0.0
    e: sdl.Event

  assert(init != nil)
  assert(update != nil)
  assert(draw != nil)

  var initFunc = init
  var updateFunc = update
  var drawFunc = draw
  
  ###
  ###
  ###
  ###
  ### error in project structure
  ###
  ###
  ###

  MAIN_CONTEXT = setupGraphics((title: "window", w: 512, h: 512, clear: color(255, 255, 255), fps: 60.0))
  discard initFunc()

  while MAIN_CONTEXT.running:
    while sdl.pollEvent(addr(e)) != 0:
      case e.kind
      of sdl.Quit:
        MAIN_CONTEXT.running = false
      of KeyDown:
        case e.key.keysym.sym
        of sdl.K_Escape: return
        else: discard
      else: discard
    
    timer.step()

    updateFunc(timer.getDelta())

    # draw the buffer to the screen
    # gl.clearColor(0.0f, 0.0f, 0.0f, 1.0f);
    gl.clear(BufferMask.DEPTH_BUFFER_BIT, BufferMask.COLOR_BUFFER_BIT);
    MAIN_CONTEXT.canvas.clear(MAIN_CONTEXT.cfg.clear)
    drawFunc(MAIN_CONTEXT.canvas)

    let buf = MAIN_CONTEXT.canvas

    gl.texImage2D(TexImageTarget.TEXTURE_2D, 0, TextureInternalFormat.RGBA, buf.w, buf.h,
      PixelDataFormat.RGBA, PixelDataType.UNSIGNED_BYTE, buf.pixels)

    gl.drawElements(gl.DrawMode.QUADS, 4, IndexType.UNSIGNED_INT, 0)

    sdl.glSwapWindow(MAIN_CONTEXT.window)

    # wait for next frame
    let step = 1.0 / MAIN_CONTEXT.cfg.fps
    let now = sdl.getTicks().float / 1000.0
    let wait = step - (now - last);
    last += step
    if wait > 0:
      sleep((wait * 1000.0).int)
    else:
      last = now

  # shutdown sdl
  sdl.quit()
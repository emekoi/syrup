import 
  sdl2/sdl,
  suffer,
  os

import  
  timer,
  embed

type
  Config* = tuple
    title: string
    w, h: int
    clear: Pixel
    fps: float

  Context* = ref object
    window*: sdl.Window
    screen*: sdl.Surface
    canvas*: Buffer
    cfg*: Config

var 
  RUNNING = false
  WINDOW: Context

let DEFAULT_FONT = newFontString(DEFAULT_FONT_DATA, DEFAULT_FONT_SIZE)

export suffer
export timer

proc cloneBuffer*(): Buffer = WINDOW.canvas.cloneBuffer()
proc loadPixels*(src: openarray[uint32], fmt: suffer.PixelFormat) = WINDOW.canvas.loadPixels(src, fmt)
proc loadPixels8*(src: openarray[uint8], pal: openarray[Pixel]) = WINDOW.canvas.loadPixels8(src, pal)
proc loadPixels8*(src: openarray[uint8]) = WINDOW.canvas.loadPixels8(src)
proc setBlend*(blend: suffer.BlendMode) = WINDOW.canvas.setBlend(blend)
proc setAlpha*[T](alpha: T) = WINDOW.canvas.setAlpha(alpha)
proc setColor*(c: Pixel) = WINDOW.canvas.setColor(c)
proc setClip*(r: suffer.Rect) = WINDOW.canvas.setClip(r)
proc reset*() = WINDOW.canvas.reset()
proc clear*(c: Pixel) = WINDOW.canvas.clear(c)
proc getPixel*(x: int, y: int): Pixel = WINDOW.canvas.getPixel(x, y)
proc setPixel*(c: Pixel, x: int, y: int) = WINDOW.canvas.setPixel(c, x, y)
proc copyPixels*(src: Buffer, x, y: int, sub: suffer.Rect, sx, sy: float) = WINDOW.canvas.copyPixels(src, x, y, sub, sx, sy)
proc copyPixels*(src: Buffer, x, y: int, sx, sy: float) = WINDOW.canvas.copyPixels(src, x, y, sx, sy)
proc noise*(seed: uint, low, high: int, grey: bool) = WINDOW.canvas.noise(seed, low, high, grey)
proc floodFill*(c: Pixel, x, y: int) = WINDOW.canvas.floodFill(c, x, y)
proc drawPixel*(c: Pixel, x, y: int) = WINDOW.canvas.drawPixel(c, x, y)
proc drawLine*(c: Pixel, x0, y0, x1, y1: int) = WINDOW.canvas.drawLine(c, x0, y0, x1, y1)
proc drawRect*(c: Pixel, x, y, w, h: int) = WINDOW.canvas.drawRect(c, x, y, w, h)
proc drawBox*(c: Pixel, x, y, w, h: int) = WINDOW.canvas.drawBox(c, x, y, w, h)
proc drawCircle*(c: Pixel, x, y, r: int) = WINDOW.canvas.drawCircle(c, x, y, r)
proc drawRing*(c: Pixel, x, y, r: int) = WINDOW.canvas.drawRing(c, x, y, r)
proc drawText*(font: Font, c: Pixel, txt: string, x, y: int, width: int=0) = WINDOW.canvas.drawText(font, c, txt, x, y, width)
proc drawText*(c: Pixel, txt: string, x, y: int, width: int=0) = WINDOW.canvas.drawText(DEFAULT_FONT, c, txt, x, y, width)
proc drawBuffer*(src: Buffer, x, y: int, sub: suffer.Rect, t: Transform) = WINDOW.canvas.drawBuffer(src, x, y, sub, t)
proc drawBuffer*(src: Buffer, x, y: int, sub: suffer.Rect) = WINDOW.canvas.drawBuffer(src, x, y, sub)
proc drawBuffer*(src: Buffer, x, y: int, t: Transform) = WINDOW.canvas.drawBuffer(src, x, y, t)
proc drawBuffer*(src: Buffer, x, y: int) = WINDOW.canvas.drawBuffer(src, x, y)
proc desaturate*(amount: int) = WINDOW.canvas.desaturate(amount)
proc mask*(mask: Buffer, channel: char) = WINDOW.canvas.mask(mask, channel)
proc palette*(palette: openarray[Pixel]) = WINDOW.canvas.palette(palette)
proc dissolve*(amount: int, seed: uint) = WINDOW.canvas.dissolve(amount, seed)
proc wave*(src: Buffer, amountX, amountY, scaleX, scaleY, offsetX, offsetY: int) = WINDOW.canvas.wave(src, amountX, amountY, scaleX, scaleY, offsetX, offsetY)
proc displace*(src, map: Buffer, channelX, channelY: char, scaleX, scaleY: int) = WINDOW.canvas.displace(src, map, channelX, channelY, scaleX, scaleY)
proc blur*(src: Buffer, radiusx, radiusy: int) = WINDOW.canvas.blur(src, radiusx, radiusy)

proc finalize(win: Context) =
  win.window.destroyWindow()
  
proc setup*(cfg: Config) =
  new(WINDOW, finalize)

  if sdl.init(sdl.InitVideo) != 0:
    quit "ERROR: can't initialize SDL: " & $sdl.getError()
  
  # Create window
  WINDOW.window = sdl.createWindow(
    cfg.title,
    sdl.WindowPosUndefined,
    sdl.WindowPosUndefined,
    cfg.w, cfg.h, 
    0)

  if WINDOW.window == nil:
    quit "ERROR: can't create window: " & $sdl.getError()

  WINDOW.screen = WINDOW.window.getWindowSurface
  WINDOW.canvas = newBuffer(cfg.w, cfg.h)
  WINDOW.cfg = cfg


proc run*(init: proc(), update: proc(dt: float), draw: proc(buf: Buffer)) =
  var
    last = 0.0
    e: sdl.Event

  assert(update != nil)
  assert(draw != nil)

  var initFunc = init
  var updateFunc = update
  var drawFunc = draw

  if initFunc != nil:
    initFunc()

  RUNNING = true
  
  while RUNNING:
    while sdl.pollEvent(addr(e)) != 0:
      case e.kind
      of sdl.Quit:
        RUNNING = false
      of KeyDown:
        case e.key.keysym.sym
        of sdl.K_Escape: return
        else: discard
      else: discard
    
    timer.step()

    updateFunc(timer.getDelta())
    WINDOW.canvas.clear(WINDOW.cfg.clear)
    drawFunc(WINDOW.canvas)

    # copy pixels to screen
    if WINDOW.screen != nil and WINDOW.screen.mustLock():
      if WINDOW.screen.lockSurface() != 0:
        quit "ERROR: couldn't lock screen: " & $sdl.getError()
    copyMem(WINDOW.screen.pixels, WINDOW.canvas.pixels[0].addr, (WINDOW.cfg.w * WINDOW.cfg.h) * sizeof(Pixel))
    if WINDOW.screen.mustLock(): WINDOW.screen.unlockSurface()
    if WINDOW.window.updateWindowSurface() != 0:
      quit "ERROR: couldn't update screen: " & $sdl.getError()

    # wait for next frame
    let step = 1.0 / WINDOW.cfg.fps
    let now = sdl.getTicks().float / 1000.0
    let wait = step - (now - last);
    last += step
    if wait > 0:
      sleep((wait * 1000.0).int)
    else:
      last = now

  # shutdown sdl
  sdl.quit()
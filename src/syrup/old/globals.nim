# CONFIG
proc resetVideoMode() =
  discard sdl.setWindowFullscreen(CORE.window, if SETTINGS.fullscreen: sdl.WINDOW_FULLSCREEN_DESKTOP else: 0)
  sdl.setWindowSize(CORE.window, SETTINGS.width, SETTINGS.height)
  sdl.setWindowResizable(CORE.window, if SETTINGS.resizable: true else: false)
  sdl.setWindowBordered(CORE.window, if SETTINGS.bordered: true else: false)
  CORE.canvas.resize(SETTINGS.width, SETTINGS.height)
  CORE.canvas.reset()
  
proc getConfig*(): Config =
  SETTINGS

proc setConfig*(c: Config) =
  SETTINGS = c
  resetVideoMode()

proc getWindowTitle*(): string =
  SETTINGS.title

proc setWindowTitle*(title: string) =
  SETTINGS.title = title
  sdl.setWindowTitle(CORE.window, title)

proc getWindowWidth*(): int =
  SETTINGS.width

proc setWindowWidth*(width: int) =
  SETTINGS.width = width
  resetVideoMode()

proc getWindowHeight*(): int =
  SETTINGS.height

proc setWindowHeight*(height: int) =
  SETTINGS.height = height
  resetVideoMode()

proc getWindowFullscreen*(): bool =
  SETTINGS.fullscreen

proc setWindowFullscreen*(fullscreen: bool) =
  SETTINGS.fullscreen = fullscreen
  resetVideoMode()

proc getWindowResizable*(): bool =
  SETTINGS.resizable

proc setWindowResizable*(resizable: bool) =
  SETTINGS.resizable = resizable
  resetVideoMode()

proc getWindowBordered*(): bool =
  SETTINGS.bordered

proc setWindowBordered*(bordered: bool) =
  SETTINGS.bordered = bordered
  resetVideoMode()

proc setWindowClear*(): Pixel =
  SETTINGS.clear

proc setWindowClear*(color: Pixel) =
  SETTINGS.clear = color

proc getWindowFps*(): float =
  SETTINGS.fps

proc setWindowFps*(fps: float) =
  SETTINGS.fps = fps

# INPUT
proc keyDown*(keys: varargs[string]): bool =
  result = false
  for k in keys:
    if input.keysDown.hasKey(k) and input.keysDown[k]:
      return true

proc keyPressed*(keys: varargs[string]): bool =
  result = false
  for k in keys:
    if input.keysPressed.hasKey(k) and input.keysPressed[k]:
      return true

proc keyReleased*(keys: varargs[string]): bool =
  keyPressed(keys) and not keyDown(keys)

proc mouseDown*(buttons: varargs[string]): bool =
  result = false
  for b in buttons:
    if input.buttonsDown.hasKey(b) and input.buttonsDown[b]:
      return true

proc mousePressed*(buttons: varargs[string]): bool =
  result = false
  for b in buttons:
    if input.buttonsPressed.hasKey(b) and input.buttonsPressed[b]:
      return true

proc mouseReleased*(buttons: varargs[string]): bool =
  mouseDown(buttons) and not mousePressed(buttons)

proc mousePosition*(): (int, int) =
  (input.mousePos.x, input.mousePos.y)

# GRAPHICS
proc cloneBuffer*(): Buffer = CORE.canvas.cloneBuffer()
proc loadPixels*(src: openarray[uint32], fmt: suffer.PixelFormat) = CORE.canvas.loadPixels(src, fmt)
proc loadPixels8*(src: openarray[uint8], pal: openarray[Pixel]) = CORE.canvas.loadPixels8(src, pal)
proc loadPixels8*(src: openarray[uint8]) = CORE.canvas.loadPixels8(src)
proc setBlend*(blend: suffer.BlendMode) = CORE.canvas.setBlend(blend)
proc setAlpha*[T](alpha: T) = CORE.canvas.setAlpha(alpha)
proc setColor*(c: Pixel) = CORE.canvas.setColor(c)
proc setClip*(r: suffer.Rect) = CORE.canvas.setClip(r)
proc reset*() = CORE.canvas.reset()
proc clear*(c: Pixel) = CORE.canvas.clear(c)
proc getPixel*(x: int, y: int): Pixel = CORE.canvas.getPixel(x, y)
proc setPixel*(c: Pixel, x: int, y: int) = CORE.canvas.setPixel(c, x, y)
proc copyPixels*(src: Buffer, x, y: int, sub: suffer.Rect, sx, sy: float=1.0) = CORE.canvas.copyPixels(src, x, y, sub, sx, sy)
proc copyPixels*(src: Buffer, x, y: int, sx, sy: float=1.0) = CORE.canvas.copyPixels(src, x, y, sx, sy)
proc noise*(seed: uint, low, high: int, grey: bool) = CORE.canvas.noise(seed, low, high, grey)
proc floodFill*(c: Pixel, x, y: int) = CORE.canvas.floodFill(c, x, y)
proc drawPixel*(c: Pixel, x, y: int) = CORE.canvas.drawPixel(c, x, y)
proc drawLine*(c: Pixel, x0, y0, x1, y1: int) = CORE.canvas.drawLine(c, x0, y0, x1, y1)
proc drawRect*(c: Pixel, x, y, w, h: int) = CORE.canvas.drawRect(c, x, y, w, h)
proc drawBox*(c: Pixel, x, y, w, h: int) = CORE.canvas.drawBox(c, x, y, w, h)
proc drawCircle*(c: Pixel, x, y, r: int) = CORE.canvas.drawCircle(c, x, y, r)
proc drawRing*(c: Pixel, x, y, r: int) = CORE.canvas.drawRing(c, x, y, r)
proc drawText*(font: Font, c: Pixel, txt: string, x, y: int, width: int=0) = CORE.canvas.drawText(font, c, txt, x, y, width)
proc drawText*(c: Pixel, txt: string, x, y: int, width: int=0) = CORE.canvas.drawText(DEFAULT_FONT, c, txt, x, y, width)
proc drawBuffer*(src: Buffer, x, y: int, sub: suffer.Rect, t: Transform) = CORE.canvas.drawBuffer(src, x, y, sub, t)
proc drawBuffer*(src: Buffer, x, y: int, sub: suffer.Rect) = CORE.canvas.drawBuffer(src, x, y, sub)
proc drawBuffer*(src: Buffer, x, y: int, t: Transform) = CORE.canvas.drawBuffer(src, x, y, t)
proc drawBuffer*(src: Buffer, x, y: int) = CORE.canvas.drawBuffer(src, x, y)
proc desaturate*(amount: int) = CORE.canvas.desaturate(amount)
proc mask*(mask: Buffer, channel: char) = CORE.canvas.mask(mask, channel)
proc palette*(palette: openarray[Pixel]) = CORE.canvas.palette(palette)
proc dissolve*(amount: int, seed: uint) = CORE.canvas.dissolve(amount, seed)
proc wave*(src: Buffer, amountX, amountY, scaleX, scaleY, offsetX, offsetY: int) = CORE.canvas.wave(src, amountX, amountY, scaleX, scaleY, offsetX, offsetY)
proc displace*(src, map: Buffer, channelX, channelY: char, scaleX, scaleY: int) = CORE.canvas.displace(src, map, channelX, channelY, scaleX, scaleY)
proc blur*(src: Buffer, radiusx, radiusy: int) = CORE.canvas.blur(src, radiusx, radiusy)

# FONT
proc fontFromDefault*(ptsize: float=DEFAULT_FONT_SIZE): Font =
  newFontString(DEFAULT_FONT_DATA, ptsize)

if CORE == nil:
  setup()
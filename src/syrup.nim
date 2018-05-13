##
##  Copyright (c) 2017 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import
  sdl2/sdl, suffer, os, tables,
  syrup/[timer, embed, mixer],
  syrup/[system, input, gifwriter]
  
export
  suffer,
  timer,
  mixer,
  system
  # gifwriter

type Context = ref object
  running*: bool
  window*: sdl.Window
  surface*: sdl.Surface
  canvas*: Buffer
  canvas_size: int

type Config* = tuple
  title: string
  width, height: int
  fullscreen: bool
  resizable: bool
  bordered: bool
  clear: Pixel
  fps: float
  samplerate: int
  buffersize: uint
  

let DEFAULT_FONT = newFontString(DEFAULT_FONT_DATA, DEFAULT_FONT_SIZE)

var
  CORE: Context
  SETTINGS: Config = (
    "syrup", 512, 512,
    false, false, true,
    color(255, 255, 255), 60.0,
    44100, 1024'u
  )
  
proc finalize(ctx: Context) =
  mixer.deinit()
  ctx.window.destroyWindow()
  sdl.quit()

proc setup() =
  new(CORE, finalize)

  var flags = 0'u32

  if sdl.init(sdl.INIT_VIDEO) != 0:
    quit "ERROR: can't initialize SDL video: " & $sdl.getError()

  # Create window
  CORE.window = sdl.createWindow(
    SETTINGS.title,
    sdl.WindowPosUndefined,
    sdl.WindowPosUndefined,
    SETTINGS.width, SETTINGS.height,
    flags)

  if CORE.window == nil:
    quit "ERROR: can't create window: " & $sdl.getError()

  CORE.surface = CORE.window.getWindowSurface()
  CORE.canvas = newBuffer(SETTINGS.width, SETTINGS.height)
  CORE.canvas_size = SETTINGS.width * SETTINGS.height * sizeof(Pixel)

  mixer.init(SETTINGS.samplerate, SETTINGS.buffersize)
  CORE.running = true

proc run*(update: proc(dt: float), draw: proc()) =
  var last = 0.0

  var updateFunc = update
  var drawFunc = draw

  while CORE.running:
    for e in system.poll():
      if e.id == system.QUIT:
        CORE.running = false
      system.update(e)

    timer.step()

    if updateFunc != nil:
      updateFunc(timer.getDelta())

    # clear the screen
    CORE.canvas.clear(SETTINGS.clear)

    # run the draw callback
    if drawFunc != nil:
      drawFunc()

    # draw the buffer to the screen
    if CORE.surface != nil and CORE.surface.mustLock():
      if CORE.surface.lockSurface() != 0:
        quit "ERROR: couldn't lock screen: " & $sdl.getError()
    copyMem(CORE.surface.pixels, CORE.canvas.pixels[0].addr, CORE.canvas_size)
    if CORE.surface.mustLock(): CORE.surface.unlockSurface()
    if CORE.window.updateWindowSurface() != 0:
      quit "ERROR: couldn't update screen: " & $sdl.getError()

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

# CONFIG
proc resetVideoMode() =
  discard sdl.setWindowFullscreen(CORE.window, if SETTINGS.fullscreen: sdl.WINDOW_FULLSCREEN_DESKTOP else: 0)
  sdl.setWindowSize(CORE.window, SETTINGS.width, SETTINGS.height)
  CORE.canvas_size = SETTINGS.width * SETTINGS.height * sizeof(Pixel)
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

proc getAudioSampleRate*(): int =
  SETTINGS.samplerate
  
proc setAudioSampleRate*(samplerate: int) =
  SETTINGS.samplerate = samplerate

proc getAudioBufferSize*(): uint =
  SETTINGS.buffersize

proc setAudioBufferSize*(buffersize: uint) =
  SETTINGS.buffersize = buffersize

# GIF
# proc writeGif*(gif: Gif, delay=0.0, localPalette=false) =
  # gifwriter.writeGif(gif, CORE.canvas, delay, localPalette)

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
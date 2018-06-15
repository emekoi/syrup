##
##  Copyright (c) 2017 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import
  sdl2/sdl, suffer, os, tables,
  syrup/[system, keyboard, mouse, time, graphics, debug]

type
  Context = ref object
    running*: bool
    window*: sdl.Window
    surface*: sdl.Surface
    canvas_size: int

  Config = tuple
    title: string
    width, height: int
    fullscreen: bool
    resizable: bool
    bordered: bool
    fps: float
    samplerate: int
    buffersize: uint

var
  CORE: Context
  SETTINGS: Config = (
    "syrup", 512, 512,
    false, false, true,
    60.0, 44100, 1024'u
  )
  
proc finalize(ctx: Context) =
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
  graphics.canvas.resize(SETTINGS.width, SETTINGS.height)
  CORE.canvas_size = SETTINGS.width * SETTINGS.height * sizeof(Pixel)

  CORE.running = true

proc run*(update: proc(dt: float), draw: proc()) =
  var last = 0.0

  var updateFunc = update
  var drawFunc = draw

  when defined(useRealtimeGC):
    GC_disable()
  while CORE.running:
    for e in system.poll():
      if e.id == system.QUIT:
        CORE.running = false
      system.update(e)

    time.step()

    if updateFunc != nil:
      updateFunc(time.getDelta())

    # clear the screen
    graphics.clear()

    # run the draw callback
    if drawFunc != nil:
      drawFunc()

    # draw debug indicators
    debug.drawIndicators()

    # reset input
    keyboard.reset()
    mouse.reset()

    # draw the buffer to the screen
    if CORE.surface != nil and CORE.surface.mustLock():
      if CORE.surface.lockSurface() != 0:
        quit "ERROR: couldn't lock screen: " & $sdl.getError()
    copyMem(CORE.surface.pixels, graphics.canvas.pixels[0].addr, CORE.canvas_size)
    if CORE.surface.mustLock(): CORE.surface.unlockSurface()
    if CORE.window.updateWindowSurface() != 0:
      quit "ERROR: couldn't update screen: " & $sdl.getError()

    let step = 1.0 / SETTINGS.fps

    when defined(useRealtimeGC):
    # run the GC
      GC_step((step * 1.0e6).int)

    # wait for next frame
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
  graphics.canvas.resize(SETTINGS.width, SETTINGS.height)
  graphics.canvas.reset()
  
proc getTitle*(): string = SETTINGS.title

proc getWidth*(): int = SETTINGS.width

proc getHeight*(): int = SETTINGS.height

proc getFullscreen*(): bool = SETTINGS.fullscreen

proc getResizable*(): bool = SETTINGS.resizable

proc getBordered*(): bool = SETTINGS.bordered

proc getMaxFps*(): float = SETTINGS.fps

proc getSampleRate*(): int = SETTINGS.samplerate

proc getBufferSize*(): uint = SETTINGS.buffersize

proc setTitle*(title: string) =
  SETTINGS.title = title
  sdl.setWindowTitle(CORE.window, title)

proc setWidth*(width: int) =
  SETTINGS.width = width
  resetVideoMode()

proc setHeight*(height: int) =
  SETTINGS.height = height
  resetVideoMode()

proc setFullscreen*(fullscreen: bool) =
  SETTINGS.fullscreen = fullscreen
  resetVideoMode()

proc setResizable*(resizable: bool) =
  SETTINGS.resizable = resizable
  resetVideoMode()

proc setBordered*(bordered: bool) =
  SETTINGS.bordered = bordered
  resetVideoMode()

proc setMaxFps*(fps: float) =
  SETTINGS.fps = fps
  
proc setSampleRate*(samplerate: int) =
  SETTINGS.samplerate = samplerate

proc setBufferSize*(buffersize: uint) =
  SETTINGS.buffersize = buffersize

# GIF
# proc writeGif*(gif: Gif, delay=0.0, localPalette=false) =
  # gifwriter.writeGif(gif, CORE.canvas, delay, localPalette)

if CORE == nil:
  setup()
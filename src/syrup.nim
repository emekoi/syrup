##
##  Copyright (c) 2018 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import
  sdl2/sdl, sdl2/sdl_gpu as gpu, os, tables,
  syrup/[system, keyboard, mouse, time, graphics]

type
  Context = ref object
    running*: bool
    window*: sdl.Window

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

proc resetVideoMode() =
  discard gpu.setFullscreen(SETTINGS.fullscreen, true)
  discard gpu.setWindowResolution(uint16(SETTINGS.width), uint16(SETTINGS.height))
  # sdl.setWindowResizable(CORE.window, if SETTINGS.resizable: true else: false)
  # sdl.setWindowBordered(CORE.window, if SETTINGS.bordered: true else: false)
  # graphics.canvas.resize(SETTINGS.width, SETTINGS.height)
  # graphics.canvas.reset()

proc finalize(ctx: Context) =
  ctx.window.destroyWindow()
  gpu.quit()
  sdl.quit()

proc setup() =
  new(CORE, finalize)

  let flags = uint32(gpu.INIT_DISABLE_VSYNC)

  # set debug level
  when not defined(release):
    gpu.setDebugLevel(gpu.DEBUG_LEVEL_MAX)
    when defined(windows):
      setStdIoUnbuffered()

  # setup rendering target
  when defined(OPENGL2) or true:
    graphics.screen = gpu.initRenderer(gpu.RENDERER_OPENGL_2,
      uint16(SETTINGS.width), uint16(SETTINGS.height), flags)
  else:
    graphics.screen = gpu.init(uint16(SETTINGS.width), uint16(SETTINGS.height), flags)

  if graphics.screen.isNil:
    gpu.logError("failed to create screen target")
    quit(QuitFailure)

  CORE.window = sdl.getWindowFromID(1)
  if CORE.window.isNil:
    gpu.logError("failed to find window")
    quit(QuitFailure)

  CORE.running = true

proc run*(update: proc(dt: float), draw: proc()) =
  var last = 0.0

  var updateFunc = update
  var drawFunc = draw

  when defined(useRealtimeGC):
    GC_disable()

  while CORE.running:
    for e in system.poll():
      case e.id:
        of EventType.QUIT:
          CORE.running = false
        of EventType.RESIZE:
          SETTINGS.width = e.width
          SETTINGS.height = e.height
          resetVideoMode()
        else:
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
    # debug.drawIndicators()

    # reset input
    keyboard.reset()
    mouse.reset()

    # update the screen
    graphics.screen.flip()

    let step = 1.0 / SETTINGS.fps

    # run the GC
    when defined(useRealtimeGC):
      GC_step((step * 1.0e6).int)

    # wait for next frame
    let now = sdl.getTicks().float / 1000.0
    let wait = step - (now - last);
    last += step
    if wait > 0:
      sleep((wait * 1000.0).int)
    else:
      last = now

{.push inline.}

proc exit*() =
  CORE.running = false

proc getTitle*(): string =
  SETTINGS.title

proc getWidth*(): int =
  SETTINGS.width

proc getHeight*(): int =
  SETTINGS.height

proc getFullscreen*(): bool =
  SETTINGS.fullscreen

proc getResizable*(): bool =
  SETTINGS.resizable

proc getBordered*(): bool =
  SETTINGS.bordered

proc getMaxFps*(): float =
  SETTINGS.fps

proc getSampleRate*(): int =
  SETTINGS.samplerate

proc getBufferSize*(): uint =
  SETTINGS.buffersize

{.pop.}

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
  if SETTINGS.fullscreen != fullscreen:
    SETTINGS.fullscreen = fullscreen
    resetVideoMode()

proc setResizable*(resizable: bool) =
  if SETTINGS.resizable != resizable:
    SETTINGS.resizable = resizable
    resetVideoMode()

proc setBordered*(bordered: bool) =
  if SETTINGS.bordered != bordered:
    SETTINGS.bordered = bordered
    resetVideoMode()

proc setMaxFps*(fps: float) =
  SETTINGS.fps = fps

proc setSampleRate*(samplerate: int) =
  SETTINGS.samplerate = samplerate

proc setBufferSize*(buffersize: uint) =
  SETTINGS.buffersize = buffersize

setup()

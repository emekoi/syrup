##
##  Copyright (c) 2018 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import
  sdl2/sdl, sdl2/sdl_gpu as gpu, os, tables,
  syrup/[system, keyboard, mouse, font, time, graphics, mixer, debug]

type
  Context = ref object
    running: bool
    window: sdl.Window
    target: gpu.Target

  Config = tuple
    title: string
    width, height: int
    fullscreen: bool
    resizable: bool
    bordered: bool
    fps: float
    sampleRate: int
    bufferSize: uint

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
  sdl.setWindowResizable(CORE.window, SETTINGS.resizable)
  sdl.setWindowBordered(CORE.window, SETTINGS.bordered)
  # graphics.canvas.resize(SETTINGS.width, SETTINGS.height)
  graphics.resetTexture()

proc resetMixer() =
  mixer.deinit()
  mixer.init(SETTINGS.sampleRate, SETTINGS.bufferSize)

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

  when defined(OPENGL2):
    CORE.target = gpu.initRenderer(gpu.RENDERER_OPENGL_2,
      uint16(SETTINGS.width), uint16(SETTINGS.height), flags)
  else:
    CORE.target = gpu.init(uint16(SETTINGS.width), uint16(SETTINGS.height), flags)

  if CORE.target.isNil:
    gpu.logError("failed to create screen target")
    quit(QuitFailure)

  graphics.screen = newTexture(SETTINGS.width, SETTINGS.height)

  # context is nil unless we created the window ourselves
  # CORE.window = sdl.getWindowFromID(graphics.screen.context.windowID)

  CORE.window = sdl.getWindowFromID(1)
  if CORE.window.isNil:
    gpu.logError("failed to find window")
    quit(QuitFailure)

  # initialize mixer
  mixer.init(SETTINGS.sampleRate, SETTINGS.bufferSize)

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
        of system.EventType.QUIT:
          CORE.running = false
        of system.EventType.RESIZE:
          SETTINGS.width = e.width
          SETTINGS.height = e.height
          resetVideoMode()
        else:
          system.update(e)

    time.step()

    # clear the screen
    CORE.target.clear()
    graphics.clear()

    if updateFunc != nil:
      updateFunc(time.getDelta())

    # run the draw callback
    if drawFunc != nil:
      drawFunc()

    # draw debug indicators
    debug.drawIndicators()

    # reset input
    keyboard.reset()
    mouse.reset()

    # update the screen
    graphics.screen.image.blit(
      nil, CORE.target,
      SETTINGS.width / 2,
      SETTINGS.height / 2
    )
    CORE.target.flip()

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
  resetMixer()

proc setBufferSize*(buffersize: uint) =
  SETTINGS.buffersize = buffersize
  resetMixer()

setup()

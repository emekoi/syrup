##
##  Copyright (c) 2017 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import
  glfw, os, tables, strutils,
  syrup/[embed, shader, gl, texture],
  syrup/[timer, renderer]

type
  Context = ref object
    window*: glfw.Window
    gfx*: Renderer

type Config* = tuple
  title: string
  width, height: int
  fullscreen: bool
  resizable: bool
  bordered: bool
  fps: float

var
  CORE: Context
  SETTINGS: Config = (
    "syrup", 512, 512,
    false, false, true,
    60.0
  )

proc windowSizeCb(w: Window not nil, size: tuple[w, h: int32])
proc keyCbDebug(w: Window, key: Key, scanCode: int32, action: KeyAction, mods: set[ModifierKey])

proc finalize(ctx: Context) =
  ctx.window.destroy()
  glfw.terminate()

proc setup() =
  new(CORE, finalize)
  glfw.initialize()

  # configure glfw
  var c = glfw.DefaultOpenglWindowConfig
  c.size.w = SETTINGS.width
  c.size.h = SETTINGS.height
  c.title = SETTINGS.title
  c.resizable = SETTINGS.resizable
  c.version = glv21
  c.doubleBuffer = true

  CORE.window = glfw.newWindow(c)
  CORE.window.windowSizeCb = windowSizeCb
  CORE.window.keyCb = keyCbDebug

  loadExtensions()

  CORE.gfx = newRenderer(SETTINGS.width, SETTINGS.height)

proc run*(update: proc(dt: float), draw: proc()) =
  var last = 0.0

  var updateFunc = update
  var drawFunc = draw

  while not CORE.window.shouldClose():
    glfw.pollEvents()
    timer.step()

    if updateFunc != nil:
      updateFunc(0.0)

    if drawFunc != nil:
      drawFunc()

    CORE.gfx.clear()
    CORE.gfx.render()
    
    CORE.window.swapBuffers()

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
  CORE.window.shouldClose = true

proc resetVideoMode() =
  CORE.window.size = (SETTINGS.width, SETTINGS.height)
  GC_unref(CORE.gfx)
  CORE.gfx = newRenderer(SETTINGS.width, SETTINGS.height)
  
proc getConfig*(): Config =
  SETTINGS

proc setConfig*(c: Config) =
  SETTINGS = c
  resetVideoMode()

proc getWindowTitle*(): string =
  SETTINGS.title

proc setWindowTitle*(title: string) =
  SETTINGS.title = title
  CORE.window.title = title

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

# proc getWindowFullscreen*(): bool =
#   SETTINGS.fullscreen

# proc setWindowFullscreen*(fullscreen: bool) =
#   SETTINGS.fullscreen = fullscreen
#   resetVideoMode()

# proc getWindowResizable*(): bool =
#   SETTINGS.resizable

# proc setWindowResizable*(resizable: bool) =
#   SETTINGS.resizable = resizable
#   resetVideoMode()

# proc getWindowBordered*(): bool =
#   SETTINGS.bordered

# proc setWindowBordered*(bordered: bool) =
#   SETTINGS.bordered = bordered
#   resetVideoMode()

# proc setWindowClear*(): Pixel =
#   SETTINGS.clear

# proc setWindowClear*(color: Pixel) =
#   SETTINGS.clear = color

proc getWindowFps*(): float =
  SETTINGS.fps

proc setWindowFps*(fps: float) =
  SETTINGS.fps = fps

proc windowSizeCb(w: Window not nil, size: tuple[w, h: int32]) =
  SETTINGS.width = size.w
  SETTINGS.height = size.h
  resetVideoMode()

proc keyCbDebug(w: Window, key: Key, scanCode: int32, action: KeyAction, mods: set[ModifierKey]) =

  if key == keyR:
    let shader = newShaderFromFile("syrup/embed/default.vert", "syrup/embed/default.frag")
    CORE.gfx.setShader(shader)

  if action != kaUp and (key == keyEscape or key == keyF4 and mkAlt in mods):
    w.shouldClose = true

if CORE == nil:
  setup()

run(nil, nil)
#
#  Copyright (c) 2018 emekoi
# 
#  This library is free software; you can redistribute it and/or modify it
#  under the terms of the MIT license. See LICENSE for details.
#

import system, tables

var buttonsDown* = newTable[string, bool]()
var buttonsPressed* = newTable[string, bool]()
var mousePos*: tuple[x, y: int]

proc mouseDown*(buttons: varargs[string]): bool =
  result = false
  for b in buttons:
    if buttonsDown.hasKey(b) and buttonsDown[b]:
      return true

proc mousePressed*(buttons: varargs[string]): bool =
  result = false
  for b in buttons:
    if buttonsPressed.hasKey(b) and buttonsPressed[b]:
      return true

proc mouseReleased*(buttons: varargs[string]): bool =
  mouseDown(buttons) and not mousePressed(buttons)

proc mousePosition*(): (int, int) =
  (mousePos.x, mousePos.y)

# proc mouseButtonCallback(w: Window, button: MouseButton, pressed: bool, mods: set[ModifierKey]) =
#   let key = $key.keyName()
#   case action:
#     of kaUp:
#       keysDown[key] = false
#     of kaDown:
#       keysDown[key] = true
#       keysPressed[key] = true
#     of kaRepeat: discard

proc reset*() =
  for k, _ in buttonsPressed: buttonsPressed[k] = false

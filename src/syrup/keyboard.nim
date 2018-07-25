#  Copyright (c) 2017 emekoi
#
#  This library is free software; you can redistribute it and/or modify it
#  under the terms of the MIT license. See LICENSE for details.
#

import tables
import glfw

var keysDown* = newTable[string, bool]()
var keysPressed* = newTable[string, bool]()

proc keyDown*(keys: varargs[string]): bool =
  result = false
  for k in keys:
    if keysDown.hasKey(k) and keysDown[k]:
      return true

proc keyPressed*(keys: varargs[string]): bool =
  result = false
  for k in keys:
    if keysPressed.hasKey(k) and keysPressed[k]:
      return true

proc keyReleased*(keys: varargs[string]): bool =
  keyPressed(keys) and not keyDown(keys)

proc keyboardCallback(w: Window, key: Key, scanCode: int32, action: KeyAction, mods: set[ModifierKey]) =
  let key = $key.keyName()
  case action:
    of kaUp:
      keysDown[key] = false
    of kaDown:
      keysDown[key] = true
      keysPressed[key] = true
    of kaRepeat: discard

proc reset*() =
  for k, _ in keysPressed: keysPressed[k] = false

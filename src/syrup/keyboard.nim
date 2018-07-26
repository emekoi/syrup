##
##  Copyright (c) 2018 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import system, tables

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

proc onEvent(e: Event) =
  case e.id
  of QUIT, NONE: discard
  of RESIZE: discard
  of KEYDOWN:
    keysDown[e.key] = true
    keysPressed[e.key] = true
  of KEYUP:
    keysDown[e.key] = false
  of TEXTINPUT: discard
  else: discard

proc reset*() =
  for k, _ in keysPressed: keysPressed[k] = false

system.addEventHandler(onEvent)

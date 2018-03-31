##
##  Copyright (c) 2017 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import system, tables

var keysDown* = newTable[string, bool]()
var keysPressed* = newTable[string, bool]()
var buttonsDown* = newTable[string, bool]()
var buttonsPressed* = newTable[string, bool]()
var mousePos*: tuple[x, y: int]


proc onEvent*(e: Event) =
  case e.id
  of QUIT, NONE: discard
  of RESIZE: discard
  of KEYDOWN:
    keysDown[e.key] = true
    keysPressed[e.key] = true
  of KEYUP:
    keysDown[e.key] = false
  of TEXTINPUT: discard
  of MOUSEMOVE:
    mousePos = (e.x, e.y)
  of MOUSEBUTTONDOWN:
    buttonsDown[e.press.button] = true
    buttonsPressed[e.press.button] = true
  of MOUSEBUTTONUP:
    buttonsDown[e.press.button] = false

proc reset*() =
  for k, _ in keysPressed:
    keysPressed[k] = false
  for k, _ in buttonsPressed:
    buttonsPressed[k] = false
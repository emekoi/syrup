##
##  Copyright (c) 2017 emekoi
## 
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import ../src/syrup
import random, times

setWindowTitle("window")
setWindowClear(color(255, 255, 255))

var x, y = 0
const step = 20
var ticks = 0.0

var 
  shader: Shader
  frame: Buffer

proc init() =
  shader = newShaderFromFile("shader.glsl")
  frame = newBuffer(512, 512)
  # shader.use()
  # shader.setVec2("u_resolution", 512, 512)

  frame.floodFill color(255, 255, 255), 0, 0

proc update(dt: float) =
  if keyDown("escape"): exit()
  # (x, y) = mousePosition()

proc draw() =
  if rand(1.0) > 0.5:
    frame.drawLine color(255, 0, 0), x, y, x + step, y + step
    # frame.drawLine color(0, 255, 0), x, y, x + step, y + step
    # frame.drawLine color(0, 0, 255), x, y, x + step, y + step
  else:
    frame.drawLine color(255, 0, 0), x, y + step, x + step, y
    # frame.drawLine color(0, 255, 0), x, y + step, x + step, y
    # frame.drawLine color(0, 0, 255), x, y + step, x + step, y
  
  x += step
  if x > 512:
    y += step
    x = 0

  drawBuffer(frame, 0, 0)
  drawText color(0, 0, 0), $syrup.timer.getFps(), 2, 0

  # shader.setVec2("u_mouse", x.float, y.float)
  # shader.setFloat("u_time", ticks)
  # ticks += 0.01

syrup.run(init, update, draw)
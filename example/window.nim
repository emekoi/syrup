##
##  Copyright (c) 2017 emekoi
## 
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import ../src/syrup
import random, times

var x, y = 0
const step = 2
var ticks = 0.0

var shader: Shader

proc config(): Config =
  (title: "window", w: 512, h: 512, clear: color(255, 255, 255), fps: 60.0)

proc init() =
  clear false  
  shader = newShader("shader.glsl")
  shader.use()
  shader.setVec2("u_resolution", 512, 512)

  floodFill color(255, 255, 255), 0, 0

proc draw() =
  # drawText color(0, 0, 0), $syrup.timer.getFps(), 2, 0
  # if rand(1.0) > 0.5:
  #   drawLine color(0, 0, 0), x, y, x + step, y + step
  # else:
  #   drawLine color(0, 0, 0), x, y + step, x + step, y
  
  # x += step
  # if x > 512:
  #   y += step
  #   x = 0
  # shader.setVec2("u_mouse", , )
  shader.setFloat("u_time", ticks)
  ticks += 0.01

syrup.run(config, init, nil, draw)
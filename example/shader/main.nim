##
##  Copyright (c) 2017 emekoi
## 
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import ../../src/syrup
import random, times

setWindowTitle("shader")
setWindowClear(color(255, 255, 255))

var x, y = 0
var ticks = 0.0

var shader = newShaderFromFile("example/shader/shader.glsl")  
shader.use()
shader.setVec2("u_resolution", 512, 512)

proc update(dt: float) =
  if keyDown("escape"): exit()
  (x, y) = mousePosition()

proc draw() =
  shader.setVec2("u_mouse", x.float, y.float)
  shader.setFloat("u_time", ticks)
  ticks += 0.01

syrup.run(update, draw)
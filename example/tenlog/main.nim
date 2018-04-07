##
##  Copyright (c) 2017 emekoi
## 
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import ../../src/syrup
import random, times, math

setWindowTitle("10log")
setWindowClear(color(0.15, 0.15, 0.2))

const step = 8

var
  x, y = 0
  elapsed = 0.0
  frame = newBuffer(128, 128)

frame.clear(pixel(255, 255, 255, 0))

proc update(dt: float) =
  if keyDown("escape"): exit()
  elapsed += dt

proc draw() =
  let
    r = (1 + math.sin(elapsed * 1.2) / 2)
    g = (1 + math.sin(elapsed * 1.6) / 2)
    b = (1 + math.sin(elapsed * 0.7) / 2)

  if rand(1.0) > 0.5:
    frame.drawLine color(0xff, 0xff, 0xff), x, y, x + step, y + step
  else:
    frame.drawLine color(0xff, 0xff, 0xff), x, y + step, x + step, y

  x += step
  if x > frame.w:
    y += step
    x = 0
  if y > frame.h:
    frame.clear(pixel(255, 255, 255, 0))
    x = 0
    y = 0

  setColor color(r, g, b)
  # drawBuffer(frame, 0, 0, transform(sx=4.0, sy=4.0))

syrup.run(update, draw)
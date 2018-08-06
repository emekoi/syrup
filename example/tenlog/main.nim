##
##  Copyright (c) 2018 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import syrup
import syrup/[keyboard, graphics, debug]
import random, times, math

syrup.setTitle("10log")
graphics.clearColor = (0.15, 0.15, 0.2, 1.0)

const step = 8

var
  x, y = 0
  elapsed = 0.0
  frame = newTexture(128, 128)

frame.clear()

proc update(dt: float) =
  if keyboard.keyPressed("escape"): exit()
  elapsed += dt / 2

proc draw() =
  let
    r = (1 + math.sin(elapsed * 1.2) / 2)
    g = (1 + math.sin(elapsed * 1.6) / 2)
    b = (1 + math.sin(elapsed * 0.7) / 2)

  if rand(1.0) > 0.5:
    frame.drawLine (1.0, 1.0, 1.0, 1.0), x, y, x + step, y + step
  else:
    frame.drawLine (1.0, 1.0, 1.0, 1.0), x, y + step, x + step, y

  x += step
  if x > frame.width:
    y += step
    x = 0
  if y > frame.height:
    frame.clear((1.0, 1.0, 1.0, 0.0))
    x = 0
    y = 0

  frame.setColor (r, g, b, 1.0)
  graphics.drawTexture(frame, 256, 256, transform(sx=4.0, sy=4.0))

syrup.run(update, draw)

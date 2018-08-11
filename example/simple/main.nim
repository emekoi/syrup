##
##  Copyright (c) 2018 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import syrup, syrup/[keyboard, graphics, debug, font]
import random, times, math

syrup.setTitle("simple")
let bigFont = font.newFontDefault(32.0)

proc update(dt: float) =
  if keyboard.keyPressed("escape"): exit()
  if keyboard.keyPressed("return"):
    debug.setVisible(not debug.getVisible())
  if keyboard.keyPressed("space"):
    syrup.setFullscreen(not syrup.getFullscreen())

proc draw() =
  bigFont.drawText((1.0, 1.0, 1.0, 1.0), "HELLO WORLD", 255, 255)
  bigFont.drawText((1.0, 1.0, 1.0, 1.0), "HELLO WORLD", 255, 127)
  graphics.drawRing((1.0, 0.0, 0.0, 1.0), 65, 255, 127)

syrup.run(update, draw)

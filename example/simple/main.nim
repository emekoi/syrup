##
##  Copyright (c) 2018 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import syrup, syrup/[keyboard, graphics]
import random, times, math

syrup.setTitle("simple")
# syrup.setFullscreen(true)

proc update(dt: float) =
  if keyboard.keyDown("escape"): exit()

proc draw() =
  # graphics.screen.clear((1.0, 1.0, 0.0, 1.0))
  discard

syrup.run(update, draw)

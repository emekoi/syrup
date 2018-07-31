##
##  Copyright (c) 2018 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import syrup, syrup/[keyboard, font]
import random, times, math

syrup.setTitle("simple")
# syrup.setFullscreen(true)

proc update(dt: float) =
  if keyboard.keyDown("escape"): exit()

proc draw() =
  discard

syrup.run(update, draw)

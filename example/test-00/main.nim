##
##  Copyright (c) 2017 emekoi
## 
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import syrup, syrup/[keyboard]

setWindowTitle("test-00")

proc update(dt: float) =
  if keyDown("escape"): exit()

proc draw() = discard

syrup.run(update, draw)
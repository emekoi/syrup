##
##  Copyright (c) 2017 emekoi
## 
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import math, times
import glfw

var
  last = 0.0
  delta = 0.0
  average = 0.0
  avgTimer = 0.0
  avgAcc = 1.0
  avgCount = 1.0

proc getNow*(): float {.inline.} =
  times.epochTime()

proc getTime*(): float {.inline.} =
  glfw.getTime()

proc step*() =
  let now = glfw.getTime()
  if last == 0: last = now
  delta = now - last
  last = now
  avgTimer = avgTimer - delta
  avgAcc = avgAcc + delta
  avgCount = avgCount + 1
  if avgTimer <= 0:
    average = avgAcc / avgCount
    avgTimer = avgTimer + 1
    avgCount = 0
    avgAcc = 0

proc getDelta*(): float {.inline.} =
  delta

proc getAverage*(): float {.inline.} =
  average

proc getFps*(): int32 {.inline.} =
  (1 / average + 0.5).floor().int32()
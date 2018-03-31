##
##  Copyright (c) 2017 emekoi
## 
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import
  suffer,
  timer

type Animation* = object
  fps*: int
  frames*: seq[Rect]
  currentFrame: int
  wait, timer: float

proc newAnimation*(fps: int, frames: varargs[Rect]): Animation =
  result.fps = fps
  result.wait = 1 / fps
  result.currentFrame = 1
  result.timer = result.wait
  result.frames = newSeq[Rect](frames.len)
  for i in 0..<frames.len:
    result.frames[i] = frames[i]

proc getFrame*(anim: var Animation): Rect =
  anim.timer -= timer.getDelta()
  if anim.timer <= 0.0:
    anim.currentFrame += 1
    if anim.currentFrame == anim.frames.len:
      anim.currentFrame = 1
    anim.timer = anim.wait
  anim.frames[anim.currentFrame]
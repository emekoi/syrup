##
##  Copyright (c) 2017 emekoi
## 
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import
  suffer,
  timer

type
  Animation* = object
    fps*: int
    frames*: seq[Rect]
    currentFrame: int
    wait, timer: float

  # DrawListType {.pure.} = enum
  #   LINE,
  #   RECT,
  #   BOX, 
  #   CIRCLE,
  #   RING,
  #   TEXT,
  #   BUFFER,
  #   PROC

template lerp[T](a, b, p: T): T =
  (1 - p) * a + p * b

proc lerp*(fm, to: Pixel, t: float): Pixel =
  result.rgba.r = lerp(fm.rgba.r.float, to.rgba.r.float, t).uint8
  result.rgba.g = lerp(fm.rgba.g.float, to.rgba.g.float, t).uint8
  result.rgba.b = lerp(fm.rgba.b.float, to.rgba.b.float, t).uint8
  result.rgba.a = lerp(fm.rgba.a.float, to.rgba.a.float, t).uint8


  # DrawListItem = object
  #   case kind: DrawListType
  #   of DrawListType.LINE:
  #     line: tuple[color: Pixel, x0, y0, x1, y1: int]
  #   of DrawListType.RECT:
  #     rect: tuple[color: Pixel, x, y, w, h: int]
  #   of DrawListType.BOX:
  #     box: tuple[color: Pixel, x, y, w, h: int]
  #   of DrawListType.CIRCLE:
  #     circle: tuple[color: Pixel, x, y, r: int]
  #   of DrawListType.RING:
  #     ring: tuple[color: Pixel, x, y, r: int]
  #   of DrawListType.TEXT:
  #     text: tuple[color: Pixel, font: Font, x, y, r: int]
  #   of DrawListType.BUFFER:
  #     buffer: tuple[dest: Buffer, x, y: int, sub: Rect, t: Transform]
  #   of DrawListType.PROC:
  #     cb: tuple[color: Pixel, x0, y0, x1, y1: int]

  # DrawList* = object


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
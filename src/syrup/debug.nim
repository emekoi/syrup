##
##  Copyright (c) 2018 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import math, graphics, font, time

type
  IndicatorCallBack* = proc(): (string, SomeNumber)
  Indicator* = proc()

let
  DEFAULT_FONT = font.newFontDefault(32.0)
  PADDING = 8

var
  enabled = false
  textRegionWidth = 20
  indicators = newSeq[Indicator]()

proc newIndicator[T: SomeNumber](fn: IndicatorCallBack, min, max: T=0): Indicator =
  var
    min = min
    max = max
    trueMin = min
    trueMax = max
    # get idx
    indicatorIdx =
      if indicators.len == 0:
        0
      else:
        indicators.len
    # Init
    pad = 8
    height = 26
    maxBars = 16
    barUpdatePeriod = 1
    yoffset = pad + height * indicatorIdx
    lastUpdate = time.getNow()
    bars = newSeq[T](maxBars)
  # create the display proc
  result = proc() =
    var (txt, val) = fn()
    textRegionWidth = textRegionWidth.max(DEFAULT_FONT.getWidth(txt) + PADDING)
    if time.getNow() > lastUpdate + barUpdatePeriod.float:
      discard bars.pop()
      bars.insert(val)
      min = trueMin.min(bars.min())
      max = trueMax.max(bars.max())
      lastUpdate = time.getNow()
    # draw text
    var w = textRegionWidth
    graphics.drawRect(
      (0.0, 0.0, 0.0, 0.8),
      pad div 2, yoffset - (pad div 2),
      w, height - 1
    )

    font.drawText(
      (1.0, 1.0, 1.0, 1.0),
      txt, (pad div 2) + (w div 2),
      (yoffset - (pad div 2)) + ((height - 1) div 2)
    )



    # draw bars
    graphics.drawRect(
      (0.0, 0.0, 0.0, 0.8),
      pad div 2 + w + 1,
      yoffset - (pad div 2),
      73, height - 1
    )
    for i, v in bars.pairs():
      var x = if min != max:
        int(((bars[i] - min) / (max - min) * 16).floor())
      else:
        0
      graphics.drawRect(
        (1.0, 1.0, 1.0, if i == 0: 1.0 else: 0.4),
        pad div 2 + w + PADDING div 2 + (i - 1) * 4 + 5,
        yoffset + 16 - x, 3, x
      )

proc drawIndicators*() =
  if not enabled: return
  graphics.resetTexture()
  # graphics.clear()
  for p in indicators: p()

proc setVisible*(e: bool) =
  enabled = e

proc getVisible*(): bool =
  enabled

proc addIndicator*[T: SomeNumber](fn: IndicatorCallBack, min, max: T=0): Indicator =
  result = newIndicator(fn, min, max)
  indicators.add(result)

discard addIndicator(proc(): (string, int) =
  var r = time.getFps()
  ($r & "fps", r),
  0
)

discard addIndicator(proc(): (string, int) =
  var m = getOccupiedMem() div 1e3.int
  ($m & "kb", m),
  0
)

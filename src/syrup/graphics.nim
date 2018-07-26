##
##  Copyright (c) 2018 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import suffer, embed, font
export suffer 

let
  DEFAULT_FONT = font.fromDefault()
  canvas*: Buffer = newBuffer(1, 1)

var
  clearColor* = color(255, 255, 255)

proc cloneBuffer*(): Buffer = canvas.cloneBuffer()
proc loadPixels*(src: openarray[uint32], fmt: suffer.PixelFormat) = canvas.loadPixels(src, fmt)
proc loadPixels8*(src: openarray[uint8], pal: openarray[Pixel]) = canvas.loadPixels8(src, pal)
proc loadPixels8*(src: openarray[uint8]) = canvas.loadPixels8(src)
proc setBlend*(blend: suffer.BlendMode) = canvas.setBlend(blend)
proc setAlpha*[T](alpha: T) = canvas.setAlpha(alpha)
proc setColor*(c: Pixel) = canvas.setColor(c)
proc setClip*(r: suffer.Rect) = canvas.setClip(r)
proc reset*() = canvas.reset()
proc clear*(c: Pixel) = canvas.clear(c)
proc clear*() = canvas.clear(clearColor)
proc getPixel*(x: int, y: int): Pixel = canvas.getPixel(x, y)
proc setPixel*(c: Pixel, x: int, y: int) = canvas.setPixel(c, x, y)
proc copyPixels*(src: Buffer, x, y: int, sub: suffer.Rect, sx, sy: float=1.0) = canvas.copyPixels(src, x, y, sub, sx, sy)
proc copyPixels*(src: Buffer, x, y: int, sx, sy: float=1.0) = canvas.copyPixels(src, x, y, sx, sy)
proc noise*(seed: uint, low, high: int, grey: bool) = canvas.noise(seed, low, high, grey)
proc floodFill*(c: Pixel, x, y: int) = canvas.floodFill(c, x, y)
proc drawPixel*(c: Pixel, x, y: int) = canvas.drawPixel(c, x, y)
proc drawLine*(c: Pixel, x0, y0, x1, y1: int) = canvas.drawLine(c, x0, y0, x1, y1)
proc drawRect*(c: Pixel, x, y, w, h: int) = canvas.drawRect(c, x, y, w, h)
proc drawBox*(c: Pixel, x, y, w, h: int) = canvas.drawBox(c, x, y, w, h)
proc drawCircle*(c: Pixel, x, y, r: int) = canvas.drawCircle(c, x, y, r)
proc drawRing*(c: Pixel, x, y, r: int) = canvas.drawRing(c, x, y, r)
proc drawText*(font: Font, c: Pixel, txt: string, x, y: int, width: int=0) = canvas.drawText(font, c, txt, x, y, width)
proc drawText*(c: Pixel, txt: string, x, y: int, width: int=0) = canvas.drawText(DEFAULT_FONT, c, txt, x, y, width)
proc drawBuffer*(src: Buffer, x, y: int, sub: suffer.Rect, t: Transform) = canvas.drawBuffer(src, x, y, sub, t)
proc drawBuffer*(src: Buffer, x, y: int, sub: suffer.Rect) = canvas.drawBuffer(src, x, y, sub)
proc drawBuffer*(src: Buffer, x, y: int, t: Transform) = canvas.drawBuffer(src, x, y, t)
proc drawBuffer*(src: Buffer, x, y: int) = canvas.drawBuffer(src, x, y)
proc desaturate*(amount: int) = canvas.desaturate(amount)
proc mask*(mask: Buffer, channel: char) = canvas.mask(mask, channel)
proc palette*(palette: openarray[Pixel]) = canvas.palette(palette)
proc dissolve*(amount: int, seed: uint) = canvas.dissolve(amount, seed)
proc wave*(src: Buffer, amountX, amountY, scaleX, scaleY, offsetX, offsetY: int) = canvas.wave(src, amountX, amountY, scaleX, scaleY, offsetX, offsetY)
proc displace*(src, map: Buffer, channelX, channelY: char, scaleX, scaleY: int) = canvas.displace(src, map, channelX, channelY, scaleX, scaleY)
proc blur*(src: Buffer, radiusx, radiusy: int) = canvas.blur(src, radiusx, radiusy)
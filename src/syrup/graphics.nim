##
##  Copyright (c) 2018 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import sdl2/sdl_gpu as gpu
# import font

type
  ColorFormat* {.pure.} = enum
    ## the different pixel formats supported
    BGRA
    RGBA
    ARGB
    ABGR

  Color* {.packed.} = tuple
    ## a normalized rgba color
    r, g, b, a: float

  Rect* {.packed.} = tuple
    ## a rectangle used for clipping and drawing specific regions of texture
    x, y, w, h: int

  Transform* {.packed.} = tuple
    ## describes a texure tranformation
    ox, oy, r, sx, sy: float

  Texture* = ref object
    clip*: Rect
    # image: Image
    # target: Target


var screen*: gpu.Target

# proc cloneTexture*(): Texture = canvas.cloneTexture()
# proc loadColors*(src: openarray[uint32], fmt: suffer.ColorFormat) = canvas.loadColors(src, fmt)
# proc loadColors8*(src: openarray[uint8], pal: openarray[Color]) = canvas.loadColors8(src, pal)
# proc loadColors8*(src: openarray[uint8]) = canvas.loadColors8(src)
# proc setBlend*(blend: suffer.BlendMode) = canvas.setBlend(blend)
# proc setAlpha*[T](alpha: T) = canvas.setAlpha(alpha)
# proc setColor*(c: Color) = canvas.setColor(c)
# proc setClip*(r: suffer.Rect) = canvas.setClip(r)
# proc reset*() = canvas.reset()
# proc clear*(c: Color) = canvas.clear(c)
proc clear*() = screen.clear()
# proc getColor*(x: int, y: int): Color = canvas.getColor(x, y)
# proc setColor*(c: Color, x: int, y: int) = canvas.setColor(c, x, y)
# proc copyColors*(src: Texture, x, y: int, sub: suffer.Rect, sx, sy: float=1.0) = canvas.copyColors(src, x, y, sub, sx, sy)
# proc copyColors*(src: Texture, x, y: int, sx, sy: float=1.0) = canvas.copyColors(src, x, y, sx, sy)
# proc noise*(seed: uint, low, high: int, grey: bool) = canvas.noise(seed, low, high, grey)
# proc floodFill*(c: Color, x, y: int) = canvas.floodFill(c, x, y)
# proc drawColor*(c: Color, x, y: int) = canvas.drawColor(c, x, y)
# proc drawLine*(c: Color, x0, y0, x1, y1: int) = canvas.drawLine(c, x0, y0, x1, y1)
# proc drawRect*(c: Color, x, y, w, h: int) = canvas.drawRect(c, x, y, w, h)
# proc drawBox*(c: Color, x, y, w, h: int) = canvas.drawBox(c, x, y, w, h)
# proc drawCircle*(c: Color, x, y, r: int) = canvas.drawCircle(c, x, y, r)
# proc drawRing*(c: Color, x, y, r: int) = canvas.drawRing(c, x, y, r)
# proc drawText*(font: Font, c: Color, txt: string, x, y: int, width: int=0) = canvas.drawText(font, c, txt, x, y, width)
# proc drawText*(c: Color, txt: string, x, y: int, width: int=0) = canvas.drawText(DEFAULT_FONT, c, txt, x, y, width)
# proc drawTexture*(src: Texture, x, y: int, sub: suffer.Rect, t: Transform) = canvas.drawTexture(src, x, y, sub, t)
# proc drawTexture*(src: Texture, x, y: int, sub: suffer.Rect) = canvas.drawTexture(src, x, y, sub)
# proc drawTexture*(src: Texture, x, y: int, t: Transform) = canvas.drawTexture(src, x, y, t)
# proc drawTexture*(src: Texture, x, y: int) = canvas.drawTexture(src, x, y)












proc newTexture*(w, h: int): Texture = discard

proc newTextureFile*(filename: string): Texture = discard

proc newTextureString*(str: string): Texture = discard

proc cloneTexture*(src: Texture): Texture = discard

proc loadPixels*(tex: Texture, src: openarray[uint32]) = discard

proc loadPixels8*(tex: Texture, src: openarray[uint8], pal: openarray[Color]) = discard

proc loadPixels8*(tex: Texture, src: openarray[uint8]) = discard

proc setBlend*(tex: Texture, blend: BlendMode) = discard

proc setAlpha*[T](tex: Texture, alpha: T) = discard

proc setColor*(tex: Texture, c: Color) = discard

proc setClip*(tex: Texture, r: Rect) = discard

proc reset*(tex: Texture) = discard

proc resize*(tex: Texture, width, height: int) = discard

proc clear*(tex: Texture, c: Color) = discard

proc getColor*(tex: Texture, x: int, y: int): Color = discard

proc setColor*(tex: Texture, c: Color, x: int, y: int) = discard

proc copyPixels*(tex, src: Texture, x, y: int, sub: Rect, sx, sy: float=1.0) = discard

proc copyPixels*(tex, src: Texture, x, y: int, sx, sy: float=1.0) = discard

proc noise*(tex: Texture, seed: uint, low, high: int, grey: bool) = discard

proc floodFill*(tex: Texture, c: Color, x, y: int) = discard

proc drawColor*(tex: Texture, c: Color, x, y: int) = discard

proc drawLine*(tex: Texture, c: Color, x0, y0, x1, y1: int) = discard

proc drawRect*(tex: Texture, c: Color, x, y, w, h: int) = discard

proc drawBox*(tex: Texture, c: Color, x, y, w, h: int) = discard

proc drawCircle*(tex: Texture, c: Color, x, y, r: int) = discard

proc drawRing*(tex: Texture, c: Color, x, y, r: int) = discard

proc drawTexture*(tex: Texture, src: Texture, x, y: int, sub: Rect, t: Transform) = discard

proc drawTexture*(tex: Texture, src: Texture, x, y: int, sub: Rect) = discard

proc drawTexture*(tex: Texture, src: Texture, x, y: int, t: Transform) = discard

proc drawTexture*(tex: Texture, src: Texture, x, y: int) = discard

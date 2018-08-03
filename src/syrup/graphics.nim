##
##  Copyright (c) 2018 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import sdl2/sdl, sdl2/sdl_gpu as gpu
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
    image*: Image
    clip*: Rect


var screen*: Texture





template lerp[T](a, b, p: T): untyped =
  ((T(1) - p) * a + p * b)

converter toColor*(c: Color): sdl.Color =
  result.r = uint8(lerp(0.0, 256.0, c.r))
  result.g = uint8(lerp(0.0, 256.0, c.g))
  result.b = uint8(lerp(0.0, 256.0, c.b))
  result.a = uint8(lerp(0.0, 256.0, c.a))

proc finalizer(tex: Texture) =
  if not tex.isNil:
    gpu.freeImage(tex.image)

proc newTexture*(w, h: int): Texture =
  new result, finalizer
  result.image = gpu.createImage(uint16(w), uint16(h), Format.FORMAT_RGBA)
  discard result.image.loadTarget()

proc newTextureFile*(filename: string): Texture =
  new result, finalizer
  result.image = gpu.loadImage(filename)
  discard result.image.loadTarget()

proc cloneTexture*(src: Texture): Texture =
  new result, finalizer
  result = src
  result.image = src.image.copyImage()

proc loadPixels*(tex: Texture, src: openarray[uint32]) =
  let data = cast[ptr cuchar](unsafeAddr src[0])
  tex.image.updateImageBytes(nil, data, cint(tex.image.w))

# proc loadPixels8*(tex: Texture, src: openarray[uint8], pal: openarray[Color]) =
#   let sz = int(tex.image.w * tex.image.h - 1)
#   var pixels = newSeq[uint32](sz)
#   for i in countdown(sz, 0):
#     pixels[i] = uint32(pal[src[i]])
#   tex.loadPixels(pixels)

proc loadPixels8*(tex: Texture, src: openarray[uint8]) =
  let sz = int(tex.image.w * tex.image.h - 1)
  var pixels = newSeq[uint32](sz)
  for i in countdown(sz, 0):
    pixels[i] = 0xffffff00'u32 and uint32(src[i])
  tex.loadPixels(pixels)

proc setBlend*(tex: Texture, blend: gpu.BlendMode) = discard

proc setAlpha*[T](tex: Texture, alpha: T) = discard

proc setColor*(tex: Texture, c: Color) =
  tex.image.setColor(c)

proc setClip*(tex: Texture, r: Rect) = discard

proc reset*(tex: Texture) = discard

proc resize*(tex: Texture, width, height: int) = discard

proc clear*(tex: Texture, c: Color) =
  tex.image.target.clearColor(c)

proc clear*(tex: Texture) =
  tex.image.target.clear()

proc getColor*(tex: Texture, x: int, y: int): Color = discard

proc setColor*(tex: Texture, c: Color, x: int, y: int) = discard

proc copyPixels*(tex, src: Texture, x, y: int, sub: Rect, sx, sy: float=1.0) = discard

proc copyPixels*(tex, src: Texture, x, y: int, sx, sy: float=1.0) = discard

proc noise*(tex: Texture, seed: uint, low, high: int, grey: bool) = discard

proc floodFill*(tex: Texture, c: Color, x, y: int) = discard


proc drawPixel*(tex: Texture, c: Color, x, y: int) =
  tex.image.target.pixel(float(x), float(y), c)

proc drawLine*(tex: Texture, c: Color, x0, y0, x1, y1: int) =
  tex.image.target.line(float(x0), float(y0), float(x1), float(y1), c)

proc drawRect*(tex: Texture, c: Color, x, y, w, h: int) =
  tex.image.target.rectangleFilled(
    float(x), float(y), float(x + w), float(y + h), c
  )

proc drawBox*(tex: Texture, c: Color, x, y, w, h: int) =
  tex.image.target.rectangle(
    float(x), float(y), float(x + w), float(y + h), c
  )

proc drawCircle*(tex: Texture, c: Color, x, y, r: int) =
  tex.image.target.circleFilled(float(x), float(y), float(r), c)

proc drawRing*(tex: Texture, c: Color, x, y, r: int) =
  tex.image.target.circle(float(x), float(y), float(r), c)


proc drawTexture*(tex: Texture, src: Texture, x, y: int, sub: Rect, t: Transform) =
  # src.image.blitTransformX(sub, tex.image.target, float(x), float(y), t.ox, t.oy, t.r, t.sx, t.sy)
  src.image.blitTransformX(nil, tex.image.target, float(x), float(y), t.ox, t.oy, t.r, t.sx, t.sy)

proc drawTexture*(tex: Texture, src: Texture, x, y: int, sub: Rect) = discard

proc drawTexture*(tex: Texture, src: Texture, x, y: int, t: Transform) = discard

proc drawTexture*(tex: Texture, src: Texture, x, y: int) = discard











# proc cloneTexture*(): Texture = canvas.cloneTexture()
# proc loadColors*(src: openarray[uint32], fmt: suffer.ColorFormat) = canvas.loadColors(src, fmt)
# proc loadColors8*(src: openarray[uint8], pal: openarray[Color]) = canvas.loadColors8(src, pal)
# proc loadColors8*(src: openarray[uint8]) = canvas.loadColors8(src)
# proc setBlend*(blend: suffer.BlendMode) = canvas.setBlend(blend)
# proc setAlpha*[T](alpha: T) = canvas.setAlpha(alpha)
# proc setColor*(c: Color) = canvas.setColor(c)
# proc setClip*(r: suffer.Rect) = canvas.setClip(r)
# proc reset*() = canvas.reset()
proc clear*(c: Color) = screen.clear(c)
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

##
##  Copyright (c) 2018 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import sdl2/sdl, sdl2/sdl_gpu as gpu
import math

type
  ColorFormat* {.pure.} = enum
    ## the different pixel formats supported
    BGRA
    RGBA
    ARGB
    ABGR

  DrawFlags {.pure.} = enum
    CLEAN
    DIRTY

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
    flags: set[DrawFlags]
    image*: Image
    clip*: Rect
    color*: Color

var screen*: Texture

template lerp[T](a, b, p: T): untyped =
  ((T(1) - p) * a + p * b)

template dirty(tex: Texture): untyped =
  tex.flags.incl {DrawFlags.DIRTY}
  tex.flags.excl {DrawFlags.CLEAN}

template clean(tex: Texture): untyped =
  tex.flags.incl {DrawFlags.CLEAN}
  tex.flags.excl {DrawFlags.DIRTY}

converter toColor(c: Color): sdl.Color =
  result.r = uint8(lerp(0.0, 255.0, c.r))
  result.g = uint8(lerp(0.0, 255.0, c.g))
  result.b = uint8(lerp(0.0, 255.0, c.b))
  result.a = uint8(lerp(0.0, 255.0, c.a))

converter toRect(r: Rect): gpu.Rect =
  result.x = cfloat(r.x)
  result.y = cfloat(r.y)
  result.w = cfloat(r.w)
  result.h = cfloat(r.h)

converter toUInt32(c: Color): uint32 =
  let c = c.toColor()
  uint32(c.r shr  0) and uint32(c.g shr  8) and
    uint32(c.b shr 16) and uint32(c.a shr 24)


proc finalizer(tex: Texture) =
  if not tex.isNil:
    gpu.freeImage(tex.image)

proc newTexture*(w, h: int): Texture =
  new result, finalizer
  result.image = gpu.createImage(uint16(w), uint16(h), Format.FORMAT_RGBA)
  result.flags = {DrawFlags.DIRTY}
  discard result.image.loadTarget()

proc newTextureFile*(filename: string): Texture =
  new result, finalizer
  result.image = gpu.loadImage(filename)
  result.flags = {DrawFlags.DIRTY}
  discard result.image.loadTarget()

proc cloneTexture*(src: Texture): Texture =
  new result, finalizer
  result = src
  result.image = src.image.copyImage()

proc loadPixels*(tex: Texture, src: openarray[uint32], fmt: ColorFormat) =
  var sr, sg, sb, sa: int
  var data = newSeq[cuchar](tex.image.w * tex.image.h)
  case fmt:
    of ColorFormat.BGRA: (sr, sg, sb, sa) = (16,  8,  0, 24)
    of ColorFormat.RGBA: (sr, sg, sb, sa) = ( 0,  8, 16, 24)
    of ColorFormat.ARGB: (sr, sg, sb, sa) = ( 8, 16, 24,  0)
    of ColorFormat.ABGR: (sr, sg, sb, sa) = (24, 16,  8,  0)

  for i in countdown(data.len - 1, 0):
    data[i * 4 + 0] = cuchar((src[i] shr sr) and 0xff)
    data[i * 4 + 1] = cuchar((src[i] shr sg) and 0xff)
    data[i * 4 + 2] = cuchar((src[i] shr sb) and 0xff)
    data[i * 4 + 3] = cuchar((src[i] shr sa) and 0xff)

  tex.image.updateImageBytes(nil, addr data[0], cint(tex.image.w))

proc loadPixels8*(tex: Texture, src: openarray[uint8], pal: openarray[Color]) =
  var data = newSeq[uint32](tex.image.w * tex.image.h - 1)
  for i in countdown(data.len, 0):
    data[i] = uint32(pal[src[i]])
  tex.loadPixels(data, ColorFormat.RGBA)

proc loadPixels8*(tex: Texture, src: openarray[uint8]) =
  let sz = int(tex.image.w * tex.image.h - 1)
  var pixels = newSeq[uint32](sz)
  for i in countdown(sz, 0):
    pixels[i] = 0xffffff00'u32 and uint32(src[i])
  tex.loadPixels(pixels, ColorFormat.RGBA)

# proc setBlend*(tex: Texture, blend: gpu.BlendMode) = discard

# proc setAlpha*[T](tex: Texture, alpha: T) = discard

proc setColor*(tex: Texture, c: Color) =
  tex.image.setColor(c)
  tex.color = c

proc setClip*(tex: Texture, r: Rect) =
  tex.setClip(r)
  tex.clip = r

# proc reset*(tex: Texture) = tex.clean()

# proc resize*(tex: Texture, width, height: int) = tex.clean()

proc clear*(tex: Texture, c: Color) =
  if DrawFlags.DIRTY in tex.flags:
    tex.image.target.clearColor(c)
    tex.clean()

proc clear*(tex: Texture) =
  if DrawFlags.DIRTY in tex.flags:
    tex.image.target.clear()
    tex.clean()

# proc getColor*(tex: Texture, x: int, y: int): Color = discard

# proc setColor*(tex: Texture, c: Color, x: int, y: int) = tex.dirty()

# proc copyPixels*(tex, src: Texture, x, y: int, sub: Rect, sx, sy: float=1.0) = tex.dirty()

# proc copyPixels*(tex, src: Texture, x, y: int, sx, sy: float=1.0) = tex.dirty()

# proc noise*(tex: Texture, seed: uint, low, high: int, grey: bool) = tex.dirty()

# proc floodFill*(tex: Texture, c: Color, x, y: int) = tex.dirty()

proc drawPixel*(tex: Texture, c: Color, x, y: int) =
  tex.image.target.pixel(float(x), float(y), c)
  tex.dirty()

proc drawLine*(tex: Texture, c: Color, x0, y0, x1, y1: int) =
  tex.image.target.line(float(x0), float(y0), float(x1), float(y1), c)
  tex.dirty()

proc drawRect*(tex: Texture, c: Color, x, y, w, h: int) =
  tex.image.target.rectangleFilled(
    float(x), float(y), float(x + w), float(y + h), c
  )
  tex.dirty()

proc drawBox*(tex: Texture, c: Color, x, y, w, h: int) =
  tex.image.target.rectangle(
    float(x), float(y), float(x + w), float(y + h), c
  )
  tex.dirty()

proc drawCircle*(tex: Texture, c: Color, x, y, r: int) =
  tex.image.target.circleFilled(float(x), float(y), float(r), c)
  tex.dirty()

proc drawRing*(tex: Texture, c: Color, x, y, r: int) =
  tex.image.target.circle(float(x), float(y), float(r), c)
  tex.dirty()

proc drawTexture*(tex: Texture, src: Texture, x, y: int, sub: Rect) =
  var r = gpu.Rect(sub)
  src.image.blit(addr r, tex.image.target, float(x), float(y))

proc drawTexture*(tex: Texture, src: Texture, x, y: int, t: Transform) =
  var (x, y, t) = (float(x), float(y), t)
  # move rotation value into 0..PI2 range
  t.r = ((t.r mod math.TAU) + math.TAU) mod math.TAU
  # apply offset
  (x, y) = (x - t.ox, y - t.oy)
  src.image.blitRotate(nil, tex.image.target, float(x), float(y), t.r)

proc drawTexture*(tex: Texture, src: Texture, x, y: int) =
  src.image.blit(nil, tex.image.target, float(x), float(y))

proc drawTexture*(tex: Texture, src: Texture, x, y: int, sub: Rect, t: Transform) =
  var (x, y, t, r) = (float(x), float(y), t, gpu.Rect(sub))
  # move rotation value into 0..PI2 range
  t.r = ((t.r mod math.TAU) + math.TAU) mod math.TAU
  # Not rotated or scaled? apply offset and draw basic
  if t.r == 0:
    (x, y) = (x - t.ox, y - t.oy)
    if t.sx == 1 and t.sy == 1:
      src.image.blit(addr r, tex.image.target, x, y)
    else:
      src.image.blitScale(addr r, tex.image.target, x, y, t.sx, t.sy)
  else:
    src.image.blitTransformX(unsafeAddr(r), tex.image.target, float(x), float(y), t.ox, t.oy, t.r, t.sx, t.sy)










proc cloneTexture*(): Texture =
  screen.cloneTexture()

proc loadPixels*(src: openarray[uint32], fmt: ColorFormat) =
  screen.loadPixels(src, fmt)

proc loadPixels8*(src: openarray[uint8], pal: openarray[Color]) =
  screen.loadPixels8(src, pal)

proc loadPixels8*(src: openarray[uint8]) =
  screen.loadPixels8(src)

# proc setBlend*(blend: suffer.BlendMode) = screen.setBlend(blend)

# proc setAlpha*[T](alpha: T) = screen.setAlpha(alpha)

proc setColor*(c: Color) =
  screen.setColor(c)

proc setClip*(r: Rect) =
  screen.setClip(r)

# proc reset*() = screen.reset()

proc clear*(c: Color) =
  screen.clear(c)

proc clear*() =
  screen.clear()

# proc getColor*(x: int, y: int): Color = screen.getColor(x, y)

# proc setColor*(c: Color, x: int, y: int) = screen.setColor(c, x, y)

# proc copyColors*(src: Texture, x, y: int, sub: suffer.Rect, sx, sy: float=1.0) = screen.copyColors(src, x, y, sub, sx, sy)

# proc copyColors*(src: Texture, x, y: int, sx, sy: float=1.0) = screen.copyColors(src, x, y, sx, sy)

# proc noise*(seed: uint, low, high: int, grey: bool) = screen.noise(seed, low, high, grey)

# proc floodFill*(c: Color, x, y: int) = screen.floodFill(c, x, y)

proc drawPixel*(c: Color, x, y: int) =
  screen.drawPixel(c, x, y)

proc drawLine*(c: Color, x0, y0, x1, y1: int) =
  screen.drawLine(c, x0, y0, x1, y1)

proc drawRect*(c: Color, x, y, w, h: int) =
  screen.drawRect(c, x, y, w, h)

proc drawBox*(c: Color, x, y, w, h: int) =
  screen.drawBox(c, x, y, w, h)

proc drawCircle*(c: Color, x, y, r: int) =
  screen.drawCircle(c, x, y, r)

proc drawRing*(c: Color, x, y, r: int) =
  screen.drawRing(c, x, y, r)

proc drawTexture*(src: Texture, x, y: int, sub: Rect, t: Transform) =
  screen.drawTexture(src, x, y, sub, t)

proc drawTexture*(src: Texture, x, y: int, sub: Rect) =
  screen.drawTexture(src, x, y, sub)

proc drawTexture*(src: Texture, x, y: int, t: Transform) =
  screen.drawTexture(src, x, y, t)

proc drawTexture*(src: Texture, x, y: int) =
  screen.drawTexture(src, x, y)

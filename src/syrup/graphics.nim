##
##  Copyright (c) 2018 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import math, strutils
import sdl2/sdl, sdl2/sdl_gpu as gpu

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

proc color*(r, g, b, a: float): Color
  ## @
proc color*(r, g, b: float): Color
  ## @
proc color*(c: string): Color
  ## @
proc rect*(x, y, w, h: int=0): Rect
  ## @
proc transform*(ox, oy, r: float=0.0, sx, sy: float=1.0): Transform
  ## @
proc newTexture*(w, h: int): Texture
  ## @
proc newTexture*(filename: string): Texture
  ## @
proc width*(tex: Texture): int
  ## @
proc height*(tex: Texture): int
  ## @
proc cloneTexture*(src: Texture): Texture
  ## @
proc loadPixels*(tex: Texture, src: openarray[uint32], fmt: ColorFormat)
  ## @
proc loadPixels8*(tex: Texture, src: openarray[uint8], pal: openarray[Color])
  ## @
proc loadPixels8*(tex: Texture, src: openarray[uint8])
  ## @
# proc setBlend*(tex: Texture, blend: gpu.BlendMode)
## @
# proc setAlpha*[T](tex: Texture, alpha: T)
## @
proc setColor*(tex: Texture, c: Color)
  ## @
proc setClip*(tex: Texture, r: Rect)
  ## @
proc resetTexture*(tex: Texture)
  ## @
# proc resize*(tex: Texture, width, height: int)
## @
proc clear*(tex: Texture, c: Color)
  ## @
proc clear*(tex: Texture)
## @
# proc getColor*(tex: Texture, x: int, y: int): Color
## @
# proc setColor*(tex: Texture, c: Color, x: int, y: int)
## @
# proc copyPixels*(tex, src: Texture, x, y: int, sub: Rect, sx, sy: float=1.0)
## @
# proc copyPixels*(tex, src: Texture, x, y: int, sx, sy: float=1.0)
## @
# proc noise*(tex: Texture, seed: uint, low, high: int, grey: bool)
## @
# proc floodFill*(tex: Texture, c: Color, x, y: int)
## @
proc drawPixel*(tex: Texture, c: Color, x, y: int)
  ## @
proc drawLine*(tex: Texture, c: Color, x0, y0, x1, y1: int)
  ## @
proc drawRect*(tex: Texture, c: Color, x, y, w, h: int)
  ## @
proc drawBox*(tex: Texture, c: Color, x, y, w, h: int)
  ## @
proc drawCircle*(tex: Texture, c: Color, x, y, r: int)
  ## @
proc drawRing*(tex: Texture, c: Color, x, y, r: int)
  ## @
proc drawTexture*(tex: Texture, src: Texture, x, y: int, sub: Rect)
  ## @
proc drawTexture*(tex: Texture, src: Texture, x, y: int, t: Transform)
  ## @
proc drawTexture*(tex: Texture, src: Texture, x, y: int)
  ## @
proc drawTexture*(tex: Texture, src: Texture, x, y: int, sub: Rect, t: Transform)
  ## @

var
  screen*: Texture

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

proc color*(r, g, b, a: float): Color =
  (r, g, b, a)

proc color*(r, g, b: float): Color =
  (r, g, b, 1.0)

proc color*(c: string): Color =
  let hex = parseHexInt(c)
  if hex >= 0xffffff:
    result.r = lerp(0.0, 255.0, float((hex shr 24) and 0xff))
    result.g = lerp(0.0, 255.0, float((hex shr 16) and 0xff))
    result.b = lerp(0.0, 255.0, float((hex shr  8) and 0xff))
    result.a = lerp(0.0, 255.0, float((hex shr  0) and 0xff))
  else:
    result.r = lerp(0.0, 255.0, float((hex shr 16) and 0xff))
    result.g = lerp(0.0, 255.0, float((hex shr  8) and 0xff))
    result.b = lerp(0.0, 255.0, float((hex shr  0) and 0xff))
    result.a = 1.0

proc rect*(x, y, w, h: int=0): Rect =
  (x: x, y: y, w: w, h: h)

proc transform*(ox, oy, r: float=0.0, sx, sy: float=1.0): Transform =
  (ox: ox, oy: oy, r: r, sx: sx, sy: sy)

proc finalizer(tex: Texture) =
  if not tex.isNil:
    gpu.freeImage(tex.image)

proc newTexture*(w, h: int): Texture =
  new result, finalizer
  result.image = gpu.createImage(uint16(w), uint16(h), Format.FORMAT_RGBA)
  result.flags = {DrawFlags.DIRTY}
  discard result.image.loadTarget
  result.resetTexture()

proc newTexture*(filename: string): Texture =
  new result, finalizer
  result.image = gpu.loadImage(filename)
  result.flags = {DrawFlags.DIRTY}
  discard result.image.loadTarget()
  result.resetTexture()

proc width*(tex: Texture): int =
  int(tex.image.w)

proc height*(tex: Texture): int =
  int(tex.image.h)

proc cloneTexture*(src: Texture): Texture =
  new result, finalizer
  result = src
  result.image = src.image.copyImage()

proc loadPixels*(tex: Texture, src: openarray[uint32], fmt: ColorFormat) =
  var sr, sg, sb, sa: int
  var data = newSeq[cuchar](tex.image.w * tex.image.h * 4)
  case fmt:
    of ColorFormat.BGRA: (sr, sg, sb, sa) = (16,  8,  0, 24)
    of ColorFormat.RGBA: (sr, sg, sb, sa) = ( 0,  8, 16, 24)
    of ColorFormat.ARGB: (sr, sg, sb, sa) = ( 8, 16, 24,  0)
    of ColorFormat.ABGR: (sr, sg, sb, sa) = (24, 16,  8,  0)

  for i in 0 ..< src.len:
    data[i * 4 + 0] = cuchar((src[i] shr sr) and 0xff)
    data[i * 4 + 1] = cuchar((src[i] shr sg) and 0xff)
    data[i * 4 + 2] = cuchar((src[i] shr sb) and 0xff)
    data[i * 4 + 3] = cuchar((src[i] shr sa) and 0xff)

  tex.image.updateImageBytes(
    nil, addr data[0],
    cint(tex.image.w * 4)
  )

proc loadPixels8*(tex: Texture, src: openarray[uint8], pal: openarray[Color]) =
  var data = newSeq[cuchar](tex.image.w * tex.image.h * 4)
  for i in 0 ..< src.len:
    let c = sdl.Color(pal[src[i]])
    data[i * 4 + 0] = cuchar(c.r)
    data[i * 4 + 1] = cuchar(c.g)
    data[i * 4 + 2] = cuchar(c.b)
    data[i * 4 + 3] = cuchar(c.a)

  tex.image.updateImageBytes(
    nil, cast[ptr cuchar](unsafeAddr data[0]),
    cint(tex.image.w * 4)
  )

proc loadPixels8*(tex: Texture, src: openarray[uint8]) =
  var data = newSeq[cuchar](tex.image.w * tex.image.h * 4)
  for i in 0 ..< src.len:
    data[i * 4 + 0] = cuchar(0xff)
    data[i * 4 + 1] = cuchar(0xff)
    data[i * 4 + 2] = cuchar(0xff)
    data[i * 4 + 3] = cuchar(src[i])

  tex.image.updateImageBytes(
    nil, cast[ptr cuchar](addr data[0]),
    cint(tex.image.w * 4)
  )

# proc setBlend*(tex: Texture, blend: gpu.BlendMode) = discard

# proc setAlpha*[T](tex: Texture, alpha: T) = discard

proc setColor*(tex: Texture, c: Color) =
  tex.image.setColor(c)
  tex.color = c

proc setClip*(tex: Texture, r: Rect) =
  discard tex.image.target.setClipRect(r)
  tex.clip = r

proc resetTexture*(tex: Texture) =
  tex.image.target.unsetTargetColor()
  tex.image.target.unsetClip()
  # tex.image.setSnapMode(Snap.SNAP_NONE)
  tex.image.setImageFilter(Filter.FILTER_NEAREST)
  tex.image.setWrapMode(Wrap.WRAP_NONE, Wrap.WRAP_NONE)

  tex.clip = (0, 0, int(tex.image.w), int(tex.image.h))

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
  tex.dirty()

proc drawTexture*(tex: Texture, src: Texture, x, y: int, t: Transform) =
  var (x, y, t) = (float(x), float(y), t)
  # move rotation value into 0..PI2 range
  t.r = ((t.r mod math.TAU) + math.TAU) mod math.TAU
  # Not rotated or scaled? apply offset and draw basic
  if t.r == 0:
    (x, y) = (x - t.ox, y - t.oy)
    if t.sx == 1 and t.sy == 1:
      src.image.blit(nil, tex.image.target, x, y)
    else:
      src.image.blitScale(nil, tex.image.target, x, y, t.sx, t.sy)
  else:
    src.image.blitTransformX(nil, tex.image.target, float(x), float(y), t.ox, t.oy, t.r, t.sx, t.sy)

  tex.dirty()

proc drawTexture*(tex: Texture, src: Texture, x, y: int) =
  src.image.blit(nil, tex.image.target, float(x), float(y))
  tex.dirty()

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
  tex.dirty()

proc width*(): int =
  int(screen.image.w)

proc height*(): int =
  int(screen.image.h)

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

proc setLineThickness*(thickness: int) =
  discard gpu.setLineThickness(cfloat(thickness))

proc getLineThickness*(): int =
  int(gpu.getLineThickness())

proc resetTexture*() =
  screen.resetTexture()

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

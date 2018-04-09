#  Copyright (c) 2017 emekoi
#
#  This library is free software; you can redistribute it and/or modify it
#  under the terms of the MIT license. See LICENSE for details.
#

{.deadCodeElim: on, optimization: speed.}
{.compile: "suffer/ttf_impl.c".}

when defined(Posix) and not defined(haiku):
  {.passl: "-lm".}

import texture, gl


type
  FontError* = object of Exception

  stbtt_fontinfo = object

  ttf_Font = ref object
    font*: stbtt_fontinfo
    fontData*: pointer
    ptsize*: cfloat
    scale*: cfloat
    baseline*: cint
  
  Font* = ref ptr ttf_Font
    ## a reference to the actual font object

proc newFont*(data: seq[byte], ptsize: float): Font
  ## attemtpts to create a font from a sequence of bytes
proc newFontFile*(filename: string, ptsize: float): Font
  ## loads a font from a file
proc newFontString*(data: string, ptsize: float): Font
  ## creates a font from a string
proc setSize*(font: Font, ptsize: float)
  ## sets the font point size
proc getHeight*(font: Font): int
  ## gets the height of the font
proc getWidth*(font: Font, txt: string): int
  ## gets the width of `str` rendered in the font
proc render*(font: Font, txt: string): Texture
  ## creates a new Buffer with `txt` rendered on it using `font`

{.push cdecl, importc.}
proc ttf_new(data: pointer, len: cint): ptr ttf_Font
proc ttf_destroy(self: ptr ttf_Font)
proc ttf_ptsize(self: ptr ttf_Font, ptsize: cfloat)
proc ttf_height(self: ptr ttf_Font): cint
proc ttf_width(self: ptr ttf_Font, str: cstring): cint
proc ttf_render(self: ptr ttf_Font,
  str: cstring, w, h: var cint): pointer
{.pop.}

converter toCFont(font: Font): ptr ttf_Font = font[]

proc finalizer(font: Font) =
  if font != nil: ttf_destroy(font)
  
proc newFont*(data: seq[byte], ptsize: float): Font =
  new result, finalizer
  result[] = ttf_new(data[0].unsafeAddr, data.len.cint)
  if result == nil: raise newException(FontError, "unable to load font")
  result.setSize(ptsize)
    
proc newFontString*(data: string, ptsize: float): Font =
  new result, finalizer
  result[] = ttf_new(data[0].unsafeAddr, data.len.cint)
  if result == nil: raise newException(FontError, "unable to load font")
  result.setSize(ptsize)

proc newFontFile*(filename: string, ptsize: float): Font =
  let data = readFile(filename)
  result = newFontString(data, ptsize)

proc setSize*(font: Font, ptsize: float) =
  ttf_ptsize(font, ptsize.cfloat)

proc getHeight*(font: Font): int =
  return ttf_height(font).int

proc getWidth*(font: Font, txt: string): int =
  return ttf_width(font, txt.cstring).int
  
proc render*(font: Font, txt: string): Texture =
  var
    w, h: cint = 0
    txt = txt
  if txt == nil or txt.len == 0: txt = " "
  let bitmap = ttf_render(font, txt.cstring, w, h);
  if bitmap == nil:
    raise newException(FontError, "could not render text")
  # Load bitmap and free intermediate 8bit bitmap
  var pixels = newSeq[byte](w * h)
  copyMem(pixels[0].addr, bitmap, w * h * sizeof(byte))
  
  # we need to load the a bitmap into opengl :(
  result = newTexture(w, h)
  result.bindTexture()
  gl.texImage2D(TexImageTarget.TEXTURE_2D, 0, TextureInternalFormat.RGBA, w, h,
        PixelDataFormat.RGBA, PixelDataType.UNSIGNED_BYTE, pixels)
  gl.generateMipMap(MipmapTarget.TEXTURE_2D)
  result.unbindTexture()
  # result.loadPixels8(pixels)
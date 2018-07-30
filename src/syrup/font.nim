##
##  Copyright (c) 2018 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

{.compile: "private/ttf_impl.c".}

import embed

type
  stbtt_fontinfo = object

  ttf_Font = ptr object
    font: stbtt_fontinfo
    fontData: pointer
    ptsize*: cfloat
    scale*: cfloat
    baseline*: cint
  
  Font* = ref ttf_Font

proc newFontDefault*(ptsize: float): Font
  ## returns a copy of the default embeded font with the givern size
proc newFontDefault*(): Font
  ## returns a copy of the default embeded font
proc newFont*(data: seq[uint8], ptsize: float): Font
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
proc render*(font: Font, txt: string): seq[uint8]
  ## creates a new Buffer with `txt` rendered on it using `font`

{.push cdecl, importc.}
proc ttf_new(data: pointer, len: cint): ttf_Font
proc ttf_destroy(self: ttf_Font)
proc ttf_ptsize(self: ttf_Font, ptsize: cfloat)
proc ttf_height(self: ttf_Font): cint
proc ttf_width(self: ttf_Font, str: cstring): cint
proc ttf_render(self: ttf_Font, bitmap: ptr uint8, str: cstring, w, h: var cint)
{.pop.}

converter toCFont(font: Font): ttf_Font = font[]

proc finalizer(font: Font) =
  if font != nil: ttf_destroy(font)

let DEFAULT_FONT = newFontString(DEFAULT_FONT_DATA, DEFAULT_FONT_SIZE)

proc newFontDefault*(ptsize: float): Font =
  newFontString(DEFAULT_FONT_DATA, ptsize)

proc newFontDefault*(): Font =
  DEFAULT_FONT

proc newFont*(data: seq[uint8], ptsize: float): Font =
  new result, finalizer
  result[] = ttf_new(data[0].unsafeAddr, data.len.cint)
  if result == nil: raise newException(Exception, "unable to load font")
  result.setSize(ptsize)
    
proc newFontString*(data: string, ptsize: float): Font =
  new result, finalizer
  result[] = ttf_new(data[0].unsafeAddr, data.len.cint)
  if result == nil: raise newException(Exception, "unable to load font")
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

proc render*(font: Font, txt: string): seq[uint8] =
  var
    w, h: cint = 0
    txt = txt
  if txt.isNil or txt.len == 0: txt = " "
  ttf_render(font, nil, txt.cstring, w, h)
  result = newSeq[uint8](w * h)
  ttf_render(font, result[0].addr, txt.cstring, w, h)
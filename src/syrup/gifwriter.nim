##
##  Copyright (c) 2018 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##


import math

{.passl: "-lm".}
{.compile: "private/jo_gif.c".}

type jo_gif_t = object
  fp: ptr FILE
  palette: array[0x00000300, cuchar]
  width: cshort
  height: cshort
  repeat: cshort
  numColors: cint
  palSize: cint
  frame: cint

{.push cdecl, importc.}
##  width/height | the same for every frame
##  repeat       | 0 = loop forever, 1 = loop once, etc...
##  palSize		   | must be power of 2 - 1. so, 255 not 256.
proc jo_gif_start(filename: cstring; width: cshort; height: cshort; repeat: cshort;
                  palSize: cint): jo_gif_t

##  gif			     | the state (returned from jo_gif_start)
##  rgba         | the pixels
##  delayCsec    | amount of time in between frames (in centiseconds)
##  localPalette | true if you want a unique palette generated for this frame (does not effect future frames)
proc jo_gif_frame(gif: ptr jo_gif_t; rgba: ptr cuchar; delayCsec: cshort;
                  localPalette: cint)

##  gif          | the state (returned from jo_gif_start)
proc jo_gif_end(gif: ptr jo_gif_t)
{.pop.}

type
  GifState* {.pure.} = enum
    INIT,
    ACTIVE,
    CLOSED

  Gif* = ref object
    state*: GifState
    gif: jo_gif_t
    delay*: float
    delayErr: float
    buf: seq[uint8]
    w, h: int
    expectedFrameSize: int

proc close*(gif: Gif)

proc finalize*(gif: Gif) =
  if gif.state == GifState.ACTIVE:
    gif.close()

proc newGif*(filename: string, width, height: int, fps=30.0, colors=63, loop=true): Gif =
  new result, finalize
  result.state = GifState.INIT

  result.gif = jo_gif_start(
    cstring(filename), cshort(width), cshort(height),
    cshort(if loop: 0 else: 1), cint(colors))
  result.delay = 1.0 / fps
  result.buf = newSeq[uint8](width * height * 4)
  result.w = width
  result.h = height
  result.expectedFrameSize = width * height * 4

  result.state = GifState.ACTIVE

proc close*(gif: Gif) =
  assert gif.state == GifState.ACTIVE, "gif already closed"
  gif.state = GifState.CLOSED
  jo_gif_end(addr gif.gif)

proc writeGif*(gif: Gif, pixels: pointer, delay=0.0, localPalette=false) =
  assert gif.state == GifState.ACTIVE, "can't write closed gif"

  var delay =
    if delay == 0.0:
      gif.delay
    else:
      delay

  # Convert delay to centiseconds and store error
  var
    n = delay + gif.delayErr
    c = floor(n * 100)
    d = c / 100
  gif.delayErr = n - d

  jo_gif_frame(
    addr gif.gif, cast[ptr cuchar](pixels),
    cshort(c), cint(localPalette))

proc checkedWrite[T](gif: Gif, pixels: T, delay: float, localPalette: bool) =
  var pixels = pixels
  assert pixels.len * pixels[0].sizeof == gif.expectedFrameSize
  gif.writeGif(addr pixels[0], delay, localPalette)

proc writeGif*(gif: Gif, pixels: seq[uint32], delay=0.0, localPalette=false) =
  checkedWrite[seq[uint32]](gif, pixels, delay, localPalette)

proc writeGif*(gif: Gif, pixels: seq[uint8], delay=0.0, localPalette=false) =
  checkedWrite[seq[uint8]](gif, pixels, delay, localPalette)

proc writeGif*(gif: Gif, pixels: seq[Pixel], delay=0.0, localPalette=false) =
  checkedWrite[seq[Pixel]](gif, pixels, delay, localPalette)

proc writeGif*(gif: Gif, buf: Buffer, delay=0.0, localPalette=false) =
  assert buf.w == gif.w and buf.h == gif.h,
    "bad buffer dimensions for gif object, expected " & $gif.w & "x" & $gif.h

  for i in 0..<(gif.w * gif.h):
    var n = i * 4
    gif.buf[n    ] = buf.pixels[i].rgba.r
    gif.buf[n + 1] = buf.pixels[i].rgba.g
    gif.buf[n + 2] = buf.pixels[i].rgba.b

  gif.writeGif(addr gif.buf[0], delay, localPalette)

#  Copyright (c) 2017 emekoi
#
#  This library is free software; you can redistribute it and/or modify it
#  under the terms of the MIT license. See LICENSE for details.
#

{.deadCodeElim: on, optimization: speed.}
{.compile: "private/stb_impl.c".}

when defined(Posix) and not defined(haiku):
  {.passl: "-lm".}

import shader, gl, embed

type
  TextureError* = object of Exception

  Color* = tuple
    r, g, b, a: float32

  BlendingMode = tuple
    src_factor, dst_factor: BlendFactor
    blend_equation: BlendEquationEnum
    aplha_mult: bool

  # BlendMode* {.pure.} = enum
  #   # (src_factor, dst_factor, blend_func) 
  #   ALPHA = (BlendFactor.ONE_MINUS_SRC_ALPHA, BlendFactor.ONE, BlendEquationEnum.FUNC_ADD, false)
  #   COLOR = ()
  #   ADD = (BlendFactor.ONE, BlendFactor.SRC_ALPHA, BlendEquationEnum.FUNC_ADD)
  #   SUBTRACT = ()
  #   MULTIPLY = ()
  #   LIGHTEN = (BlendFactor.ONE, BlendFactor.ONE, BlendEquationEnum.MAX, false)
  #   DARKEN = (BlendFactor.ONE, BlendFactor.ONE, BlendEquationEnum.MIN, false)
  #   SCREEN = ()

  # DrawMode* = object
  #   color*: Color
  #   alpha*: uint8
  #   blend*: BlendMode

  PixelFormat = enum
    RGB
    RGBA

  Texture* = ref object
    id: gl.TextureId
    width*, height*: int32
    slot*: uint32
    fmt: PixelFormat





#   let alpha = (s.rgba.a.int * m.alpha.int) shr 8
#   var s = s
#   if alpha <= 1: return
#   # Color
#   if m.color.word != RGB_MASK:
#     s.rgba.r = ((s.rgba.r.int * m.color.rgba.r.int) shr 8).uint8
#     s.rgba.g = ((s.rgba.g.int * m.color.rgba.g.int) shr 8).uint8
#     s.rgba.b = ((s.rgba.b.int * m.color.rgba.b.int) shr 8).uint8
#   # Blend
#   case m.blend
#   of BLEND_ALPHA:
#     discard
#   of BLEND_COLOR:
#     s = m.color
#   of BLEND_ADD:
#     s.rgba.r = min(d.rgba.r.int + s.rgba.r.int, 0xff).uint8
#     s.rgba.g = min(d.rgba.g.int + s.rgba.g.int, 0xff).uint8
#     s.rgba.b = min(d.rgba.b.int + s.rgba.b.int, 0xff).uint8
#   of BLEND_SUBTRACT:
#     s.rgba.r = min(d.rgba.r.int - s.rgba.r.int, 0).uint8
#     s.rgba.g = min(d.rgba.g.int - s.rgba.g.int, 0).uint8
#     s.rgba.b = min(d.rgba.b.int - s.rgba.b.int, 0).uint8
#   of BLEND_MULTIPLY:
#     s.rgba.r = ((s.rgba.r.int * d.rgba.r.int) shr 8).uint8
#     s.rgba.g = ((s.rgba.g.int * d.rgba.g.int) shr 8).uint8
#     s.rgba.b = ((s.rgba.b.int * d.rgba.b.int) shr 8).uint8
#   of BLEND_LIGHTEN:
#     s = if s.rgba.r.int + s.rgba.g.int + s.rgba.b.int >
#           d.rgba.r.int + d.rgba.g.int + d.rgba.b.int: s else: d[]
#   of BLEND_DARKEN:
#     s = if s.rgba.r.int + s.rgba.g.int + s.rgba.b.int <
#           d.rgba.r.int + d.rgba.g.int + d.rgba.b.int: s else: d[]
#   of BLEND_SCREEN:
#     s.rgba.r = (0xff - (((0xff - d.rgba.r.int) * (0xff - s.rgba.r.int)) shr 8)).uint8
#     s.rgba.g = (0xff - (((0xff - d.rgba.g.int) * (0xff - s.rgba.g.int)) shr 8)).uint8
#     s.rgba.b = (0xff - (((0xff - d.rgba.b.int) * (0xff - s.rgba.b.int)) shr 8)).uint8
#   of BLEND_DIFFERENCE:
#     s.rgba.r = abs(s.rgba.r.int - d.rgba.r.int).uint8
#     s.rgba.g = abs(s.rgba.g.int - d.rgba.g.int).uint8
#     s.rgba.b = abs(s.rgba.b.int - d.rgba.b.int).uint8
#   # Write
#   if alpha >= 254:
#     d[] = s
#   elif d.rgba.a >= 254'u8:
#     d.rgba.r = lerp(8, d.rgba.r.int, s.rgba.r.int, alpha).uint8
#     d.rgba.g = lerp(8, d.rgba.g.int, s.rgba.g.int, alpha).uint8
#     d.rgba.b = lerp(8, d.rgba.b.int, s.rgba.b.int, alpha).uint8
#   else:
#     let
#       a = 0xff - (((0xff - d.rgba.a.int) * (0xff - alpha)) shr 8)
#       z = (d.rgba.a.int * (0xff - alpha)) shr 8
#     d.rgba.r = div8Table[((d.rgba.r.int * z) shr 8) + ((s.rgba.r.int * alpha) shr 8)][a]
#     d.rgba.g = div8Table[((d.rgba.g.int * z) shr 8) + ((s.rgba.g.int * alpha) shr 8)][a]
#     d.rgba.b = div8Table[((d.rgba.b.int * z) shr 8) + ((s.rgba.b.int * alpha) shr 8)][a]
#     d.rgba.a = a.uint8








proc newTextureBlank*(width, height: int32, slot: uint32=0): Texture
proc newTextureFromFile*(filename: string, slot: uint32=0): Texture
proc newTextureFromString*(str: string, slot: uint32=0): Texture
proc bindTexture*(t: Texture)
proc unbindTexture*(t: Texture)

proc stbi_failure_reason_c(): cstring
  {.cdecl, importc: "stbi_failure_reason".}

proc stbi_failure_reason(): string =
  return $stbi_failure_reason_c()

{.push cdecl, importc.}
proc stbi_image_free(retval_from_stbi_load: pointer)
proc stbi_load_from_memory(
  buffer: ptr cuchar,
  len: cint,
  x, y, channels_in_file: var cint,
  desired_channels: cint
): ptr cuchar
proc stbi_load(
  filename: cstring,
  x, y, channels_in_file: var cint,
  desired_channels: cint
): ptr cuchar
{.pop.}

proc finalize(t: Texture) =
  t.unbindTexture()
  gl.deleteTexture(t.id)

proc newTextureBlank*(width, height: int32, slot: uint32=0): Texture =
  new(result, finalize)
  result.id = gl.genTexture()
  result.height = height
  result.width = width
  result.slot = slot
  result.fmt = PixelFormat.RGBA
 
# bind texture, load data, generate mipmaps, then unbind the texture and free the image data
proc loadTexture(t: Texture, data: pointer, bpp: cint) =
  t.bindTexture()
  t.fmt = if bpp == 4: PixelFormat.RGBA else: PixelFormat.RGB
  gl.texImage2D(TexImageTarget.TEXTURE_2D, 0, TextureInternalFormat.RGBA, t.width, t.height,
    succ(PixelDataFormat.RGB, ord(t.fmt)), PixelDataType.UNSIGNED_BYTE, data)
  gl.generateMipMap(MipmapTarget.TEXTURE_2D)
  stbi_image_free(data)
  t.unbindTexture()

# load data, pass it through stb and call load image on the data
proc newTextureFromFile*(filename: string, slot: uint32=0): Texture =
  var width, height, bpp: cint
  let pixelData = stbi_load(filename.cstring, width, height, bpp, 4)
  if pixelData == nil: raise newException(TextureError, stbi_failure_reason())
  result = newTextureBlank(width, height, slot)
  result.loadTexture(pixelData, bpp)

proc newTextureFromString*(str: string, slot: uint32=0): Texture =
  var width, height, bpp: cint
  let
    data = cast[ptr cuchar](str[0].unsafeAddr)
    pixelData = stbi_load_from_memory(data,
      str.len.cint, width, height, bpp, 4)
  if pixelData == nil: raise newException(TextureError, stbi_failure_reason())
  result = newTextureBlank(width, height, slot)
  result.loadTexture(pixelData, bpp)

# setup the texture for 2d rendering
proc bindTexture*(t: Texture) =
  # set the texture slot so we bind to the right one
  gl.activeTexture(succ(TextureUnit.TEXTURE0, t.slot.int))
  gl.bindTexture(TextureTarget.TEXTURE_2D, t.id)

  # texture config
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MIN_FILTER, GL_NEAREST)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MAG_FILTER, GL_NEAREST)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_BASE_LEVEL, 0)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MAX_LEVEL, 0)

# this isn't needed apparently
proc unbindTexture*(t: Texture) =
  discard t # this is to look consistent
  when defined(SYRUP_DEBUG):
    gl.unBindTexture(TextureTarget.TEXTURE_2D)
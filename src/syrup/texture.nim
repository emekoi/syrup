#  Copyright (c) 2017 emekoi
#
#  This library is free software; you can redistribute it and/or modify it
#  under the terms of the MIT license. See LICENSE for details.
#

{.compile: "private/stb_impl.c".}

when defined(Posix) and not defined(haiku):
  {.passl: "-lm".}

import shader, gl, embed, types

const RGB_MASK = 0x00FFFFFF'u32

type
  TextureError* = object of Exception

  # Color* = tuple
  #   r, g, b, a: float32

  # BlendingMode = tuple
  #   src_factor, dst_factor: BlendFactor
  #   blend_equation: BlendEquationEnum
  #   aplha_mult: bool

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

  DrawMode* = object
    color*: Color
    # alpha*: uint8
    # blend*: BlendMode

  PixelFormat = enum
    RGB
    RGBA

  Texture* = ref object
    id: gl.TextureId
    vao*: gl.VertexArrayId
    vbo, ebo: Buffer
    fmt: PixelFormat
    slot: uint32
    width*, height*: int32
    mode: DrawMode
    quad: Quad
    

proc newTexture*(width, height: int32, slot: uint32=0): Texture
proc newTextureFromFile*(filename: string, slot: uint32=0): Texture
proc newTextureFromString*(str: string, slot: uint32=0): Texture
proc setColor*(t: Texture, c: Color)
proc getColor*(t: Texture): Color
proc enable*(t: Texture)
proc disable*(t: Texture)
proc render*(t: Texture)

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

# let TEXTURE_EBO = newBuffer(BufferTarget.ELEMENT_ARRAY_BUFFER, [
#   0'u16, 1'u16, 2'u16,
#   2'u16, 3'u16, 0'u16
# ])

template lerp[T](a, b, p: T): untyped =
  ((1 - p) * a + p * b)

template norm[T](a, b, v: T): untyped =
  (v - a) / (b - a)

proc finalize(t: Texture) =
  gl.deleteVertexArray(t.vao)
  gl.deleteTexture(t.id)

proc calculate_vbo(t: Texture, x, y: int32) =
  let
    width = (t.width).float32
    height = (t.height).float32
    min_x = (t.quad.x).float32
    min_y = (t.quad.y).float32
    max_x = (t.quad.x + t.quad.w).float32
    max_y = (t.quad.y + t.quad.h).float32
    dx = norm(0.0f, 512.0f, x.float32)
    dy = norm(0.0f, 512.0f, y.float32)
    (tlox, tloy) = (-1.0f,  1.0f)
    (trox, troy) = ( 1.0f,  1.0f)
    (brox, broy) = ( 1.0f, -1.0f)
    (blox, bloy) = (-1.0f, -1.0f)

  if t.vbo != nil: GC_unref(t.vbo)

  # t.vbo = newBuffer(BufferTarget.ARRAY_BUFFER, [
  #   vertex(-1.0f,  1.0f,
  #     norm(0.0f, width, min_x), norm(0.0f, height, min_y)), # Top-left
  #   vertex( 1.0f,  1.0f,
  #     norm(0.0f, width, max_x), norm(0.0f, height, min_y)), # Top-right
  #   vertex( 1.0f, -1.0f,
  #     norm(0.0f, width, max_x), norm(0.0f, height, max_y)), # Bottom-right
  #   vertex(-1.0f, -1.0f,
  #     norm(0.0f, width, min_x), norm(0.0f, height, max_y)), # Bottom-left
  # ])

  t.vbo = newBuffer(BufferTarget.ARRAY_BUFFER, [
    vertex(tlox, tloy,
      norm(0.0f, width, min_x), norm(0.0f, height, min_y)), # Top-left
    vertex(trox, troy,
      norm(0.0f, width, max_x), norm(0.0f, height, min_y)), # Top-right
    vertex(brox, broy,
      norm(0.0f, width, max_x), norm(0.0f, height, max_y)), # Bottom-right
    vertex(blox, bloy,
      norm(0.0f, width, min_x), norm(0.0f, height, max_y)), # Bottom-left
  ])

proc newTexture*(width, height: int32, slot: uint32=0): Texture =
  new(result, finalize)
  result.id = gl.genTexture()

  result.height = height
  result.width = width
  result.slot = slot
  result.fmt = PixelFormat.RGBA
  result.quad = quad(0, 0, width, height)

  # generate opengl objects for rendering
  result.vao = gl.genBindVertexArray()
  result.calculate_vbo(0, 0)
  result.ebo = newBuffer(BufferTarget.ELEMENT_ARRAY_BUFFER, [
    0'u16, 1'u16, 2'u16,
    2'u16, 3'u16, 0'u16
  ])

# bind texture, load data, generate mipmaps, then unbind the texture and free the image data
proc loadTexture(t: Texture, data: pointer, bpp: cint) =
  t.enable()
  t.fmt = if bpp == 4: PixelFormat.RGBA else: PixelFormat.RGB
  gl.texImage2D(TexImageTarget.TEXTURE_2D, 0, TextureInternalFormat.RGBA, t.width, t.height,
    succ(PixelDataFormat.RGB, ord(t.fmt)), PixelDataType.UNSIGNED_BYTE, data)
  gl.generateMipMap(MipmapTarget.TEXTURE_2D)
  stbi_image_free(data)
  t.disable()

proc newTextureFromMem*(width, height: int32, data: openarray[uint32], slot: uint32=0): Texture =
  result = newTexture(width, height, slot)
  result.enable()
  gl.texImage2D(TexImageTarget.TEXTURE_2D, 0, TextureInternalFormat.RGBA,
    width, height, PixelDataFormat.RGBA, PixelDataType.UNSIGNED_BYTE, data)
  gl.generateMipMap(MipmapTarget.TEXTURE_2D)
  result.disable()

# load data, pass it through stb and call load image on the data
proc newTextureFromFile*(filename: string, slot: uint32=0): Texture =
  var width, height, bpp: cint
  let pixelData = stbi_load(filename.cstring, width, height, bpp, 4)
  if pixelData == nil: raise newException(TextureError, stbi_failure_reason())
  result = newTexture(width, height, slot)
  result.loadTexture(pixelData, bpp)

proc newTextureFromString*(str: string, slot: uint32=0): Texture =
  var width, height, bpp: cint
  let
    data = cast[ptr cuchar](str[0].unsafeAddr)
    pixelData = stbi_load_from_memory(data,
      str.len.cint, width, height, bpp, 4)
  if pixelData == nil: raise newException(TextureError, stbi_failure_reason())
  result = newTexture(width, height, slot)
  result.loadTexture(pixelData, bpp)

proc setColor*(t: Texture, c: Color) =
  t.mode.color.r = c.r
  t.mode.color.g = c.g
  t.mode.color.b = c.b
  t.mode.color.a = c.a

proc getColor*(t: Texture): Color =
  t.mode.color

proc `quad=`*(t: Texture, q: Quad) =
  t.quad = q
  t.calculate_vbo(0, 0)

# setup the texture for 2d rendering
proc enable*(t: Texture) =
  # enable buffers
  t.vbo.enable()
  t.ebo.enable()

  # set the texture slot so we bind to the right one
  gl.activeTexture(succ(TextureUnit.low(), t.slot.int))
  gl.bindTexture(TextureTarget.TEXTURE_2D, t.id)

  # texture config
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MIN_FILTER, GL_NEAREST)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MAG_FILTER, GL_NEAREST)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_BASE_LEVEL, 0)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MAX_LEVEL, 0)

# this isn't needed apparently
proc disable*(t: Texture) =
  when defined(SYRUP_DEBUG):
    gl.unBindTexture(TextureTarget.TEXTURE_2D)
    t.vbo.disable()
    t.ebo.disable()

proc render*(t: Texture) =
  t.enable()
  gl.drawElements(gl.DrawMode.TRIANGLES , t.ebo.count, IndexType.UNSIGNED_SHORT, 0)
  t.disable()

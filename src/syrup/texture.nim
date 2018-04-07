#  Copyright (c) 2017 emekoi
#
#  This library is free software; you can redistribute it and/or modify it
#  under the terms of the MIT license. See LICENSE for details.
#

{.deadCodeElim: on, optimization: speed.}
{.compile: "suffer/stb_impl.c".}

when defined(Posix) and not defined(haiku):
  {.passl: "-lm".}

import shader, gl, embed

type
  TextureError* = object of Exception

  Texture* = ref object
    tex*: gl.TextureId
    shader*: Shader


# 
# STBI STUFF
# 

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
  gl.deleteTexture(t.id)

proc newTexture(width, height: int32): Texture =
  new(result, finalize)

  result.shader = newShaderFromMem(DEFAULT_FRAG_DATA)
  # CORE.handle.shader.use()

  CORE.handle.tex = gl.genBindTexture(TextureTarget.TEXTURE_2D)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_BASE_LEVEL, 0)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MAX_LEVEL, 0)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MIN_FILTER, GL_NEAREST)
  gl.texParameteri(TextureTarget.TEXTURE_2D, TextureParameter.TEXTURE_MAG_FILTER, GL_NEAREST)
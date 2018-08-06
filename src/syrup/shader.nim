##
##  Copyright (c) 2018 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import sdl2/sdl, sdl2/sdl_gpu as gpu
import graphics

type
  Shader* = ref object
    program*: uint32
    shaderBlock: gpu.ShaderBlock
    log*: tuple[
      vertex: string,
      fragment: string,
      program: string,
    ]

  TextureUnit* {.pure.} = enum
    TEXTURE0
    TEXTURE1
    TEXTURE2
    TEXTURE3
    TEXTURE4
    TEXTURE5
    TEXTURE6
    TEXTURE7
    TEXTURE8
    TEXTURE9
    TEXTURE10
    TEXTURE11
    TEXTURE12
    TEXTURE13
    TEXTURE14
    TEXTURE15
    TEXTURE16
    TEXTURE17
    TEXTURE18
    TEXTURE19
    TEXTURE20
    TEXTURE21
    TEXTURE22
    TEXTURE23
    TEXTURE24
    TEXTURE25
    TEXTURE26
    TEXTURE27
    TEXTURE28
    TEXTURE29
    TEXTURE30
    TEXTURE31

proc newShader*(vertexFile, fragmentFile: File): Shader
  ## @
proc newShader*(vertexSource, fragmentSource: string): Shader
  ## @
proc useShader*(shader: Shader)
  ## @
proc setBool*(shader: Shader, name: string, value: bool)
  ## @
proc setInt*(shader: Shader, name: string, value: int32)
  ## @
proc setFloat*(shader: Shader, name: string, value: float32)
  ## @
proc setVec*(shader: Shader, name: string, value: openarray[float32])
  ## @
proc setVec2*(shader: Shader, name: string, value: openarray[float32])
  ## @
proc setVec3*(shader: Shader, name: string, value: openarray[float32])
  ## @
proc setVec4*(shader: Shader, name:string, value: openarray[float32])
  ## @
proc setTexture*(shader: Shader, name: string, value: graphics.Texture, unit: TextureUnit)
  ## @

proc finalizer(s: Shader) =
  gpu.freeShaderProgram(s.program)

proc newShader*(vertexFile, fragmentFile: File): Shader =
  newShader(vertexFile.readAll(), fragmentFile.readAll())

proc newShader*(vertexSource, fragmentSource: string): Shader =
  new result, finalizer

  let vert = gpu.compileShader(ShaderType.VERTEX_SHADER, vertexSource)
  result.log.vertex = $gpu.getShaderMessage()

  if vert == 0:
    raise newException(Exception, "vertex shader: " & result.log.vertex)

  let frag = gpu.compileShader(ShaderType.FRAGMENT_SHADER, fragmentSource)
  result.log.fragment = $gpu.getShaderMessage()

  if frag == 0:
    raise newException(Exception, "fragment shader: " & result.log.fragment)

  result.program = gpu.linkShaders(vert, frag)
  result.log.program = $gpu.getShaderMessage()

  if result.program == 0:
    raise newException(Exception, "shader program: " & result.log.program)

  result.shaderBlock = result.program.loadShaderBLock(
    "gpu_Vertex", "gpu_TexCoord", "gpu_Color",
    "gpu_ModelViewProjectionMatrix"
  )

  vert.freeShader()
  frag.freeShader()

# proc setAttribute*(shader: Shader, T: typedesc[SomeNumber], name: string, size: int, kind: VertexAttribType, normal: bool, stride: int, p: int) =
#   let attrib = gl.getAttribLocation(shader.program, name)
#   gl.vertexAttribPointer(attrib.uint32, size, kind, normal, stride * sizeof(T), p * sizeof(T))
#   gl.enableVertexAttribArray(attrib.uint32)
#
# proc setAttribute*(shader: Shader, T: typedesc[SomeNumber], location: uint32, size: int, kind: VertexAttribType, normal: bool, stride: int, p: int) =
#   gl.vertexAttribPointer(location, size, kind, normal, stride * sizeof(T), p * sizeof(T))
#   gl.enableVertexAttribArray(location)

proc useShader*(shader: Shader) =
  shader.program.activateShaderProgram(addr shader.shaderBlock)

proc setBool*(shader: Shader, name: string, value: bool) =
  shader.program.getUniformLocation(name).setUniformi(int(value))

proc setInt*(shader: Shader, name: string, value: int32) =
  shader.program.getUniformLocation(name).setUniformi(value)

proc setFloat*(shader: Shader, name: string, value: float32) =
  shader.program.getUniformLocation(name).setUniformf(value)

proc setVec*(shader: Shader, name: string, value: openarray[float32]) =
  shader.program.getUniformLocation(name).setUniformfv(value.len, 1, unsafeAddr value[0])

proc setVec2*(shader: Shader, name: string, value: openarray[float32]) =
  shader.program.getUniformLocation(name).setUniformfv(2, 1, unsafeAddr value[0])

proc setVec3*(shader: Shader, name: string, value: openarray[float32]) =
  shader.program.getUniformLocation(name).setUniformfv(3, 1, unsafeAddr value[0])

proc setVec4*(shader: Shader, name:string, value: openarray[float32]) =
  shader.program.getUniformLocation(name).setUniformfv(4, 1, unsafeAddr value[0])

proc setTexture*(shader: Shader, name: string, value: graphics.Texture, unit: TextureUnit) =
  value.image.setShaderImage(shader.program.getUniformLocation(name), ord(unit))

##
##  Copyright (c) 2017 emekoi
## 
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import gl, glm, embed

type Shader* = ref object
  program*: gl.ShaderProgramId
  vertLog*, fragLog*, progLog*: string
  
proc compileAndAttachShader(shaderType: ShaderType, shaderSource: string, programId: ShaderProgramId): ShaderId =    
  let shaderId = gl.createShader(shaderType)
  gl.shaderSource(shaderId, shaderSource)
  gl.compileShader(shaderId)
  if not gl.getShaderCompileStatus(shaderId):
      raise newException(Exception, "Shader Compile Error:\n" & gl.getShaderInfoLog(shaderId))
  else:
      gl.attachShader(programId, shaderId)
  shaderId

proc finalizer(s: Shader) =
  if s != nil:
    gl.deleteProgram(s.program)

proc createAndLinkProgram(vertexSource:string, fragmentSource:string): Shader =
  new result, finalizer   
  
  result.program = gl.createProgram()
  let vert = compileAndAttachShader(ShaderType.VERTEX_SHADER, vertexSource, result.program)
  let frag = compileAndAttachShader(ShaderType.FRAGMENT_SHADER, fragmentSource, result.program)

  gl.linkProgram(result.program)    

  if not gl.getProgramLinkStatus(result.program):
    raise newException(Exception, "Link Error:\n" & gl.getProgramInfoLog(result.program))

  result.vertLog = $vert.getShaderInfoLog()
  result.fragLog = $frag.getShaderInfoLog()
  result.progLog = $result.program.getProgramInfoLog()

  if result.vertLog.len > 0:
    echo result.vertLog
  if result.fragLog.len > 0:
      echo result.fragLog
  if result.progLog.len > 0:
      echo result.progLog

  gl.deleteShader(vert)
  gl.deleteShader(frag)

proc shader_from_file*(fragmentFile:string): Shader =
  result = createAndLinkProgram(DEFAULT_VERT_DATA, readFile(fragmentFile))

proc shader_from_file*(vertexFile, fragmentFile:string): Shader =
  result = createAndLinkProgram(readFile(vertexFile), readFile(fragmentFile))
  
proc shader_from_mem*(fragmentSource:string): Shader =
  result = createAndLinkProgram(DEFAULT_VERT_DATA, fragmentSource)
  
proc shader_from_mem*(vertexSource, fragmentSource:string): Shader =
  result = createAndLinkProgram(vertexSource, fragmentSource)

proc set_attribute*(shader: Shader, name: string, size: int, kind: VertexAttribType, normal: bool, stride: int, p: int) =
  let attrib = gl.getAttribLocation(shader.program, name)
  gl.vertexAttribPointer(attrib.uint32, size, kind, normal, stride, p)
  gl.enableVertexAttribArray(attrib.uint32)

proc set_attribute*(shader: Shader, location: uint32, size: int, kind: VertexAttribType, normal: bool, stride: int, p: int) =
  gl.vertexAttribPointer(location, size, kind, normal, stride, p)
  gl.enableVertexAttribArray(location)  

# proc use*(shader: Shader) =
#   gl.use(shader.program)
#   shader.setAttribute("sp_Position", 4, VertexAttribType.FLOAT, false, 8 * sizeof(float32), 0)
#   shader.setAttribute("sp_TexCoord", 4, VertexAttribType.FLOAT, false, 8 * sizeof(float32), 4 * sizeof(float32))

proc use*(shader: Shader) =
  gl.use(shader.program)
  shader.set_attribute(0, 4, VertexAttribType.FLOAT, false, 8 * sizeof(float32), 0)                   # position
  shader.set_attribute(1, 4, VertexAttribType.FLOAT, false, 8 * sizeof(float32), 4 * sizeof(float32)) # tex coords

proc set_bool*(shader: Shader, name: string, value: bool) =
  gl.setBool(shader.program, name, value)

proc set_int*(shader: Shader, name: string, value: int32) =
  gl.setInt(shader.program, name, value)
  
proc set_float*(shader: Shader, name: string, value: float32) =
  gl.setFloat(shader.program, name, value)

proc set_vec2*(shader: Shader, name: string, value:var Vec2f) =
  gl.setVec2(shader.program, name, value)

proc set_vec2*(shader: Shader, name: string, x:float32, y:float32) =
  gl.setVec2(shader.program, name, x, y)
  
proc set_vec3*(shader: Shader, name: string, value:var Vec3f) =
  gl.setVec3(shader.program, name, value)
  
proc set_vec3*(shader: Shader, name: string, x:float32, y:float32, z:float32) =
  gl.setVec3(shader.program, name, x, y, z)

proc set_vec4*(shader: Shader, name:string, value: var Vec4f) =
  gl.setVec4(shader.program, name, value)

proc set_vec4*(shader: Shader, name: string, x:float32, y:float32, z:float32, w:float32) =
  gl.setVec4(shader.program, name, x, y, z, w)
          
proc set_mat4*(shader: Shader, name: string, value: var Mat4f ) =
  gl.setMat4(shader.program, name, value)

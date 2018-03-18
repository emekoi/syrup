import gl, glm

type Shader* = ref object
  program*: gl.ShaderProgramId
  
proc compileAndAttachShader(shaderType: ShaderType, shaderSource: string, programId: ShaderProgramId): ShaderId =    
  let shaderId = gl.createShader(shaderType)
  gl.shaderSource(shaderId, shaderSource)
  gl.compileShader(shaderId)
  if not gl.getShaderCompileStatus(shaderId):
      raise newException(Exception, "Shader Compile Error:\n" & gl.getShaderInfoLog(shaderId))
  else:
      gl.attachShader(programId, shaderId)
  shaderId

proc createAndLinkProgram(vertexSource:string, fragmentSource:string): gl.ShaderProgramId =
  let programId = gl.createProgram()
  let vert = compileAndAttachShader(ShaderType.VERTEX_SHADER, vertexSource, programId)
  let frag = compileAndAttachShader(ShaderType.FRAGMENT_SHADER, fragmentSource, programId)

  gl.linkProgram(programId)    

  if not gl.getProgramLinkStatus(programId):
    raise newException(Exception, "Link Error:\n" & gl.getProgramInfoLog(programId))
  

  var msg = vert.getShaderInfoLog()
  if msg.len > 0:
    echo msg
  msg = frag.getShaderInfoLog()
  if msg.len > 0:
    echo msg
  msg = programId.getProgramInfoLog()
  if msg.len > 0:
    echo msg

  gl.deleteShader(vert)
  gl.deleteShader(frag)
  programId

proc finalizer(s: Shader) =
  if s != nil:
    gl.deleteProgram(s.program)

proc newShader*(vertexFile:string, fragmentFile:string): Shader =
  new result, finalizer   
  result.program = createAndLinkProgram(readFile(vertexFile), readFile(fragmentFile))

proc newShaderString*(vertexSource:string, fragmentSource:string): Shader =
  new result, finalizer   
  result.program = createAndLinkProgram(vertexSource, fragmentSource)

proc setAttribute*(shader: Shader, name: string, size: int, kind: VertexAttribType, normal: bool, stride: int, p: int) =
  let attrib = gl.getAttribLocation(shader.program, name)
  gl.vertexAttribPointer(attrib.uint32, size, kind, normal, stride, p)
  gl.enableVertexAttribArray(attrib.uint32)  

proc use*(shader: Shader) =
  gl.use(shader.program)
  shader.setAttribute("sp_Position", 4, VertexAttribType.FLOAT, false, 8 * sizeof(float32), 0)
  shader.setAttribute("sp_TexCoord", 4, VertexAttribType.FLOAT, false, 8 * sizeof(float32), 4 * sizeof(float32))

proc setBool*(shader: Shader, name: string, value: bool) =
  gl.setBool(shader.program, name, value)

proc setInt*(shader: Shader, name: string, value: int32) =
  gl.setInt(shader.program, name, value)
  
proc setFloat*(shader: Shader, name: string, value: float32) =
  gl.setFloat(shader.program, name, value)

proc setVec2*(shader: Shader, name: string, value:var Vec2f) =
  gl.setVec2(shader.program, name, value)

proc setVec2*(shader: Shader, name: string, x:float32, y:float32) =
  gl.setVec2(shader.program, name, x, y)
  
proc setVec3*(shader: Shader, name: string, value:var Vec3f) =
  gl.setVec3(shader.program, name, value)
  
proc setVec3*(shader: Shader, name: string, x:float32, y:float32, z:float32) =
  gl.setVec3(shader.program, name, x, y, z)

proc setVec4*(shader: Shader, name:string, value: var Vec4f) =
  gl.setVec4(shader.program, name, value)

proc setVec4*(shader: Shader, name: string, x:float32, y:float32, z:float32, w:float32) =
  gl.setVec4(shader.program, name, x, y, z, w)
          
proc setMat4*(shader: Shader, name: string, value: var Mat4f ) =
  gl.setMat4(shader.program, name, value)

import gl, embed

type Shader = ref object
  vertex, fragment: ShaderId
  program: ShaderProgramId
  
proc finalizer(s: Shader) =
  if s != nil:
    gl.detachShader(s.program, s.vertex)
    gl.detachShader(s.program, s.fragment)
    gl.deleteShader(s.vertex)
    gl.deleteShader(s.fragment)
    gl.deleteProgram(s.program)

proc newShader*(file: string): Shader =
    new result, finalizer
  
proc newShaderString*(file: string): Shader =
    new result, finalizer

proc getWarnings*(s: Shader): string =
  return getShaderInfoLog(s.fragment)
##
##  Copyright (c) 2017 emekoi
## 
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import gl, embed, shader, texture, sequtils

type
  Renderer* = ref object
    vbo: gl.BufferId
    vao: gl.VertexArrayId
    ebo: gl.BufferId
    texture*: Texture
    shader*: Shader
    width*, height*: int32

  Vertex {.packed, pure.} = object
    # Position
    sx*, sy*: float32
    # Texcoord
    tx*, ty*: float32

proc vertex(sx, sy, tx, ty: float32): Vertex =
  Vertex(sx: sx, sy: sy, tx: tx, ty: ty)

let
  VERTICIES = [
    vertex(-1.0f,  1.0f, 0.0f, 0.0f), # Top-left
    vertex( 1.0f,  1.0f, 1.0f, 0.0f), # Top-right
    vertex( 1.0f, -1.0f, 1.0f, 1.0f), # Bottom-right
    vertex(-1.0f, -1.0f, 0.0f, 1.0f), # Bottom-left
  ]
 #  VERTICIES = [
 #    -1.0f,  1.0f,   0.0f, 0.0f, # Top-left
 #     1.0f,  1.0f,   0.5f, 0.0f, # Top-right
 #     1.0f, -1.0f,   0.5f, 1.0f, # Bottom-right
 #    -1.0f, -1.0f,   0.0f, 1.0f, # Bottom-left
 #  ]
  ELEMENTS = [
    0, 1, 2,
    2, 3, 0
  ]


proc finalize(r: Renderer) =
  # clean up opengl objects
  gl.deleteBuffers([r.ebo, r.vbo])
  gl.deleteVertexArray(r.vao)

proc setShader*(r: Renderer, shader: Shader) =
  if r.shader == shader: return
  r.shader = shader
  gl.use(shader.program)
  # in case different attribute names are set,
  # bind to the first and second available attrib slots
  r.shader.setAttribute(float32, 0, 2, VertexAttribType.FLOAT, false, 4, 0) # position
  r.shader.setAttribute(float32, 1, 2, VertexAttribType.FLOAT, false, 4, 2) # tex coords

proc newRenderer*(width, height: int32): Renderer =
  new(result, finalize)

  result.width = width
  result.height = height

  # disable capabilities
  gl.disable(Capability.CULL_FACE)
  gl.disable(Capability.DEPTH_TEST)
  
  # enable capabilities
  gl.enable(Capability.BLEND)

  # opengl config
  gl.blendFunc(BlendFactor.SRC_ALPHA, BlendFactor.ONE_MINUS_SRC_ALPHA)
  gl.clearColor(0.0f, 0.0f, 0.0f, 1.0f)

  # generate opengl objects for rendering
  result.vao = gl.genBindVertexArray()
  result.vbo = gl.genBindBufferData(BufferTarget.ARRAY_BUFFER, VERTICIES, BufferDataUsage.STATIC_DRAW)
  result.ebo = gl.genBindBufferData(BufferTarget.ELEMENT_ARRAY_BUFFER, ELEMENTS, BufferDataUsage.STATIC_DRAW);

  # should we use the shader right away?
  # result.shader = newShaderFromMem(DEFAULT_FRAG_DATA)
  let shader = newShaderFromFile("syrup/embed/default.vert", "syrup/embed/default.frag")
  result.setShader(shader)
  
  # generate our texture for drawing to
  # result.texture = texture.newTextureBlank(width, height)
  result.texture = texture.newTextureFromFile("syrup/embed/test.png")

proc clear*(r: Renderer) =
  gl.clear(BufferMask.DEPTH_BUFFER_BIT, BufferMask.COLOR_BUFFER_BIT)

proc render*(r: Renderer) =
  # clear the screen
  r.texture.bindTexture()
  # draw our internal texture to the screen
  gl.drawElements(gl.DrawMode.TRIANGLES , 6, IndexType.UNSIGNED_INT, 0)
  # this only does work if `SYRUP_DEBUG` is defined
  r.texture.unbindTexture()
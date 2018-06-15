##
##  Copyright (c) 2017 emekoi
## 
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import sequtils
import gl, embed, shader, texture, types

type
  Renderer* = ref object
    texture*: Texture
    shader*: Shader
    width*, height*: int32
    queue*: seq[Texture]

proc finalize(r: Renderer) =
  # clean up opengl objects
  discard r

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

  # generate our texture for drawing to
  # result.texture = texture.newTexture(width, height)
  result.texture = texture.newTextureFromFile("src/syrup/embed/test.png")
  result.texture.quad = quad(0, 0, 64, 64)
  # we need to enable the texture's vbo to create our shader
  result.texture.enable()
  
  # result.shader = newShaderFromMem(DEFAULT_FRAG_DATA)
  let shader = newShaderFromFile("src/syrup/embed/default.vert", "src/syrup/embed/default.frag")
  result.setShader(shader)

  result.texture.disable()

proc clear*(r: Renderer) =
  gl.clear(BufferMask.COLOR_BUFFER_BIT, BufferMask.DEPTH_BUFFER_BIT)

proc submit*(r: Renderer, t: Texture) =
  r.queue.add(t)

proc flush*(r: Renderer) =
  r.clear()
  while r.queue.len() > 0:
    let tex = r.queue.pop()
    tex.render()

proc render*(r: Renderer) =
  # clear the screen
  r.clear()
  r.texture.render()

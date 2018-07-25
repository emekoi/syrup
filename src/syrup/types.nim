#
#  Copyright (c) 2018 emekoi
# 
#  This library is free software; you can redistribute it and/or modify it
#  under the terms of the MIT license. See LICENSE for details.
#

import tables
import shader, gl, embed

type
  Vertex* {.packed, pure.} = object
    sx*, sy*: float32 # Position
    tx*, ty*: float32 # Texcoord
  
  Color* {.packed, pure.} = object
    r*, g*, b*, a*: float32

  Quad* {.packed, pure.} = object
    x*, y*, w*, h*: int32

  Buffer* = ref object
    id: gl.BufferId
    target: int32
    count*: int32

  # VertexArray* = ref object
  #   id: gl.VertexArrayId
  #   buf: seq[Buffer]

var
  BOUND_BUFFER = toTable({
    ord(BufferTarget.ARRAY_BUFFER)              : -1,
    ord(BufferTarget.ELEMENT_ARRAY_BUFFER)      : -1,
    ord(BufferTarget.PIXEL_PACK_BUFFER)         : -1,
    ord(BufferTarget.PIXEL_UNPACK_BUFFER)       : -1,
    ord(BufferTarget.UNIFORM_BUFFER)            : -1,
    ord(BufferTarget.TEXTURE_BUFFER)            : -1,
    ord(BufferTarget.TRANSFORM_FEEDBACK_BUFFER) : -1,
    ord(BufferTarget.COPY_READ_BUFFER)          : -1,
    ord(BufferTarget.COPY_WRITE_BUFFER)         : -1,
    ord(BufferTarget.DRAW_INDIRECT_BUFFER)      : -1,
    ord(BufferTarget.SHADER_STORAGE_BUFFER)     : -1,
    ord(BufferTarget.DISPATCH_INDIRECT_BUFFER)  : -1,
    ord(BufferTarget.QUERY_BUFFER)              : -1,
    ord(BufferTarget.ATOMIC_COUNTER_BUFFER)     : -1,
  })

  # BOUND_VERTEX_ARRAY = -1

proc vertex*(sx, sy, tx, ty: float32): Vertex =
  Vertex(sx: sx, sy: sy, tx: tx, ty: ty)

proc color*(r, g, b, a: float32=1.0): Color =
  Color(r: r, g: g, b: b, a: a)

proc quad*(x, y, w, h: int32): Quad =
  Quad(x: x, y: y, w: w, h: h)

proc finalize(buf: Buffer) =
  gl.deleteBuffer(buf.id)

proc newBuffer*[T](target: gl.BufferTarget, data: openarray[T]): Buffer =
  new(result, finalize)
  result.target = ord(target)
  result.count = data.len
  result.id = gl.genBindBufferData(target,
    data, BufferDataUsage.STATIC_DRAW)
  gl.unBindBuffer(target)

proc enable*(buf: Buffer) =
  if BOUND_BUFFER[buf.target] != buf.id.int32:
    gl.bindBuffer(BufferTarget(buf.target), buf.id)
    BOUND_BUFFER[buf.target] = buf.id.int32

proc disable*(buf: Buffer) =
  when defined(SYRUP_DEBUG):
    gl.unBindBuffer(BufferTarget(buf.target))
    BOUND_BUFFER[buf.target] = -1
  else:
    discard


# do we need this stuff?
# proc finalize(v: VertexArray) =
#   for buf in v.buf:
#     while buf.getRefcount() > 0:
#       GC_unref(buf)
#   gl.deleteVertexArray(v.id)

# proc newVertexArray*(): VertexArray =
#   new(result, finalize)
#   result.id = gl.genVertexArray()
#   result.buf = @[]

# proc enable*(v: VertexArray) =
#   if BOUND_VERTEX_ARRAY != v.id.int32:
#     gl.bindVertexArray(v.id)
#     BOUND_VERTEX_ARRAY = v.id.int32

# proc disable*(v: VertexArray) =
#   when defined(SYRUP_DEBUG):
#     gl.unBindVertexArray()
#     BOUND_VERTEX_ARRAY = -1
#   else:
#     discard

# proc addBuffer*(v: VertexArray, buf: Buffer, idx: uint32) =
#   v.enable()

#   v.disable()
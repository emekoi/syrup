##
##  Copyright (c) 2017 emekoi
## 
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import opengl, glm
export opengl, glm

type
  BufferId* = distinct GLuint
  VertexArrayId* = distinct GLuint
  TextureId* = distinct GLuint
  ShaderId* = distinct GLuint
  ShaderProgramId* = distinct GLuint
  FrameBufferId* = distinct GLuint
  RenderBufferID* = distinct GLuint
  UniformLocation* = distinct GLint

  ErrorType* {.pure.} = enum
    NO_ERROR = GL_NO_ERROR,
    INVALUD_ENUM = GL_INVALID_ENUM,
    INVALID_VALUE = GL_INVALID_VALUE,
    INVALID_OPERATION = GL_INVALID_OPERATION,
    OUT_OF_MEMORY = GL_OUT_OF_MEMORY,
    INVALID_FRAMEBUFFER_OPERATION = GL_INVALID_FRAMEBUFFER_OPERATION


  Capability* {.pure.} = enum
    LINE_SMOOTH = GL_LINE_SMOOTH, #0x0B20
    POLYGON_SMOOTH = GL_POLYGON_SMOOTH, #0x0B41
    CULL_FACE = GL_CULL_FACE, #0x0B44
    DEPTH_TEST = GL_DEPTH_TEST, #0x0B71
    STENCIL_TEST = GL_STENCIL_TEST #0x0B90,
    DITHER = GL_DITHER, #0x0BD0
    BLEND = GL_BLEND, #0x0BE2
    COLOR_LOGIC_OP = GL_COLOR_LOGIC_OP, #0x0BF2
    SCISSOR_TEST = GL_SCISSOR_TEST, #0x0C11
    POLYGON_OFFSET_POINT = GL_POLYGON_OFFSET_POINT, #0x2A01
    POLYGON_OFFSET_LINE = GL_POLYGON_OFFSET_LINE, #0x2A02
    CLIP_DISTANCE0 = GL_CLIP_DISTANCE0,
    CLIP_DISTANCE1 = GL_CLIP_DISTANCE1,
    CLIP_DISTANCE2 = GL_CLIP_DISTANCE2,
    CLIP_DISTANCE3 = GL_CLIP_DISTANCE3,
    CLIP_DISTANCE4 = GL_CLIP_DISTANCE4,
    CLIP_DISTANCE5 = GL_CLIP_DISTANCE5,
    CLIP_DISTANCE6 = GL_CLIP_DISTANCE6,
    CLIP_DISTANCE7 = GL_CLIP_DISTANCE7,
    POLYGON_OFFSET_FILL = GL_POLYGON_OFFSET_FILL, #0x8037
    MULTISAMPLE = GL_MULTISAMPLE, #0x809D
    SAMPLE_ALPHA_TO_COVERAGE = GL_SAMPLE_ALPHA_TO_COVERAGE, #0x809E
    SAMPLE_ALPHA_TO_ONE = GL_SAMPLE_ALPHA_TO_ONE, #0x809F
    SAMPLE_COVERAGE = GL_SAMPLE_COVERAGE, #0x80A0
    DEBUG_OUTPUT_SYNCHRONOUS = GL_DEBUG_OUTPUT_SYNCHRONOUS, #0x8242
    PROGRAM_POINT_SIZE = GL_PROGRAM_POINT_SIZE #0x8642
    DEPTH_CLAMP = GL_DEPTH_CLAMP,
    TEXTURE_CUBE_MAP_SEAMLESS = GL_TEXTURE_CUBE_MAP_SEAMLESS, #0x884F
    SAMPLE_SHADING = GL_SAMPLE_SHADING, #0x8C36
    RASTERIZER_DISCARD = GL_RASTERIZER_DISCARD, #0x8C89
    PRIMITIVE_RESTART_FIXED_INDEX = GL_PRIMITIVE_RESTART_FIXED_INDEX, #0x8D69
    FRAMEBUFFER_SRGB = GL_FRAMEBUFFER_SRGB, #0x8DB9
    SAMPLE_MASK = GL_SAMPLE_MASK, #0x8E51
    PRIMITIVE_RESTART = GL_PRIMITIVE_RESTART, #0x8F9D
    DEBUG_OUTPUT = GL_DEBUG_OUTPUT, #0x92E0

  Access* {.pure.} = enum
    READ_ONLY = GL_READ_ONLY,
    WRITE_ONLY = GL_WRITE_ONLY,
    READ_WRITE = GL_READ_WRITE

  AlphaFunc* {.pure.} = enum
    NEVER = GL_NEVER,
    LESS = GL_LESS,
    EQUAL = GL_EQUAL,
    LEQUAL = GL_LEQUAL,
    GREATER = GL_GREATER,
    NOTEQUAL = GL_NOTEQUAL,
    GEQUAL = GL_GEQUAL,
    ALWAYS = GL_ALWAYS

  StencilOpEnum* {.pure.} = enum
    ZERO = GL_ZERO,
    INVERT = GL_INVERT, #0x150A
    KEEP = GL_KEEP, #0x1E00
    REPLACE = GL_REPLACE,
    INCR = GL_INCR,
    DECR = GL_DECR, #0x1E03
    INCR_WRAP = GL_INCR_WRAP,
    DECR_WRAP = GL_DECR_WRAP

  BlendFactor* {.pure.} = enum
    ZERO = GL_ZERO,
    ONE = GL_ONE,
    SRC_COLOR = GL_SRC_COLOR,
    ONE_MINUS_SRC_COLOR = GL_ONE_MINUS_SRC_COLOR,
    SRC_ALPHA = GL_SRC_ALPHA, #302
    ONE_MINUS_SRC_ALPHA = GL_ONE_MINUS_SRC_ALPHA,
    DST_ALPHA = GL_DST_ALPHA,
    ONE_MINUS_DST_ALPHA = GL_ONE_MINUS_DST_ALPHA,
    DST_COLOR = GL_DST_COLOR,
    ONE_MINUS_DST_COLOR = GL_ONE_MINUS_DST_COLOR,
    SRC_ALPHA_SATURATE = GL_SRC_ALPHA_SATURATE,
    CONSTANT_COLOR = GL_CONSTANT_COLOR,
    ONE_MINUS_CONSTANT_COLOR = GL_ONE_MINUS_CONSTANT_COLOR,
    CONSTANT_ALPHA = GL_CONSTANT_ALPHA,
    ONE_MINUS_CONSTANT_ALPHA = GL_ONE_MINUS_CONSTANT_ALPHA
    SRC1_ALPHA = GL_SRC1_ALPHA,
    SRC1_COLOR = GL_SRC1_COLOR,
    ONE_MINUS_SRC1_COLOR = GL_ONE_MINUS_SRC1_COLOR,
    ONE_MINUS_SRC1_ALPHA = GL_ONE_MINUS_SRC1_ALPHA

  BlendEquationEnum* {.pure.} = enum
    FUNC_ADD = GL_FUNC_ADD,
    MIN = GL_MIN,
    MAX = GL_MAX
    FUNC_SUBTRACT = GL_FUNC_SUBTRACT,
    FUNC_REVERSE_SUBTRACT = GL_FUNC_REVERSE_SUBTRACT,

  FaceMode* {.pure.} = enum
    CW = GL_CW,
    CCW = GL_CCW

  BufferTarget* {.pure.} = enum
    ARRAY_BUFFER = GL_ARRAY_BUFFER, #0x88923
    ELEMENT_ARRAY_BUFFER = GL_ELEMENT_ARRAY_BUFFER, #0x8893
    PIXEL_PACK_BUFFER = GL_PIXEL_PACK_BUFFER, #0x88EB
    PIXEL_UNPACK_BUFFER = GL_PIXEL_UNPACK_BUFFER, #0x88EC
    UNIFORM_BUFFER = GL_UNIFORM_BUFFER #0x8A11
    TEXTURE_BUFFER = GL_TEXTURE_BUFFER, #0x8C2A
    TRANSFORM_FEEDBACK_BUFFER = GL_TRANSFORM_FEEDBACK_BUFFER, #0x8C8E
    COPY_READ_BUFFER = GL_COPY_READ_BUFFER, #0x8F36
    COPY_WRITE_BUFFER = GL_COPY_WRITE_BUFFER, #0x8F37
    DRAW_INDIRECT_BUFFER = GL_DRAW_INDIRECT_BUFFER,#0x8F3F
    SHADER_STORAGE_BUFFER = GL_SHADER_STORAGE_BUFFER, #0x90D2
    DISPATCH_INDIRECT_BUFFER = GL_DISPATCH_INDIRECT_BUFFER, #0x90EE
    QUERY_BUFFER = GL_QUERY_BUFFER, #0x9192
    ATOMIC_COUNTER_BUFFER = GL_ATOMIC_COUNTER_BUFFER, #0x92C0

  BufferRangeTarget* {.pure.} = enum
    UNIFORM_BUFFER = GL_UNIFORM_BUFFER,
    TRANSFORM_FEEDBACK_BUFFER = GL_TRANSFORM_FEEDBACK_BUFFER,
    SHADER_STORAGE_BUFFER = GL_SHADER_STORAGE_BUFFER,
    ATOMIC_COUNTER_BUFFER = GL_ATOMIC_COUNTER_BUFFER,

  FramebufferTarget* {.pure.} = enum
    READ_FRAMEBUFFER = GL_READ_FRAMEBUFFER,
    DRAW_FRAME_BUFFER = GL_DRAW_FRAMEBUFFER,
    FRAMEBUFFER = GL_FRAMEBUFFER

  FramebufferStatus* {.pure.} = enum
    FRAMEBUFFER_COMPLETE = GL_FRAMEBUFFER_COMPLETE,
    FRAMEBUFFER_INCOMPLETE_ATTACHMENT = GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT,
    FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT = GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT,
    FRAMEBUFFER_INCOMPLETE_DIMENSIONS = GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS,
    FRAMEBUFFER_UNSUPPORTED = GL_FRAMEBUFFER_UNSUPPORTED

  # todo: i should range from 0 to GL_MAX_COLOR_ATTACHMENTS-1
  FramebufferAttachment* {.pure.} = enum
    DEPTH_STENCIL_ATTACHMENT = GL_DEPTH_STENCIL_ATTACHMENT,
    COLOR_ATTACHMENT0 = GL_COLOR_ATTACHMENT0, #              0x8CE0
    COLOR_ATTACHMENT1 = GL_COLOR_ATTACHMENT1, #              0x8CE1
    COLOR_ATTACHMENT2 = GL_COLOR_ATTACHMENT2, #              0x8CE2
    COLOR_ATTACHMENT3 = GL_COLOR_ATTACHMENT3, #              0x8CE3
    COLOR_ATTACHMENT4 = GL_COLOR_ATTACHMENT4, #              0x8CE4
    COLOR_ATTACHMENT5 = GL_COLOR_ATTACHMENT5, #              0x8CE5
    COLOR_ATTACHMENT6 = GL_COLOR_ATTACHMENT6, #              0x8CE6
    COLOR_ATTACHMENT7 = GL_COLOR_ATTACHMENT7, #              0x8CE7
    COLOR_ATTACHMENT8 = GL_COLOR_ATTACHMENT8, #              0x8CE8
    COLOR_ATTACHMENT9 = GL_COLOR_ATTACHMENT9, #              0x8CE9
    COLOR_ATTACHMENT10 = GL_COLOR_ATTACHMENT10, #             0x8CEA
    COLOR_ATTACHMENT11 = GL_COLOR_ATTACHMENT11, #             0x8CEB
    COLOR_ATTACHMENT12 = GL_COLOR_ATTACHMENT12, #             0x8CEC
    COLOR_ATTACHMENT13 = GL_COLOR_ATTACHMENT13, #             0x8CED
    COLOR_ATTACHMENT14 = GL_COLOR_ATTACHMENT14, #             0x8CEE
    COLOR_ATTACHMENT15 = GL_COLOR_ATTACHMENT15, #             0x8CEF
    DEPTH_ATTACHMENT = GL_DEPTH_ATTACHMENT,
    STENCIL_ATTACHMENT = GL_STENCIL_ATTACHMENT

  BufferDataUsage* {.pure.} = enum
    STREAM_DRAW = GL_STREAM_DRAW,
    STREAM_READ = GL_STREAM_READ,
    STREAM_COPY = GL_STREAM_COPY,
    STATIC_DRAW = GL_STATIC_DRAW,
    STATIC_READ = GL_STATIC_READ,
    STATIC_COPY = GL_STATIC_COPY,
    DYNAMIC_DRAW = GL_DYNAMIC_DRAW,
    DYNAMIC_READ = GL_DYNAMIC_READ,
    DYNAMIC_COPY = GL_DYNAMIC_COPY

  ShaderType* {.pure.} = enum
    FRAGMENT_SHADER = GL_FRAGMENT_SHADER #0x8B30
    VERTEX_SHADER = GL_VERTEX_SHADER #0x8B31,
    GEOMETRY_SHADER = GL_GEOMETRY_SHADER, #0x8DD9
    TESS_EVALUATION_SHADER = GL_TESS_EVALUATION_SHADER, #0x8E87
    TESS_CONTROL_SHADER = GL_TESS_CONTROL_SHADER, #0x8E88
    COMPUTE_SHADER = GL_COMPUTE_SHADER, #0x91B9

  VertexAttribIType* {.pure.} = enum
    BYTE = cGL_BYTE,
    UNSIGNED_BYTE = GL_UNSIGNED_BYTE,
    SHORT =  cGL_SHORT,
    UINSIGNED_SHORT = GL_UNSIGNED_SHORT,
    INT = cGL_INT,
    UNSIGNED_INT = GL_UNSIGNED_INT

  VertexAttribType* {.pure.} = enum
    BYTE = cGL_BYTE, #0x1400
    UNSIGNED_BYTE = GL_UNSIGNED_BYTE, #0x1401
    SHORT =  cGL_SHORT, #0x1402
    UINSIGNED_SHORT = GL_UNSIGNED_SHORT, #0x1403
    INT = cGL_INT,#0x1404
    UNSIGNED_INT = GL_UNSIGNED_INT, #0x1405
    FLOAT = cGL_FLOAT, #0x1406
    DOUBLE = cGL_DOUBLE,
    HALF_FLOAT = GL_HALF_FLOAT, #0x140B
    FIXED = cGL_FIXED,
    UNSIGNED_INT_2_10_10_10_REV = GL_UNSIGNED_INT_2_10_10_10_REV, # 0x8368
    UNSIGNED_INT_10F_11F_11F_REV = GL_UNSIGNED_INT_10F_11F_11F_REV #0x8C3B
    INT_2_10_10_10_REV = GL_INT_2_10_10_10_REV, #0x8D9F

  DrawMode* {.pure.} = enum
    POINTS = GL_POINTS, #0x0000
    LINE = GL_LINES, # 0x0001
    LINE_LOOP = GL_LINE_LOOP, #0x0002
    LINE_STRIP = GL_LINE_STRIP, #0x0003
    TRIANGLES = GL_TRIANGLES, #0x0004
    TRIANGLE_STRIP = GL_TRIANGLE_STRIP, #0x0005
    TRIANGLE_FAN = GL_TRIANGLE_FAN, #0x0006
    QUADS = GL_QUADS #0x0007
    LINES_ADJACENCY = GL_LINES_ADJACENCY, #0x000A
    LINE_STRIP_ADJACENCY = GL_LINE_STRIP_ADJACENCY, #0x000B
    TRIANGLES_ADJACENCY = GL_TRIANGLES_ADJACENCY, #0x000C
    TRIANGLE_STRIP_ADJACENCY = GL_TRIANGLE_STRIP_ADJACENCY, #0x000D
    PATCHES = GL_PATCHES #0x000E

  BufferMask* {.pure.} = enum
    DEPTH_BUFFER_BIT = GL_DEPTH_BUFFER_BIT,
    STENCIL_BUFFER_BIT = GL_STENCIL_BUFFER_BIT,
    COLOR_BUFFER_BIT = GL_COLOR_BUFFER_BIT

  IndexType* {.pure.} = enum
    UNSIGNED_BYTE = GL_UNSIGNED_BYTE,
    UNSIGNED_SHORT = GL_UNSIGNED_SHORT,
    UNSIGNED_INT = GL_UNSIGNED_INT

  MipmapTarget* {.pure.} = enum
    TEXTURE_1D = GL_TEXTURE_1D,
    TEXTURE_2D = GL_TEXTURE_2D,
    TEXTURE_3D = GL_TEXTURE_3D,
    TEXTURE_CUBE_MAP = GL_TEXTURE_CUBE_MAP, #0x8513
    TEXTURE_1D_ARRAY = GL_TEXTURE_1D_ARRAY,
    TEXTURE_2D_ARRAY = GL_TEXTURE_2D_ARRAY, #0x8C1A
    TEXTURE_CUBE_MAP_ARRAY = GL_TEXTURE_CUBE_MAP_ARRAY,

  TextureTarget* {.pure.} = enum
    TEXTURE_1D = GL_TEXTURE_1D,
    TEXTURE_2D = GL_TEXTURE_2D,
    TEXTURE_3D = GL_TEXTURE_3D,
    TEXTURE_RECTANGLE = GL_TEXTURE_RECTANGLE, #0x84F5
    TEXTURE_CUBE_MAP = GL_TEXTURE_CUBE_MAP, #0x8513
    TEXTURE_1D_ARRAY = GL_TEXTURE_1D_ARRAY,
    TEXTURE_2D_ARRAY = GL_TEXTURE_2D_ARRAY, #0x8C1A
    TEXTURE_BUFFER = GL_TEXTURE_BUFFER, #0x8C2A
    TEXTURE_CUBE_MAP_ARRAY = GL_TEXTURE_CUBE_MAP_ARRAY,
    TEXTURE_2D_MULTISAMPLE = GL_TEXTURE_2D_MULTISAMPLE,
    TEXTURE_2D_MULTISAMPLE_ARRAY = GL_TEXTURE_2D_MULTISAMPLE_ARRAY

  # todo - refine?  https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/glFramebufferTexture.xhtml
  FramebufferTextureTarget* {.pure.} = enum
    TEXTURE_1D = GL_TEXTURE_1D,
    TEXTURE_2D = GL_TEXTURE_2D,
    TEXTURE_3D = GL_TEXTURE_3D,
    TEXTURE_RECTANGLE = GL_TEXTURE_RECTANGLE, #0x84F5
    TEXTURE_CUBE_MAP = GL_TEXTURE_CUBE_MAP, #0x8513
    # if texture is a cube map then this must be one of:
    TEXTURE_CUBE_MAP_POSITIVE_X = GL_TEXTURE_CUBE_MAP_POSITIVE_X,
    TEXTURE_CUBE_MAP_NEGATIVE_X = GL_TEXTURE_CUBE_MAP_NEGATIVE_X,
    TEXTURE_CUBE_MAP_POSITIVE_Y = GL_TEXTURE_CUBE_MAP_POSITIVE_Y,
    TEXTURE_CUBE_MAP_NEGATIVE_Y = GL_TEXTURE_CUBE_MAP_NEGATIVE_Y,
    TEXTURE_CUBE_MAP_POSITIVE_Z = GL_TEXTURE_CUBE_MAP_POSITIVE_Z,
    TEXTURE_CUBE_MAP_NEGATIVE_Z = GL_TEXTURE_CUBE_MAP_NEGATIVE_Z
    # endif
    TEXTURE_1D_ARRAY = GL_TEXTURE_1D_ARRAY,
    TEXTURE_2D_ARRAY = GL_TEXTURE_2D_ARRAY, #0x8C1A
    TEXTURE_BUFFER = GL_TEXTURE_BUFFER, #0x8C2A
    TEXTURE_CUBE_MAP_ARRAY = GL_TEXTURE_CUBE_MAP_ARRAY,
    TEXTURE_2D_MULTISAMPLE = GL_TEXTURE_2D_MULTISAMPLE,
    TEXTURE_2D_MULTISAMPLE_ARRAY = GL_TEXTURE_2D_MULTISAMPLE_ARRAY,

  TexImageTarget* {.pure.} = enum
    TEXTURE_2D = GL_TEXTURE_2D,
    PROXY_TEXTURE_2D = GL_PROXY_TEXTURE_2D, #0x8064
    TEXTURE_RECTANGLE = GL_TEXTURE_RECTANGLE,
    PROXY_TEXTURE_RECTANGLE = GL_PROXY_TEXTURE_RECTANGLE,
    TEXTURE_CUBE_MAP_POSITIVE_X = GL_TEXTURE_CUBE_MAP_POSITIVE_X, #0x8515
    TEXTURE_CUBE_MAP_NEGATIVE_X = GL_TEXTURE_CUBE_MAP_NEGATIVE_X,
    TEXTURE_CUBE_MAP_POSITIVE_Y = GL_TEXTURE_CUBE_MAP_POSITIVE_Y,
    TEXTURE_CUBE_MAP_NEGATIVE_Y = GL_TEXTURE_CUBE_MAP_NEGATIVE_Y,
    TEXTURE_CUBE_MAP_POSITIVE_Z = GL_TEXTURE_CUBE_MAP_POSITIVE_Z,
    TEXTURE_CUBE_MAP_NEGATIVE_Z = GL_TEXTURE_CUBE_MAP_NEGATIVE_Z,
    PROXY_TEXTURE_CUBE_MAP = GL_PROXY_TEXTURE_CUBE_MAP
    TEXTURE_1D_ARRAY = GL_TEXTURE_1D_ARRAY,
    PROXY_TEXTURE1D_ARRAY = GL_PROXY_TEXTURE_1D_ARRAY, #0x8C19

  TexImageMultiSampleTarget* {.pure.} = enum
    TEXTURE_2D_MULTISAMPLE = GL_TEXTURE_2D_MULTISAMPLE,
    PROXY_TEXTURE_2D_MULTISAMPLE =  GL_PROXY_TEXTURE_2D_MULTISAMPLE

  TextureParameter* {.pure.} = enum
    TEXTURE_MAG_FILTER = GL_TEXTURE_MAG_FILTER,
    TEXTURE_MIN_FILTER = GL_TEXTURE_MIN_FILTER, #0x2801
    TEXTURE_WRAP_S = GL_TEXTURE_WRAP_S, #0x2802
    TEXTURE_WRAP_T = GL_TEXTURE_WRAP_T,
    TEXTURE_WRAP_R =  GL_TEXTURE_WRAP_R,
    TEXTURE_MIN_LOD = GL_TEXTURE_MIN_LOD, #0x813A
    TEXTURE_MAX_LOD = GL_TEXTURE_MAX_LOD,
    TEXTURE_BASE_LEVEL = GL_TEXTURE_BASE_LEVEL, #0x813C
    TEXTURE_MAX_LEVEL = GL_TEXTURE_MAX_LEVEL, #0x813D
    TEXTURE_LOD_BIAS = GL_TEXTURE_LOD_BIAS, #0x8501
    TEXTURE_COMPARE_MODE = GL_TEXTURE_COMPARE_MODE, #0x884C
    TEXTURE_COMPARE_FUNC = GL_TEXTURE_COMPARE_FUNC, # 0x884D
    TEXTURE_SWIZZLE_R = GL_TEXTURE_SWIZZLE_R, #0x8E42
    TEXTURE_SWIZZLE_G = GL_TEXTURE_SWIZZLE_G,
    TEXTURE_SWIZZLE_B = GL_TEXTURE_SWIZZLE_B,
    TEXTURE_SWIZZLE_A = GL_TEXTURE_SWIZZLE_A,
    DEPTH_STENCIL_TEXTURE_MODE = GL_DEPTH_STENCIL_TEXTURE_MODE #0x90EA

  TextureParameterV* {.pure.} = enum
    TEXTURE_BORDER_COLOR = GL_TEXTURE_BORDER_COLOR, #0x1004
    TEXTURE_MAG_FILTER = GL_TEXTURE_MAG_FILTER,
    TEXTURE_MIN_FILTER = GL_TEXTURE_MIN_FILTER, #0x2801
    TEXTURE_WRAP_S = GL_TEXTURE_WRAP_S, #0x2802
    TEXTURE_WRAP_T = GL_TEXTURE_WRAP_T,
    TEXTURE_WRAP_R =  GL_TEXTURE_WRAP_R,
    TEXTURE_MIN_LOD = GL_TEXTURE_MIN_LOD, #0x813A
    TEXTURE_MAX_LOD = GL_TEXTURE_MAX_LOD,
    TEXTURE_BASE_LEVEL = GL_TEXTURE_BASE_LEVEL, #0x813C
    TEXTURE_MAX_LEVEL = GL_TEXTURE_MAX_LEVEL, #0x813D
    TEXTURE_LOD_BIAS = GL_TEXTURE_LOD_BIAS, #0x8501
    TEXTURE_COMPARE_MODE = GL_TEXTURE_COMPARE_MODE, #0x884C
    TEXTURE_COMPARE_FUNC = GL_TEXTURE_COMPARE_FUNC, # 0x884D
    TEXTURE_SWIZZLE_R = GL_TEXTURE_SWIZZLE_R, #0x8E42
    TEXTURE_SWIZZLE_G = GL_TEXTURE_SWIZZLE_G,
    TEXTURE_SWIZZLE_B = GL_TEXTURE_SWIZZLE_B,
    TEXTURE_SWIZZLE_A = GL_TEXTURE_SWIZZLE_A,
    TEXTURE_SWIZZLE_RGBA = GL_TEXTURE_SWIZZLE_RGBA, #0x8E46
    DEPTH_STENCIL_TEXTURE_MODE = GL_DEPTH_STENCIL_TEXTURE_MODE #0x90EA

  TextureUnit* {.pure.} = enum
    TEXTURE0 = GL_TEXTURE_0,
    TEXTURE1 = GL_TEXTURE_1,
    TEXTURE2 = GL_TEXTURE_2,
    TEXTURE3 = GL_TEXTURE_3,
    TEXTURE4 = GL_TEXTURE_4,
    TEXTURE5 = GL_TEXTURE_5,
    TEXTURE6 = GL_TEXTURE_6,
    TEXTURE7 = GL_TEXTURE_7,
    TEXTURE8 = GL_TEXTURE_8,
    TEXTURE9 = GL_TEXTURE_9,
    TEXTURE10 = GL_TEXTURE_10,
    TEXTURE11 = GL_TEXTURE_11,
    TEXTURE12 = GL_TEXTURE_12,
    TEXTURE13 = GL_TEXTURE_13,
    TEXTURE14 = GL_TEXTURE_14,
    TEXTURE15 = GL_TEXTURE_15,
    TEXTURE16 = GL_TEXTURE_16,
    TEXTURE17 = GL_TEXTURE_17,
    TEXTURE18  = GL_TEXTURE_18,
    TEXTURE19 = GL_TEXTURE_19,
    TEXTURE20 = GL_TEXTURE_20,
    TEXTURE21  = GL_TEXTURE_21,
    TEXTURE22 = GL_TEXTURE_22,
    TEXTURE23 = GL_TEXTURE_23,
    TEXTURE24 = GL_TEXTURE_24,
    TEXTURE25 = GL_TEXTURE_25,
    TEXTURE26 = GL_TEXTURE_26,
    TEXTURE27 = GL_TEXTURE_27,
    TEXTURE28 = GL_TEXTURE_28,
    TEXTURE29 = GL_TEXTURE_29,
    TEXTURE30 = GL_TEXTURE_30,
    TEXTURE31 = GL_TEXTURE_31

  RenderBufferFormat* {.pure.} = enum
    RGBA8 = GL_RGBA8,
    RGB10_A2 = GL_RGB10_A2,
    RGBA16 = GL_RGBA16,
    DEPTH_COMPONENT16 = GL_DEPTH_COMPONENT16,
    DEPTH_COMPONENT24 = GL_DEPTH_COMPONENT24,
    R8 = GL_R8,
    R16 = GL_R16,
    RG8 = GL_RG8,
    RG16 = GL_RG16,
    R16F = GL_R16F,
    R32F = GL_R32F,
    RG16F = GL_RG16F,
    RG32F = GL_RG32F,
    R8I = GL_R8I,
    R8UI = GL_R8UI,
    R16I = GL_R16I,
    R16UI = GL_R16UI,
    R32I = GL_R32I,
    R32UI = GL_R32UI,
    RG8I = GL_RG8I,
    RG8UI = GL_RG8UI,
    RG16I = GL_RG16I,
    RG16UI = GL_RG16UI,
    RG32I = GL_RG32I,
    RG32UI = GL_RG32UI,
    GBA32F = GL_RGBA32F,
    RGBA16F = GL_RGBA16F,
    DEPTH24_STENCIL8 = GL_DEPTH24_STENCIL8,
    R11F_G11F_B10F = GL_R11F_G11F_B10F
    SRGB8_ALPHA8 = GL_SRGB8_ALPHA8,
    DEPTH_COMPONENT32F = GL_DEPTH_COMPONENT32F,
    DEPTH32F_STENCIL8 = GL_DEPTH32F_STENCIL8,
    RGBA32UI = GL_RGBA32UI,
    RGBA16UI = GL_RGBA16UI,
    RGBA8UI = GL_RGBA8UI,
    RGBA32I = GL_RGBA32I,
    RGBA16I = GL_RGBA16I,
    RGBA8I = GL_RGBA8I,
    RGB10_A2UI = GL_RGB10_A2UI,

  # Todo reconcile this with spec
  TextureInternalFormat* {.pure.} = enum
    DEPTH_COMPONENT = GL_DEPTH_COMPONENT, #0x1902
    RED = GL_RED, #0x1903
    RGB = GL_RGB,
    RGBA = GL_RGBA, #0x1908
    RG = GL_RG,
    DEPTH_STENCIL = GL_DEPTH_STENCIL, #0x84F9
    SRGB = GL_SRGB,
    SRGB_ALPHA = GL_SRGB_ALPHA
    #todo sized formats

  PixelDataFormat* {.pure.} = enum
    STENCIL_INDEX = GL_STENCIL_INDEX, #0x1901
    DEPTH_COMPONENT = GL_DEPTH_COMPONENT,
    RED = GL_RED,
    RGB = GL_RGB,
    RGBA = GL_RGBA,
    BGR = GL_BGR, #0x80E0
    BGRA = GL_BGRA, #0x80E1
    RG = GL_RG, #0x8227
    RG_INTEGER = GL_RG_INTEGER, #0x8228
    DEPTH_STENCIAL = GL_DEPTH_STENCIL,
    RED_INTEGER = GL_RED_INTEGER, #0x8D94
    RGB_INTERGER = GL_RGB_INTEGER, #0x8D98
    RGBA_INTEGER = GL_RGBA_INTEGER, #0x8D99
    BGR_INTEGER = GL_BGR_INTEGER,
    BGRA_INTEGER = GL_BGRA_INTEGER

  PixelDataType* {.pure.} = enum
    BYTE = cGL_BYTE, #0x1400
    UNSIGNED_BYTE = GL_UNSIGNED_BYTE, #0x1401
    SHORT =  cGL_SHORT, #0x1402
    UINSIGNED_SHORT = GL_UNSIGNED_SHORT, #0x1403
    INT = cGL_INT,#0x1404
    UNSIGNED_INT = GL_UNSIGNED_INT, #0x1405
    FLOAT = cGL_FLOAT, #0x1406
    UNSIGNED_BYTE_3_3_2 = GL_UNSIGNED_BYTE_3_3_2, #0x8032
    UNSIGNED_SHORT_4_4_4_4 = GL_UNSIGNED_SHORT_4_4_4_4, #0x8033
    UNSIGNED_SHORT_5_5_5_1 = GL_UNSIGNED_SHORT_5_5_5_1, #0x8034
    UNSIGNED_INT_8_8_8_8 = GL_UNSIGNED_INT_8_8_8_8,
    UNSIGNED_INT_10_10_10_2 = GL_UNSIGNED_INT_10_10_10_2,
    UNSIGNED_BYTE_2_3_3_REV = GL_UNSIGNED_BYTE_2_3_3_REV,
    UNSIGNED_SHORT_5_6_5 = GL_UNSIGNED_SHORT_5_6_5,
    UNSIGNED_SHORT_5_6_6_REV = GL_UNSIGNED_SHORT_5_6_5_REV,
    UNSIGNED_SHORT_4_4_4_4_REV = GL_UNSIGNED_SHORT_4_4_4_4_REV, #0x8365
    UNSIGNED_SHORT_1_5_5_5_REV = GL_UNSIGNED_SHORT_1_5_5_5_REV,
    UNSIGNED_INT_8_8_8_8_REV = GL_UNSIGNED_INT_8_8_8_8_REV,
    UNSIGNED_INT_2_10_10_10_REV = GL_UNSIGNED_INT_2_10_10_10_REV # 0x8368

  PolygonFace* {.pure.} = enum
    FRONT = GL_FRONT,
    BACK = GL_BACK,
    FRONT_AND_BACK = GL_FRONT_AND_BACK

  PolygonModeEnum* {.pure.} = enum
    POINT = GL_POINT,
    LINE = GL_LINE,
    FILL = GL_FILL

  BlitFilter* {.pure.} = enum
    NEAREST = GL_NEAREST
    LINEAR = GL_LINEAR

# convert between our types and OpenGL types
converter toGLuint*(v: BufferId): GLuint = GLuint(v)
converter toGLuint*(v: VertexArrayId): GLuint = GLuint(v)
converter toGLuint*(v: TextureId): GLuint = GLuint(v)
converter toGLuint*(v: ShaderId): GLuint = GLuint(v)
converter toGLuint*(v: ShaderProgramId): GLuint = GLuint(v)
converter toGLuint*(v: FrameBufferId): GLuint = GLuint(v)
converter toGLuint*(v: RenderBufferID): GLuint = GLuint(v)
converter toGLint*(v: TextureInternalFormat): GLint = GLint(v)
converter toGLint*(v: UniformLocation): GLint = GLint(v)
converter toGLint*(v: BlitFilter): GLint = GLint(v)
converter toGLenum*(v: ErrorType): GLenum = GLenum(v)
converter toGLenum*(v: Capability): GLenum = GLenum(v)
converter toGLenum*(v: Access): GLenum = GLenum(v)
converter toGLenum*(v: AlphaFunc): GLenum = GLenum(v)
converter toGLenum*(v: StencilOpEnum): GLenum = GLenum(v)
converter toGLenum*(v: BlendFactor): GLenum = GLenum(v)
converter toGLenum*(v: BlendEquationEnum): GLenum = GLenum(v)
converter toGLenum*(v: FaceMode): GLenum = GLenum(v)
converter toGLenum*(v: BufferTarget): GLenum = GLenum(v)
converter toGLenum*(v: BufferRangeTarget): GLenum = GLenum(v)
converter toGLenum*(v: FramebufferTarget): GLenum = GLenum(v)
converter toGLenum*(v: FramebufferStatus): GLenum = GLenum(v)
converter toGLenum*(v: FramebufferAttachment): GLenum = GLenum(v)
converter toGLenum*(v: BufferDataUsage): GLenum = GLenum(v)
converter toGLenum*(v: ShaderType): GLenum = GLenum(v)
converter toGLenum*(v: VertexAttribIType): GLenum = GLenum(v)
converter toGLenum*(v: VertexAttribType): GLenum = GLenum(v)
converter toGLenum*(v: DrawMode): GLenum = GLenum(v)
converter toGLenum*(v: BufferMask): GLenum = GLenum(v)
converter toGLenum*(v: IndexType): GLenum = GLenum(v)
converter toGLenum*(v: MipmapTarget): GLenum = GLenum(v)
converter toGLenum*(v: TextureTarget): GLenum = GLenum(v)
converter toGLenum*(v: FramebufferTextureTarget): GLenum = GLenum(v)
converter toGLenum*(v: TexImageTarget): GLenum = GLenum(v)
converter toGLenum*(v: TexImageMultiSampleTarget): GLenum = GLenum(v)
converter toGLenum*(v: TextureParameter): GLenum = GLenum(v)
converter toGLenum*(v: TextureParameterV): GLenum = GLenum(v)
converter toGLenum*(v: TextureUnit): GLenum = GLenum(v)
converter toGLenum*(v: RenderBufferFormat): GLenum = GLenum(v)
converter toGLenum*(v: TextureInternalFormat): GLenum = GLenum(v)
converter toGLenum*(v: PixelDataFormat): GLenum = GLenum(v)
converter toGLenum*(v: PixelDataType): GLenum = GLenum(v)
converter toGLenum*(v: PolygonFace): GLenum = GLenum(v)
converter toGLenum*(v: PolygonModeEnum): GLenum = GLenum(v)
converter toGLenum*(v: BlitFilter): GLenum = GLenum(v)
converter toGLint*(v: int): GLint = GLint(v)
converter toGLint*(v: int32): GLint = GLint(v)
converter toGLuint*(v: uint): GLuint = GLuint(v)
converter toGLbitfield*(v: uint): GLbitfield = GLbitfield(v)
converter toGLuint*(v: uint32): GLuint = GLuint(v)
converter toGLbitfield*(v: uint32): GLbitfield = GLbitfield(v)
converter toGLfloat*(v: float32): GLfloat = GLfloat(v)
converter toGLboolean*(v: bool): GLboolean = GLboolean(v)
converter toGLint*(v: bool): GLint = GLint(v)

# When passing objects to opengl you may need this to get a relative pointer
template offsetof*(typ, field): untyped = (var dummy: typ; cast[int](addr(dummy.field)) - cast[int](addr(dummy)))

# Deviate from opengl name here because GetError conflicts with SDL2
template getGLError*() : ErrorType =
  glGetError().ErrorType

template viewport*(x,y,width,height:int32) =
  glViewport(x,y,width,height)

template enable*(cap:Capability) =
  glEnable(cap)

template disable*(cap:Capability) =
  glDisable(cap)

template polygonMode*(face:PolygonFace, mode:PolygonModeEnum) =
  glPolygonMode(face, mode)

template depthMask*(flag: bool) =
  glDepthMask(flag)

template depthFunc*(fun: AlphaFunc) =
  glDepthFunc(fun)

template stencilMask*(mask:uint32)  =
  glStencilMask(mask)

template stencilFunc*(fun:AlphaFunc, reference: int32, mask:uint32) =
  glStencilFunc(fun, reference, mask)

template stencilFuncSeparate*(face:PolygonFace,fun:AlphaFunc, reference: int32, mask:uint32) =
  glStencilFuncSeparate(face, fun, reference, mask)

template stencilOp*(sfail: StencilOpEnum, dpfail: StencilOpEnum, dppass: StencilOpEnum) =
  glStencilOp(sfail, dpfail, dppass)

template stencilOpSeparate*(face:PolygonFace, sfail: StencilOpEnum, dpfail: StencilOpEnum, dppass: StencilOpEnum) =
  glStencilOpSeparate(face,sfail, dpfail, dppass)

template genFramebuffer*() : FramebufferId =
  var frameBuffer:GLuint
  glGenFramebuffers(1,addr frameBuffer)
  frameBuffer

template genFramebuffers*(count:int32) : seq[FramebufferId] =
  let frames = newSeq[FramebufferId](count)
  glGenFramebuffers(count,cast[ptr GLuint](buffers[0].unsafeAddr))
  frames

template bindFramebuffer*(target:FramebufferTarget, frameBuffer:FramebufferId) =
  glBindFramebuffer(target,frameBuffer)

template genBindFramebuffer*(target:FramebufferTarget) : FramebufferId =
  var framebuffer:GLuint
  glGenFramebuffers(1,addr framebuffer)
  glBindFramebuffer(target,framebuffer)
  frameBuffer.FramebufferId

template unBindFramebuffer*(target:FramebufferTarget) =
  glBindFramebuffer(target,0)

template checkFramebufferStatus*(target:FramebufferTarget) : FramebufferStatus =
  glCheckFramebufferStatus(target).FramebufferStatus

# todo: this has a lot of rules about what the arguments can be, see:
# https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/glFramebufferTexture.xhtml
# can we get compile time gaurantees on these?  asserts in debug mode maybe?
template framebufferTexture2D*(target:FramebufferTarget,
                              attachment:FramebufferAttachment,
                              textarget: FramebufferTextureTarget,
                              texture: TextureId,
                              level:int) =
  glFramebufferTexture2D(target,attachment,textarget,texture,level.int32)

template blitFramebuffer*(srcX0,srcY0,srcX1,srcY1,dstX0,dstY0,dstX1,dsyY1:int,masks:varargs[BufferMask],filter:BlitFilter) =
  var mask : uint32
  for m in masks:
      mask = mask or m.uint32
  glBlitFramebuffer(srcX0,srcY0,srcX1,srcY1,dstX0,dstY0,dstX1,dsyY1,mask,filter)

template deleteFramebuffers*(framebuffers:openarray[FramebufferId]) =
  glDeleteBuffers(framebuffers.len,cast[ptr GLUint](framebuffers[0].unsafeAddr))

template deleteFramebuffer*(framebuffer:FramebufferId) =
  glDeleteBuffers(1,framebuffer.addr)

template genRenderbuffer*() : RenderbufferId =
  var renderbuffer:GLuint
  glGenRenderBuffers(1, addr renderbuffer)
  renderbuffer.RenderbufferId

template genRenderbuffers*(count:int32) : seq[RenderbufferId] =
  let renderbuffers = newSeq[RenderbufferId](count)
  glGenRenderBuffers(count,cast[ptr GLuint](renderbuffers[0].unsafeAddr))
  renderbuffers

# target can only be GL_RENDERBUFFER so we don't both asking for it
template bindRenderbuffer*(renderbuffer:RenderbufferId) =
  glBindRenderBuffer(GL_RENDERBUFFER,renderbuffer)

template unBindRenderbuffer*() =
  glBindRenderBuffer(GL_RENDERBUFFER,0)

template genBindRenderBuffer*() : RenderbufferId =
  var renderbuffer:GLuint
  glGenRenderBuffers(1, addr renderbuffer)
  glBindRenderBuffer(GL_RENDERBUFFER,renderbuffer)
  renderbuffer.RenderbufferId

# renderbuffertarget must be GL_RENDERBUFFER so we don't ask for it
template framebufferRenderbuffer*(target:FramebufferTarget,
                                attachment: FramebufferAttachment,
                                renderbuffer:RenderbufferId) =
  glFramebufferRenderBuffer(target,attachment,GL_RENDERBUFFER,renderbuffer)


type RenderbufferSize* =  range[1..GL_MAX_RENDERBUFFER_SIZE.int]
template renderbufferStorage*(internalformat:RenderbufferFormat, width:RenderbufferSize,height:RenderbufferSize) =
  glRenderBufferStorage(GL_RENDERBUFFER,internalformat,width,height)

template renderbufferStorageMultisample*(samples:int,internalformat:RenderbufferFormat, width:RenderbufferSize,height:RenderbufferSize) =
  glRenderBufferStorageMultisample(GL_RENDERBUFFER,samples,internalformat,width,height)

template genBuffer*() : BufferId  =
  var buffer:GLuint
  glGenBuffers(1,addr buffer)
  buffer.BufferId

template genBuffers*(count:int32) : seq[BufferId] =
  let buffers = newSeq[BufferId](count)
  glGenBuffers(count,cast[ptr GLuint](buffers[0].unsafeAddr))
  buffers

template bindBuffer*(target:BufferTarget, buffer:BufferId)  =
  glBindBuffer(target,buffer)

template unBindBuffer*(target:BufferTarget) =
  glBindBuffer(target,0)

template genBindBuffer*(target:BufferTarget) : BufferId =
  var buffer : GLuint
  glGenBuffers(1,addr buffer)
  glBindBuffer(target,buffer)
  buffer.BufferId

template bindBufferRange*(target:BufferRangeTarget,index:uint32,buffer:BufferId, offset:int32, size:int) =
  glBindBufferRange(target,index,buffer,offsetptr,sizeptr)

template bufferData*[T](target:BufferTarget, data:openarray[T], usage:BufferDataUsage)  =
  glBufferData(target,GLsizeiptr(data.len*T.sizeof()),data[0].unsafeAddr,usage)

template bufferData*[T](target:BufferTarget,size:int, data:ptr T, usage:BufferDataUsage)  =
  glBufferData(target,sizeptr,cast[pointer](data),usage)

template bufferData*(target:BufferTarget,size:int,usage:BufferDataUsage) =
  glBufferData(target,sizeptr,nil,usage)

# bind and set buffer data in one go
template bindBufferData*[T](target:BufferTarget, buffer:BufferId, data:openarray[T], usage:BufferDataUsage)  =
  glBindBuffer(target,buffer)
  glBufferData(target,GLsizeiptr(data.len*T.sizeof()),data[0].unsafeAddr,usage)

# generate, bind, and set buffer data in one go
template genBindBufferData*[T](target:BufferTarget, data:openarray[T], usage:BufferDataUsage) :BufferId   =
  var buffer : GLuint
  glGenBuffers(1,addr buffer)
  glBindBuffer(target,buffer)
  glBufferData(target,GLsizeiptr(data.len*T.sizeof()),data[0].unsafeAddr,usage)
  buffer.BufferId

template deleteBuffer*(buffer:BufferId) =
  var b = buffer
  glDeleteBuffers(1,b.addr)

###################################################
###################################################
###################################################
###################################################
###################################################
###################################################
###################################################
###################################################
###################################################
###################################################
###################################################
###################################################
###################################################
###################################################
###################################################
###################################################
###################################################
###################################################
###################################################
###################################################
###################################################
###################################################
###################################################
###################################################
###################################################
###################################################
template deleteBuffers*(buffers:openArray[BufferId]) =
  let p = buffers[0]
  glDeleteBuffers(buffers.len,cast[ptr GLUint](p.unsafeAddr))

template bufferSubData*[T](target:BufferTarget,offset:int,size:int,data:openarray[T]) =
  glBufferSubData(target,offsetptr, sizeptr, data[0].unsafeAddr)

template copyBufferSubData*(readTarget:BufferTarget,
                          writeTarget:BufferTarget,
                          readOffset:int32,
                          writeOffset:int32,
                          size:int32) =
  glCopyBufferSubData(readTarget,writeTarget,readOffsetptr,writeOffsetptr,sizeptr)

template mapBuffer*[T](target:BufferTarget, access:Access) : ptr UncheckedArray[T] =
  cast[ptr UncheckedArray[T]](glMapBuffer(target, access))

template unmapBuffer*(target:BufferTarget) =
  glUnmapBuffer(target)

template genVertexArray*() : VertexArrayId  =
  var vao : GLuint
  when hostOS == "macosx":
    glGenVertexArraysAPPLE(1,addr vao)  
  else:
    glGenVertexArrays(1,addr vao)
  vao.VertexArrayId

# Gen and bind vertex array in one go
template genBindVertexArray*() : VertexArrayId =
  var vao : GLuint
  when hostOS == "macosx":
    glGenVertexArraysAPPLE(1,addr vao)
    glBindVertexArrayAPPLE(vao)
  else:
    glGenVertexArrays(1,addr vao)
    glBindVertexArray(vao)
  vao.VertexArrayId

template genVertexArrays*(count:int32) : seq[VertexArrayId]  =
  let vertexArrays = newSeq[VertexArrayId](count)
  when hostOS == "macosx":
    glGenVertexArraysAPPLE(count,cast[ptr GLuint](vertexArrays[0].unsafeAddr))
  else:
    glGenVertexArrays(count,cast[ptr GLuint](vertexArrays[0].unsafeAddr))
  vertexArrays

template bindVertexArray*(vertexArray:VertexArrayId)  =
  when hostOS == "macosx":
    glBindVertexArrayAPPLE(vertexArray)
  else:
    glBindVertexArray(vertexArray)

template unBindVertexArray*() =
  when hostOS == "macosx":
    glBindVertexArrayAPPLE(0)
  else:
    glBindVertexArray(0)

template deleteVertexArray*(vertexArray:VertexArrayId) =
  when hostOS == "macosx":
    glDeleteVertexArraysAPPLE(1,cast[ptr GLuint](vertexArray.unsafeAddr))
  else:
    glDeleteVertexArrays(1,cast[ptr GLuint](vertexArray.unsafeAddr))

template deleteVertexArrays*(vertexArrays:openArray[VertexArrayId]) =
  
  when hostOS == "macosx":
    glDeleteVertexArraysAPPLE(vertexArrays.len,cast[ptr GLUint](vertexArrays[0].unsafeAddr))
  else:
    glDeleteVertexArrays(vertexArrays.len,cast[ptr GLUint](vertexArrays[0].unsafeAddr))

template genTexture*() : TextureId =
  var tex : GLuint
  glGenTextures(1,addr tex)
  tex.TextureId

template genTextures*(count:int32) : seq[TextureId] =
  let textures = newSeq[TextureId](count)
  glGenTextures(count,cast[ptr GLuint](textures[0].unsafeAddr))
  textures

template genBindTexture*(target:TextureTarget) : TextureId =
  var tex : GLuint
  glGenTextures(1,addr tex)
  glBindTexture(target, tex)
  tex.TextureId

template bindTexture*(target:TextureTarget, texture:TextureId) =
  glBindTexture(target, texture)

template unBindTexture*(target:TextureTarget) =
  glBindTexture(target, 0)

template deleteTexture*(texture:TextureId) =
  glDeleteVertexArrays(1,cast[ptr GLuint](texture.unsafeAddr))

template deleteTextures*(texture:openArray[TextureId]) =
  glDeleteVertexArrays(texture.len,cast[ptr GLUint](texture[0].unsafeAddr))

template activeTexture*(texture:TextureUnit) =
  glActiveTexture(texture)

template texParameteri*(target:TextureTarget, pname:TextureParameter, param:GLint) =
  glTexParameteri(target,pname,param)

template texImage2D*[T](target:TexImageTarget, level:int32, internalFormat:TextureInternalFormat, width:int32, height:int32, format:PixelDataFormat, pixelType:PixelDataType, data: openArray[T] )  =
  glTexImage2D(target,level,internalFormat,width,height,0,format,pixelType,data[0].unsafeAddr)

# for cases where data is null, just don't pass it in
template texImage2D*(target:TexImageTarget, level:int32, internalFormat:TextureInternalFormat, width:int32, height:int32, format:PixelDataFormat, pixelType:PixelDataType) =
  glTexImage2D(target,level,internalFormat,width,height,0,format,pixelType,nil)

template texImage2DMultisample*(target:TexImageMultiSampleTarget,samples:int,internalformat:TextureInternalFormat,width:int,height:int,fixedsamplelocations:bool) =
  glTexImage2DMultisample(target,samples,internalformat,width,height,fixedsamplelocations)

template generateMipmap*(target:MipmapTarget) =
  glGenerateMipmap(target)

# Doesn't seem to exist on win10
#template GenerateTextureMipmap*(texture:TextureId) =
#    glGenerateTextureMipmap(texture)

template createShader*(shaderType:ShaderType) : ShaderId  =
  glCreateShader(shaderType).ShaderId

template shaderSource*(shader:ShaderId, src: string) =
  let cstr =  allocCStringArray([src])
  glShaderSource(shader, 1, cstr, nil)
  deallocCStringArray(cstr)

template compileShader*(shader:ShaderId)  =
  glCompileShader(shader)

template getShaderCompileStatus*(shader:ShaderId) : bool  =
  var r : GLint
  glGetShaderiv(shader,GL_COMPILE_STATUS,addr r)
  r.bool

template getShaderInfoLog*(shader:ShaderId) : string =
  var logLen : GLint
  glGetShaderiv(shader,GL_INFO_LOG_LENGTH, addr logLen)
  var logStr = cast[ptr GLchar](alloc(logLen))
  glGetShaderInfoLog(shader,logLen,addr logLen,logStr)
  $logStr

template detachShader*(program: ShaderProgramId, shader:ShaderId)  =
  glDetachShader(program, shader)

template deleteShader*(shader:ShaderId)  =
  glDeleteShader(shader)

template createProgram*() : ShaderProgramId  =
  glCreateProgram().ShaderProgramId

template deleteProgram*(program: ShaderProgramId)  =
  glDeleteProgram(program)

template attachShader*(program:ShaderProgramId, shader:ShaderId)  =
  glAttachShader(program,shader)

template linkProgram*(program:ShaderProgramId)  =
  glLinkProgram(program)

template getProgramLinkStatus*(program:ShaderProgramId) : bool  =
  var r : GLint
  glGetProgramiv(program,GL_LINK_STATUS,addr r)
  r.bool

template getProgramInfoLog*(program:ShaderProgramId) : string  =
  var logLen : GLint
  glGetProgramiv(program,GL_INFO_LOG_LENGTH, addr logLen)
  var logStr = cast[ptr GLchar](alloc(logLen))
  glGetProgramInfoLog(program,logLen,addr logLen,logStr)
  $logStr

template use*(program:ShaderProgramId)  =
  glUseProgram(program)

template getUniformLocation*(program: ShaderProgramId, name: string) : UniformLocation  =
  glGetUniformLocation(program,name).UniformLocation

template getUniformBlockIndex*(program:ShaderProgramId, uniformBlockName:string) : uint32 =
  glGetUniformBlockIndex(program,uniformBlockName)

template uniformBlockBinding*(program:ShaderProgramId, uniformBlockIndex:uint32, uniformBlockBinding:uint32) =
  glUniformBLockBinding(program, uniformBlockIndex, uniformBlockBinding)

template uniform1i*(location:UniformLocation, value: int32)   =
  glUniform1i(location,value)

template uniform1f*(location:UniformLocation,value: float32)   =
  glUniform1f(location,value)

template uniform2f*(location:UniformLocation,x:float32, y:float32)   =
  glUniform2f(location,x,y)

template uniform3f*(location:UniformLocation,x:float32, y:float32, z:float32)   =
  glUniform3f(location,x,y,z)

template uniform3fv*[T](location:UniformLocation,count:int,value:openarray[T]) =
  glUniform3fv(location,count,cast[ptr](value[0].unsafeAddr))

template uniform4f*(location:UniformLocation,x:float32, y:float32, z:float32, w:float32)   =
  glUniform4f(location,x,y,z, w)

template getAttribLocation*(program: ShaderProgramId, name: string): GLint  =
  glGetAttribLocation(program, name.cstring)

type VertexAttribSize = range[1..4]
template vertexAttribPointer*(index:uint32, size:VertexAttribSize, attribType:VertexAttribType, normalized:bool, stride:int, offset:int)  =
  glVertexAttribPointer(index, size, attribType, normalized,stride, cast[pointer](offset))

template enableVertexAttribArray*(index:uint32)  =
  glEnableVertexAttribArray(index)

# works only for non overlaping offsets
template vertexAttribSetup*[T : int8|uint8|int16|uint16|int32|uint32|float32|float](
  target:BufferTarget,
  data:openarray[T],
  usage:BufferDataUsage,
  normalized:bool,
  ranges:varargs[tuple[index:int,size:int]]) : tuple[vao:VertexArrayId,vbo:BufferId] =

  var vertexType : VertexAttribType
  when T is int8:
      vertexType = VertexAttribType.BYTE
  when T is uint8:
      vertexType = VertexAttribType.UNSIGNED_BYTE
  when T is int16:
      vertexType = VertexAttribType.SHORT
  when T is uint16:
      vertexType = VertexAttribType.UNSIGNED_SHORT
  when T is int32:
      vertexType = VertexAttribType.INT
  when T is uint32:
      vertexType = VertexAttribType.UNSIGNED_INT
  when T is float32:
      vertexType = VertexAttribType.FLOAT
  when T is float:
      vertexType = VertexAttribType.DOUBLE

  let vao = genBindVertexArray()
  let vbo = genBindBufferData(target,data,usage)

  var offset = 0
  var totalSize = 0
  for r in ranges:
      totalSize = totalSize + r.size
  for i,r in ranges:
      enableVertexAttribArray(i.uint32)
      vertexAttribPointer(r.index.uint32,r.size,vertexType,normalized,totalSize*T.sizeof(),offset*T.sizeof())
      offset = offset + r.size

  unBindVertexArray()
  (vao,vbo)

template vertexAttribDivisor*(index:uint32,divisor:uint32) =
  glVertexAttribDivisor(index,divisor)

template drawArrays*(mode:DrawMode, first:int32, count:int32)   =
  glDrawArrays(mode, first, count)

template drawArraysInstanced*(mode:DrawMode, first:int32, count:int32,primcount:int32) =
  glDrawArraysInstanced(mode, first, count,primcount)

template drawElements*[T](mode:DrawMode, count:int, indexType:IndexType, indices:openarray[T])  =
  glDrawElements(mode, count, indexType, indices[0].unsafeAddr)

template drawElementsInstanced*[T](mode:DrawMode, count:int, indexType:IndexType, indices:openarray[T],primcount:int)  =
  glDrawElementsInstanced(mode, count, indexType, indices[0].unsafeAddr,primcount)

template drawElementsInstanced*(mode:DrawMode, count:int, indexType:IndexType,primcount:int)  =
  glDrawElementsInstanced(mode, count, indexType, nil,primcount)

template drawElements*(mode:DrawMode, count:int, indexType:IndexType, offset:int) =
  glDrawElements(mode, count, indexType, cast[pointer](offset))

template clear*(buffersToClear:varargs[BufferMask])  =
  var mask : uint32
  for m in buffersToClear:
      mask = mask or m.uint32
  glClear(mask)

template clearColor*(r:float32, g:float32, b:float32, a:float32) =
  glClearColor(r, g, b, a)

template blendFunc*(sfactor: BlendFactor, dfactor: BlendFactor) =
  glBlendFunc(sfactor, dfactor)

template blendFunci*(buf:BufferId, sfactor: BlendFactor, dfactor: BlendFactor) =
  glBlendFunci(buf,sfactor, dfactor)

template blendFuncSeparate*(srcRGB: BlendFactor, dstRGB: BlendFactor,srcAlpha: BlendFactor,dstAlpha: BlendFactor) =
  glBlendFunc(srcRGB,dstRGB,srcAlpha,dstAlpha)

template blendFuncSeparatei*(buf: BufferId,srcRGB: BlendFactor, dstRGB: BlendFactor,srcAlpha: BlendFactor,dstAlpha: BlendFactor) =
  glBlendFunc(buf,srcRGB,dstRGB,srcAlpha,dstAlpha)

template blendEquation*(mode:BlendEquationEnum) =
  glBlendEquation(mode)

template blendEquationi*(buf:BufferId,mode:BlendEquationEnum) =
  glBlendEquation(buf,mode)

template cullFace*(face:PolygonFace) =
  glCullFace(face)

template frontFace*(mode:FaceMode) =
  glFrontFace(mode)

# Compiles and attaches in 1 step with error reporting
proc compileAndAttachShader*(shaderType:ShaderType, shaderPath: string, programId:ShaderProgramId) : ShaderId =
  let shaderId = createShader(shaderType)
  shaderSource(shaderId,readFile(shaderPath))
  compileShader(shaderId)
  if not getShaderCompileStatus(shaderId):
      echo "Shader Compile Error:"
      echo getShaderInfoLog(shaderId)
  else:
      attachShader(programId,shaderId)
  shaderId

# Handles everything needed to set up a shader, with error reporting
proc createAndLinkProgram*(vertexPath:string, fragmentPath:string, geometryPath:string = nil) : ShaderProgramId =
  let programId = createProgram()
  let vert = compileAndAttachShader(ShaderType.VERTEX_SHADER,vertexPath,programId)
  let frag = compileAndAttachShader(ShaderType.FRAGMENT_SHADER,fragmentPath,programId)
  let geo =
      if geometryPath != nil:
          compileAndAttachShader(ShaderType.GEOMETRY_SHADER,geometryPath,programId)
      else:
          0.ShaderId

  linkProgram(programId)

  if not getProgramLinkStatus(programId):
      echo "Link Error:"
      echo getProgramInfoLog(programId)

  deleteShader(vert)
  deleteShader(frag)
  if geometryPath != nil: deleteShader(geo)
  programId

# Uniform funcs with easier / shorter names and glm types
template setBool*(program:ShaderProgramId, name: string, value: bool) =
  glUniform1i(getUniformLocation(program,name),value)

template setInt*(program:ShaderProgramId, name: string, value: int32) =
  glUniform1i(getUniformLocation(program,name),value)

template setFloat*(program:ShaderProgramId, name: string, value: float32) =
  glUniform1f(getUniformLocation(program,name),value)

template setVec2*(program:ShaderProgramId, name: string, value:var Vec2f) =
  glUniform2fv(getUniformLocation(program,name),1,value.caddr)

template setVec2*(program:ShaderProgramId, name: string, x:float32, y:float32) =
  glUniform2f(getUniformLocation(program,name),x,y)

template setVec3*(program:ShaderProgramId, name: string, value:var Vec3f) =
  glUniform3fv(getUniformLocation(program,name),1,value.caddr)

template setVec3*(program:ShaderProgramId, name: string, x:float32, y:float32, z:float32) =
  glUniform3f(getUniformLocation(program,name),x,y,z)

template setVec4*(program:ShaderProgramId, name:string, value: var Vec4f) =
  glUniform4fv(getUniformLocation(program,name),1,value.caddr)

template setVec4*(program:ShaderProgramId, name: string, x:float32, y:float32, z:float32, w:float32) =
  glUniform4f(getUniformLocation(program,name),x,y,z,w)

template setMat4*(program:ShaderProgramId, name: string, value: var Mat4f ) =
  glUniformMatrix4fv(getUniformLocation(program,name),1,GL_FALSE,value.caddr)

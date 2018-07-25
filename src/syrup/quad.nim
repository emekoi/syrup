#
#  Copyright (c) 2018 emekoi
# 
#  This library is free software; you can redistribute it and/or modify it
#  under the terms of the MIT license. See LICENSE for details.
#

type Quad*[T] = tuple
  x, y, z, w: T

proc quad*[T](x, y, z, w: T): Quad[T] =
  (x, y, z, w)

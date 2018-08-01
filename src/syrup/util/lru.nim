##
##  Copyright (c) 2018 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import tables

type Cache*[A, B] = object
  ## a simple lru cache
  data: OrderedTable[A, B]
  capacity: int

proc newCache*[A, B](capacity: int): Cache[A, B] =
  result.capacity = capacity
  let size = tables.rightSize(capacity)
  result.data = tables.initOrderedTable[A, B](size)

proc hasKey*[A, B](cache: Cache[A, B], key: A): bool =
  cache.data.hasKey(key)

proc `[]`*[A, B](cache: Cache[A, B], key: A): B =
  cache.data[key]

proc `[]`*[A, B](cache: var Cache[A, B], key: A): var B =
  cache.data[key]

proc `[]=`*[A, B](cache: var Cache[A, B], key: A, value: B) =
  if (cache.data.len < cache.capacity) or cache.hasKey(key):
    cache.data[key] = value
  else:
    for key in cache.data.keys:
      cache.data.del(key)
      break
    cache.data[key] = value

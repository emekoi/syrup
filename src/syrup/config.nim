##
##  Copyright (c) 2017 emekoi
## 
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import 
  suffer

type
  Config* = tuple
    title: string
    w, h: int
    clear: Pixel
    fps: float

var _config = Config("syrup", 512, 512, color(255, 255, 255), 60.0)

proc `.title=`*(title: string) =
  _config.title = title

proc `.title`*(): string =
  _config.title

proc `.width=`*(width: int32) =
  _config.width = width

proc `.width`*(): int32 =
  _config.width
  
proc `.height=`*(height: int32) =
  _config.height = height

proc `.height`*(): int32 =
  _config.height
  
proc `.clear_color=`*(clear_color: Pixel) =
  _config.clear = clear_color

proc `.clear_color`*(): Pixel =
  _config.clear
  
proc `.fps=`*(fps: float32) =
  _config.fps = fps

proc `.fps`*(): float32 =
  _config.fps

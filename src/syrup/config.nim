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
    width, height: int32
    clear: Pixel
    fps: float

var SETTINGS* = (title: "syrup", width: 512'i32, height: 512'i32, clear: color(255, 255, 255), fps: 60.0)

converter toCString*(str: string): cstring = str.cstring
converter toCInt*(num: int32): cint = num.cint

proc get_config*(): Config = SETTINGS
proc set_config*(c: Config) = SETTINGS = c
proc get_title*(): string = SETTINGS.title
proc set_title*(title: string) = SETTINGS.title = title
proc get_width*(): int32 = SETTINGS.width
proc set_width*(width: int32) = SETTINGS.width = width
proc get_height*(): int32 = SETTINGS.height
proc set_height*(height: int32) = SETTINGS.height = height
proc get_clearColor*(): Pixel = SETTINGS.clear
proc set_clearColor*(clearColor: Pixel) = SETTINGS.clear = clearColor
proc get_fps*(): float = SETTINGS.fps
proc set_fps*(fps: float) = SETTINGS.fps = fps
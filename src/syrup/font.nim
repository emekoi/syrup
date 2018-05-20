##
##  Copyright (c) 2017 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import suffer, embed

let DEFAULT_FONT = newFontString(DEFAULT_FONT_DATA, DEFAULT_FONT_SIZE)

proc fromDefault*(ptsize: float): Font =
  newFontString(DEFAULT_FONT_DATA, ptsize)

proc fromDefault*(): Font = DEFAULT_FONT
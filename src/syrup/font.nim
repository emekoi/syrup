##
##  Copyright (c) 2017 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import suffer, embed

proc fontFromDefault*(ptsize: float=DEFAULT_FONT_SIZE): Font =
  newFontString(DEFAULT_FONT_DATA, ptsize)
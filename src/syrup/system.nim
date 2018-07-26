##
##  Copyright (c) 2018 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import sdl2/sdl, strutils

type
  EventType* = enum
    NONE
    QUIT
    RESIZE
    KEYDOWN
    KEYUP
    TEXTINPUT
    MOUSEMOVE
    MOUSEBUTTONDOWN
    MOUSEBUTTONUP

  Event* = object
    case id*: EventType
    of QUIT, NONE: discard
    of RESIZE: width*, height*: int
    of KEYDOWN, KEYUP: key*: string
    of TEXTINPUT: text*: string
    of MOUSEMOVE: x*, y*: int
    of MOUSEBUTTONDOWN, MOUSEBUTTONUP: press*: tuple[button: string, x, y: int]

  EventHandler* = proc(e: Event)

var eventHandlers: seq[EventHandler] = @[]

converter buttonStr(id: int): string =
  case id
  of sdl.BUTTON_LEFT: "left"
  of sdl.BUTTON_MIDDLE: "middle"
  of sdl.BUTTON_RIGHT: "right"
  of sdl.BUTTON_X1: "wheelup"
  of sdl.BUTTON_X2: "wheeldown"
  else: "?"

proc addEventHandler*(e: EventHandler) =
  if e notin eventHandlers:
    eventHandlers.add(e)

proc poll*(): seq[Event] =
  result = @[]
  var e: sdl.Event
  while sdl.pollEvent(addr(e)) != 0:
    var event: Event
    event.id = NONE
    case e.kind
    of sdl.QUIT:
      event.id = QUIT
    of sdl.WINDOWEVENT:
      if e.window.event == sdl.WINDOWEVENT_RESIZED:
        event = Event(id: RESIZE, width: e.window.data1, height: e.window.data2)
    of sdl.KEYDOWN:
        event = Event(id: KEYDOWN, key: ($sdl.getKeyName(e.key.keysym.sym)).toLowerAscii())
    of sdl.KEYUP:
        event = Event(id: KEYUP, key: ($sdl.getKeyName(e.key.keysym.sym)).toLowerAscii())
    of sdl.TEXTINPUT:
      event = Event(id: TEXTINPUT, text: $e.text.text)
    of sdl.MOUSEMOTION:
        event = Event(id: MOUSEMOVE, x: e.motion.x, y: e.motion.y)
    of sdl.MOUSEBUTTONDOWN:
        event = Event(id: MOUSEBUTTONDOWN, press: (buttonStr(e.button.button), e.button.x.int, e.button.y.int))
    of sdl.MOUSEBUTTONUP:
        event = Event(id: MOUSEBUTTONUP, press: (buttonStr(e.button.button), e.button.x.int, e.button.y.int))
    else: discard

    if event.id != NONE:
      result.add(event)

proc update*(e: Event) =
  for p in eventHandlers: p(e)
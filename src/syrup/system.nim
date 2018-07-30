##
##  Copyright (c) 2018 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import sdl2/sdl, strutils

type
  EventType* {.pure.} = enum
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
    of EventType.QUIT: discard
    of EventType.RESIZE: width*, height*: int
    of EventType.KEYDOWN, EventType.KEYUP: key*: string
    of EventType.TEXTINPUT: text*: string
    of EventType.MOUSEMOVE: x*, y*: int
    of EventType.MOUSEBUTTONDOWN, EventType.MOUSEBUTTONUP: press*: tuple[button: string, x, y: int]

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

iterator poll*(): Event =
  for event in sdl.events():
    case event.kind
      of sdl.QUIT:
        yield Event(id: EventType.QUIT)
      of sdl.WINDOWEVENT:
        if event.window.event == sdl.WINDOWEVENT_RESIZED:
          yield Event(id: EventType.RESIZE,
            width: event.window.data1,
            height: event.window.data2
          )
      of sdl.KEYDOWN:
        yield Event(id: EventType.KEYDOWN,
          key: ($sdl.getKeyName(event.key.keysym.sym)).toLowerAscii()
        )
      of sdl.KEYUP:
        yield Event(id: EventType.KEYUP,
          key: ($sdl.getKeyName(event.key.keysym.sym)).toLowerAscii()
        )
      of sdl.TEXTINPUT:
        yield Event(id: EventType.TEXTINPUT,
          text: $event.text.text
        )
      of sdl.MOUSEMOTION:
        yield Event(id: EventType.MOUSEMOVE,
          x: event.motion.x,
          y: event.motion.y
        )
      of sdl.MOUSEBUTTONDOWN:
        yield Event(id: EventType.MOUSEBUTTONDOWN,
          press: (
            buttonStr(event.button.button),
            event.button.x.int,
            event.button.y.int
          )
        )
      of sdl.MOUSEBUTTONUP:
        yield Event(id: EventType.MOUSEBUTTONUP,
          press: (
            buttonStr(event.button.button),
            event.button.x.int,
            event.button.y.int
          )
        )
      else:
        continue

proc update*(e: Event) =
  for p in eventHandlers: p(e)

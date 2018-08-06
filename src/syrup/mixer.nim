##
##  Copyright (c) 2018 emekoi
##
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import sdl2/sdl

{.passC: "-DCM_USE_STB_VORBIS".}

{.compile: "private/cmixer_impl.c".}
{.compile: "private/stb_vorbis.c".}

type
  cm_Source = ptr object

  Source* = ref cm_Source

  State* {.pure.} = enum
    STOPPED
    PLAYING
    PAUSED

  EventType* {.pure.} = enum
    LOCK
    UNLOCK
    DESTROY
    SAMPLES
    REWIND

  Event* = object
    kind*: EventType
    udata*: pointer
    msg*: cstring
    buffer*: ptr cshort
    length*: cint

  EventHandler* = proc (e: ptr Event) {.cdecl.}

  SourceInfo* = object
    handler*: EventHandler
    udata*: pointer
    samplerate*: cint
    length*: cint

proc newSource*(info: SourceInfo): Source
  ## @
# proc newSource*(filename: string): Source
proc newSource*(file: File): Source
  ## @
proc newSource*(data: pointer; size: int): Source
  ## @
proc newSource*(data: string): Source
  ## @
proc newSource*(data: openarray[uint8]): Source
  ## @
proc setLock*(lock: EventHandler)
  ## @
proc setMasterGain*(gain: float)
  ## @
proc getLength*(src: Source): float
  ## @
proc getPosition*(src: Source): float
  ## @
proc getState*(src: Source): State
  ## @
proc setGain*(src: Source; gain: float)
  ## @
proc setPan*(src: Source; pan: float)
  ## @
proc setPitch*(src: Source; pitch: float)
  ## @
proc setLoop*(src: Source, loop: bool)
  ## @
proc play*(src: Source)
  ## @
proc pause*(src: Source)
  ## @
proc stop*(src: Source)
  ## @

var
  inited = false
  device: AudioDeviceId

{.push cdecl, importc.}
proc cm_init(samplerate: cint)
proc cm_new_source(info: ptr SourceInfo): cm_Source
# proc cm_new_source_from_file(filename: cstring): cm_Source
proc cm_new_source_from_mem(data: pointer; size: cint): cm_Source
proc cm_destroy_source(src: cm_Source)
proc cm_get_error(): cstring
proc cm_process(dst: ptr cshort; len: cint)

proc cm_set_lock(lock: EventHandler)
proc cm_set_master_gain(gain: cdouble)
proc cm_get_length(src: cm_Source): cdouble
proc cm_get_position(src: cm_Source): cdouble
proc cm_get_state(src: cm_Source): cint
proc cm_set_gain(src: cm_Source; gain: cdouble)
proc cm_set_pan(src: cm_Source; pan: cdouble)
proc cm_set_pitch(src: cm_Source; pitch: cdouble)
proc cm_set_loop(src: cm_Source; loop: cint)
proc cm_play(src: cm_Source)
proc cm_pause(src: cm_Source)
proc cm_stop(src: cm_Source)
{.pop.}

converter toCSource(source: Source): cm_Source = source[]

proc finalizer(source: Source) =
  if not source.isNil:
    cm_destroy_source(source)

proc wrap(s: cm_Source): Source =
  if not inited:
    raise newException(
      Exception, "init() must be called before sources are created")

  if s == nil:
    raise newException(Exception, $cm_get_error())

  new(result, finalizer)
  result[] = s

proc newSource*(info: SourceInfo): Source =
  cm_new_source(unsafeAddr info).wrap()

# proc newSource*(filename: string): Source =
#   cm_new_source_from_file(filename).wrap()

proc newSource*(file: File): Source =
  newSource(file.readAll()).wrap()

proc newSource*(data: pointer; size: int): Source =
  result = cm_new_source_from_mem(data, int32(size)).wrap()

proc newSource*(data: string): Source =
  result = newSource(unsafeAddr data[0], data.len)

proc newSource*(data: openarray[uint8]): Source =
  result = newSource(unsafeAddr data[0], data.len)

proc setLock*(lock: EventHandler) =
  cm_set_lock(lock)

proc setMasterGain*(gain: float) =
  cm_set_master_gain(gain)

proc getLength*(src: Source): float =
  cm_get_length(src)

proc getPosition*(src: Source): float =
  cm_get_position(src)

proc getState*(src: Source): State =
  State(cm_get_state(src))

proc setGain*(src: Source; gain: float) =
  cm_set_gain(src, gain)

proc setPan*(src: Source; pan: float) =
  cm_set_pan(src, pan)

proc setPitch*(src: Source; pitch: float) =
  cm_set_pitch(src, pitch)

proc setLoop*(src: Source, loop: bool) =
  cm_set_loop(src, cint(loop))

proc play*(src: Source) =
  cm_play(src)

proc pause*(src: Source) =
  cm_pause(src)

proc stop*(src: Source) =
  cm_stop(src)

{.push stackTrace: off.}
proc audioCallback(userdata: pointer, stream: ptr uint8, len: cint) {.cdecl.} =
  cm_process(cast[ptr cshort](stream), len div 2)

proc lockHandler(e: ptr Event) {.cdecl.} =
  case e.kind:
  of EventType.LOCK: device.lockAudioDevice()
  of EventType.UNLOCK: device.unlockAudioDevice()
  else: discard
{.pop.}

proc deinit* {.noconv.} =
  assert(inited)
  closeAudioDevice(device)
  inited = false

proc init*(samplerate: int, buffersize: uint) =
  assert(not inited)

  if sdl.init(sdl.INIT_AUDIO) != 0:
    quit "ERROR: can't initialize SDL audio: " & $sdl.getError()

  var fmt, got: AudioSpec
  fmt.freq = cint(samplerate)
  fmt.format = AudioFormat(AUDIO_S16)
  fmt.channels = uint8(2)
  fmt.samples = uint16(buffersize)
  fmt.callback = audioCallback

  device = openAudioDevice(
    nil, 0, addr fmt, addr got,
    sdl.AUDIO_ALLOW_FREQUENCY_CHANGE)

  if device == 0:
    raise newException(Exception, $sdl.getError())

  cm_init(cint(got.freq))
  setLock(lockHandler)
  addQuitProc(deinit)

  device.pauseAudioDevice(0)
  inited = true

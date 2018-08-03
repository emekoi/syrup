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

var
  inited = false
  device: AudioDeviceId

{.push cdecl.}
proc cm_init(samplerate: cint) {.importc.}
proc cm_new_source(info: ptr SourceInfo): cm_Source {.importc.}
proc cm_new_source_from_file(filename: cstring): cm_Source {.importc.}
proc cm_new_source_from_mem(data: pointer; size: cint): cm_Source {.importc.}
proc cm_destroy_source(src: cm_Source) {.importc.}
proc cm_get_error(): cstring {.importc.}
proc cm_set_loop(src: cm_Source; loop: cint) {.importc.}
proc cm_process(dst: ptr cshort; len: cint) {.importc.}

proc setLock*(lock: EventHandler) {.importc: "cm_set_lock".}
proc setMasterGain*(gain: cdouble) {.importc: "cm_set_master_gain".}
proc getLength*(src: cm_Source): cdouble {.importc: "cm_get_length".}
proc getPosition*(src: cm_Source): cdouble {.importc: "cm_get_position".}
proc getState*(src: cm_Source): cint {.importc: "cm_get_state".}
proc setGain*(src: cm_Source; gain: cdouble) {.importc: "cm_set_gain".}
proc setPan*(src: cm_Source; pan: cdouble) {.importc: "cm_set_pan".}
proc setPitch*(src: cm_Source; pitch: cdouble) {.importc: "cm_set_pitch".}
proc play*(src: cm_Source) {.importc: "cm_play".}
proc pause*(src: cm_Source) {.importc: "cm_pause".}
proc stop*(src: cm_Source) {.importc: "cm_stop".}
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

proc newSourceFromFile*(filename: string): Source =
  cm_new_source_from_file(filename).wrap()

proc newSourceFromMem*(data: pointer; size: int): Source =
  result = cm_new_source_from_mem(data, int32(size)).wrap()

proc newSourceFromMem*(data: string): Source =
  result = newSourceFromMem(unsafeAddr data[0], data.len)

proc newSourceFromMem*(data: openarray[uint8]): Source =
  result = newSourceFromMem(unsafeAddr data[0], data.len)

proc setLoop*(src: cm_Source, loop: bool) =
  cm_set_loop(src, if loop: 1 else: 0)

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

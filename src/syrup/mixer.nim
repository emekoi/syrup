##
##  Copyright (c) 2017 emekoi
## 
##  This library is free software; you can redistribute it and/or modify it
##  under the terms of the MIT license. See LICENSE for details.
##

import sdl2/sdl

{.passl: "-lm".}
{.passc: "-DCM_USE_STB_VORBIS".}

{.compile: "private/cmixer_impl.c".}
{.compile: "private/stb_vorbis.c".}


type
  cm_Source = object

  Source* = ref object
    csource: ptr cm_Source
    data: ref RootObj

  Event* = object
    kind*: cint
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

const
  STATE_STOPPED* = 0
  STATE_PLAYING* = 1
  STATE_PAUSED* = 2

const
  EVENT_LOCK* = 0
  EVENT_UNLOCK* = 1
  EVENT_DESTROY* = 2
  EVENT_SAMPLES* = 3
  EVENT_REWIND* = 4

var
  inited = false
  device: AudioDeviceId

{.push cdecl.}
proc cm_init(samplerate: cint) {.importc.}
proc cm_new_source(info: ptr SourceInfo): ptr cm_Source {.importc.}
proc cm_new_source_from_file(filename: cstring): ptr cm_Source {.importc.}
proc cm_new_source_from_mem(data: pointer; size: cint): ptr cm_Source {.importc.}
proc cm_destroy_source(src: ptr cm_Source) {.importc.}
proc cm_get_error(): cstring {.importc.}
proc cm_set_loop(src: ptr cm_Source; loop: cint) {.importc.}

proc setLock*(lock: EventHandler) {.importc: "cm_set_lock".}
proc setMasterGain*(gain: cdouble) {.importc: "cm_set_master_gain".}
proc process*(dst: ptr cshort; len: cint) {.importc: "cm_process".}
proc getLength*(src: ptr cm_Source): cdouble {.importc: "cm_get_length".}
proc getPosition*(src: ptr cm_Source): cdouble {.importc: "cm_get_position".}
proc getState*(src: ptr cm_Source): cint {.importc: "cm_get_state".}
proc setGain*(src: ptr cm_Source; gain: cdouble) {.importc: "cm_set_gain".}
proc setPan*(src: ptr cm_Source; pan: cdouble) {.importc: "cm_set_pan".}
proc setPitch*(src: ptr cm_Source; pitch: cdouble) {.importc: "cm_set_pitch".}
proc play*(src: ptr cm_Source) {.importc: "cm_play".}
proc pause*(src: ptr cm_Source) {.importc: "cm_pause".}
proc stop*(src: ptr cm_Source) {.importc: "cm_stop".}
{.pop.}


converter toCSource*(source: Source): ptr cm_Source =
  source.csource


proc finalizer(source: Source) =
  if source.csource != nil:
    cm_destroy_source(source.csource)
  if source.data != nil:
    GC_unref(source.data)


proc wrap(s: ptr cm_Source): Source =
  if not inited:
    raise newException(
      Exception, "init() must be called before sources are created")

  if s == nil:
    raise newException(Exception, $cm_get_error())

  new(result, finalizer)
  result.csource = s


proc newSource*(info: SourceInfo): Source =
  var info = info
  cm_new_source(addr info).wrap()


proc newSourceFromFile*(filename: string): Source =
  cm_new_source_from_file(filename).wrap()


proc newSourceFromMem*(data: pointer; size: int): Source =
  result = cm_new_source_from_mem(data, int32(size)).wrap()


proc newSourceFromMem*(data: string): Source =
  var data = data
  result = newSourceFromMem(addr data[0], data.len)
  result.data = cast[ref RootObj](data)
  GC_ref(result.data)


proc newSourceFromMem*(data: seq[uint8]): Source =
  var data = data
  result = newSourceFromMem(addr data[0], data.len)
  result.data = cast[ref RootObj](data)
  GC_ref(result.data)


proc setLoop*(src: ptr cm_Source, loop: bool) =
  cm_set_loop(src, if loop: 1 else: 0)

{.push stackTrace: off.}
proc audioCallback(userdata: pointer, stream: ptr uint8, len: cint) {.cdecl.} =
  process(cast[ptr cshort](stream), len div 2)
{.pop.}


{.push stackTrace: off.}
proc lockHandler(e: ptr Event) {.cdecl.} =
  case e.kind:
  of EVENT_LOCK: device.lockAudioDevice()
  of EVENT_UNLOCK: device.unlockAudioDevice()
  else: discard
{.pop.}


proc init*(samplerate=44100, buffersize=1024) =
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

  device.pauseAudioDevice(0)
  inited = true


proc deinit* =
  closeAudioDevice(device)

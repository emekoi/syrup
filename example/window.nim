import ../src/syrup
import random

proc init(): Config =
  (title: "window", w: 512, h: 512, clear: color(255, 255, 255), fps: 60.0)

proc update(dt: float) =
  discard

proc draw(buf: Buffer) =
  drawText color(0, 0, 0), $syrup.timer.getFps(), 2, 0

run(init, update, draw)
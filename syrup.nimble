# Package

version       = "0.1.1"
author        = "emekoi"
description   = "a game engine"
license       = "MIT"
srcDir        = "src"
# Dependencies

requires "nim >= 0.18.0"
requires "sdl2_nim >= 2.0.7.0"

task docs, "generate documentation and place it in the docs folder":
  if not dirExists("docs"):
    mkDir("docs")
  for file in listFiles(srcDir):
    if file[^4..<file.len] == ".nim":
      exec "nimble doc2 -o:docs/" & file[4..^5] & ".html " & file


task example, "runs the included examples":
  for dir in listDirs("example"):
    for file in listFiles(dir):
      if file[^8..<file.len] == "main.nim":
        exec "nimble c -r --nimcache:example/nimcache " & file

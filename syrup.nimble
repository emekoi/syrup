# Package

version       = "0.1.0"
author        = "emekoi"
description   = "a game engine"
license       = "MIT"
srcDir        = "src"
# bin          = @["syrup"]
# Dependencies

requires "nim >= 0.17.2"
requires "suffer >= 0.1.0"
requires "sdl2_nim >= 2.0.7.0"
requires "opengl >= 1.1.0"
requires "glm >= 1.0.2"
requires "gifwriter 0.1.0"

task docs, "generate documentation and place it in the docs folder":
  mkDir "docs"
  for file in listFiles(srcDir):
    if file[^4..<file.len] == ".nim":
      exec "nimble doc2 -o:docs/" & file[4..^5] & ".html " & file


task example, "runs the included example":
  withDir "example":
    exec "nim c -r window.nim"

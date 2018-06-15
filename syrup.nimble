# Package

version       = "0.1.0"
author        = "emekoi"
description   = "a game engine"
license       = "MIT"
srcDir        = "src"
binDir        = "bin"
bin           = @["syrup"]

# Dependencies

requires "nim >= 0.17.2"
requires "glfw >= 0.3.1"
requires "opengl >= 1.1.0"
requires "glm >= 1.0.2"

# Tasks

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

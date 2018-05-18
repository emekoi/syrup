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

when defined(SYRUP_GL):
  --define:MODE_RGBA
elif hostOS == "linux":
  --define:MODE_ARGB  

task docs, "generate documentation and place it in the docs folder":
  if not dirExists("docs"):
    mkDir("docs")
  for file in listFiles(srcDir):
    if file[^4..<file.len] == ".nim":
      exec "nimble doc2 -o:docs/" & file[4..^5] & ".html " & file


task example, "runs the included examples":
  for dir in listDirs("example"):
    var
      resFile = ""
      mainFile = ""

    for file in listFiles(dir):
      if file[^3..<file.len] == ".rc":
        # resfile = file[0..<(file.len - 3)] & ".res"
        # exec "windres " & file & " -O coff -o " & resfile
        #var cmd = "nimble c -r --nimcache:example/nimcache --link:"
        #exec cmd & resFile & " " & mainFile
        var cmd = "nimble c -r --nimcache:example/nimcache "
        exec cmd & mainFile

      if file[^8..<file.len] == "main.nim":
        mainFile = file

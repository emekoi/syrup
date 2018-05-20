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


# import os

# template winRes*(resData: string) =
#     when defined(windows):
#       static:
#         const
#           filename = instantiationInfo().filename & ".res" 
#           cmd = quoteShell("windres -O coff -o " & filename)
#           # winresFile = gorgeEx("echo \"" & resData & "\" | " & cmd, "", NimVersion)
#           # data = gorgeEx("echo '" & resData & "'; out.res", "", NimVersion).output
#           # data = gorgeEx("eval \"echo 'hello' | cat\"", "", NimVersion).output
#         echo gorgeEx("sh -c \"echo '" & resData & "' | " & cmd & "\"", "", NimVersion)
#         echo "sh -c \"echo '" & resData & "' | " & cmd & "\""
#         {.link: filename.}
#     else:
#       discard

# winRes: """
#   nimicon ICON "nim.ico"
# """




# task example, "runs the included examples":
#   for dir in listDirs("example"):
#     var
#       resFile = ""
#       mainFile = ""

#     for file in listFiles(dir):
#       if file[^3..<file.len] == ".rc":
#         resfile = file[0..<(file.len - 3)] & ".res"
#         exec "windres " & file & " -O coff -o " & resfile
#         var cmd = "nimble c -r --nimcache:example/nimcache --link:"
#         exec cmd & resFile & " " & mainFile

#       if file[^8..<file.len] == "main.nim":
#         mainFile = file
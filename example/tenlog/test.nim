import os

template winRes*(resData: string) =
    when defined(windows):
      static:
        const
          filename = instantiationInfo().filename & ".res" 
          cmd = quoteShell("windres -O coff -o " & filename)
          # winresFile = gorgeEx("echo \"" & resData & "\" | " & cmd, "", NimVersion)
          # data = gorgeEx("echo '" & resData & "'; out.res", "", NimVersion).output
          # data = gorgeEx("eval \"echo 'hello' | cat\"", "", NimVersion).output
        echo gorgeEx("sh -c \"echo '" & resData & "' | " & cmd & "\"", "", NimVersion)
        echo "sh -c \"echo '" & resData & "' | " & cmd & "\""
        {.link: filename.}
    else:
      discard

winRes: """
  nimicon ICON "nim.ico"
"""
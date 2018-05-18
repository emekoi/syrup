template winRes*(resData: string) =
    when defined(windows):
      const
        filename = instantiationInfo().filename & ".res" 
        cmd = "windres -O coff -o " & filename 
        winresFile = gorgeEx("echo \"" & resData & "\" | " & cmd, "", NimVersion)
      echo resData & " | " & cmd, ""
      echo winresFile
      # {.link: filename.}
    else:
      discard


winRes: """
  nimicon ICON "nim.ico
""""
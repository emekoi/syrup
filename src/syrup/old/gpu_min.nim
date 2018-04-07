import sdl2/sdl, sdl2/sdl_gpu as gpu, os

var
  screen: Target
  running = true
  last = 0.0

proc main() =
  gpu.setDebugLevel(gpu.DEBUG_LEVEL_MAX)
  if sdl.init(sdl.INIT_EVERYTHING) != 0:
    quit "ERROR: can't initialize SDL video: " & $sdl.getError()
  
  # init sdl_gpu
  when defined(USE_GL2) or true:
    screen = gpu.initRenderer(gpu.RENDERER_OPENGL_2, 512, 512, gpu.INIT_DISABLE_VSYNC)
  else:
    screen = gpu.init(512, 512, gpu.INIT_DISABLE_VSYNC)

  let renderer = gpu.getCurrentRenderer()
  let id = renderer.id
  
  gpu.logInfo("\nusing renderer: %s (%d.%d)\n", id.name, id.major_version, id.minor_version)
  gpu.logInfo(" shader versions supported: %d to %d\n\n", renderer.min_shader_version, renderer.max_shader_version)

  while running:
    var e: sdl.Event
    while sdl.pollEvent(addr e) != 0:
      case e.kind
      of sdl.QUIT, sdl.KEYDOWN:
        running = false
      else: discard

    screen.clear()
    # drawing the screen
    screen.flip()

    let step = 1.0 / 60.0
    let now = sdl.getTicks().float / 1000.0
    let wait = step - (now - last);
    last += step
    if wait > 0:
      sleep((wait * 1000.0).int)
    else:
      last = now
  
  gpu.quit()
  
main()
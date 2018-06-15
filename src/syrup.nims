switch("define", "useRealtimeGC")

if not defined(release):
  switch("define", "SYRUP_DEBUG")

if buildOS == "macosx":
  switch("define", "glfwStaticLib")
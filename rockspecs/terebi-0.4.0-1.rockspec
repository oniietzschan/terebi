package = "terebi"
version = "0.4.0-1"
source = {
   url = "git://github.com/oniietzschan/terebi",
   tag = "0.4.0",
}
description = {
  summary = "Graphics scaling library for Love2D.",
  detailed = "A simple library to handle pixel-perfect scaling of window content in Love2D.",
  homepage = "https://github.com/oniietzschan/terebi",
  license = "MIT"
}
dependencies = {
  "lua >= 5.1",
  "love >= 0.10, < 0.11"
}
build = {
  type = "builtin",
  modules = {
    terebi = "terebi.lua"
  }
}

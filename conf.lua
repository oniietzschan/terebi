io.stdout:setvbuf("no")

SCALE  = 3
WIDTH  = 240
HEIGHT = 160

function love.conf(t)
  t.window = {
    title = "Terebi Demo",
    width  = WIDTH * SCALE,
    height = HEIGHT * SCALE,
    resizable = true,
    fullscreentype = 'desktop',
    highdpi = false,
  }
end

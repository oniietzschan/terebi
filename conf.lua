io.stdout:setvbuf("no")

function love.conf(t)
  t.window = {
    title = "Terebi Demo",
    width  = 240 * 3,
    height = 160 * 3,
    resizable = true,
    fullscreentype = 'desktop',
    highdpi = false,
  }
end

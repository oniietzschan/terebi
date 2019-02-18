local Terebi = require 'terebi'
local image
local quads = {}
local screen
local time = 0

local SCALE  = SCALE  or 3
local WIDTH  = WIDTH  or 240
local HEIGHT = HEIGHT or 160

function love.load(arg)
  -- Set nearest-neighbour scaling. Calling this is optional.
  Terebi.initializeLoveDefaults()

  -- Init graphics.
  image = love.graphics.newImage('demo/graphics.png')
  for i = 0, 1 do
    local quad = love.graphics.newQuad(WIDTH * i, 0, WIDTH, HEIGHT, image:getDimensions())
    table.insert(quads, quad)
  end

  -- Parameters: game width, game height, starting scale factor
  screen = Terebi.newScreen(WIDTH, HEIGHT, SCALE)
    -- This color will used for fullscreen letterboxing when content doesn't fit exactly. (Optional)
    :setBackgroundColor(0.25, 0.25, 0.25)
end

function love.keypressed(key)
  local isAltDown = love.keyboard.isDown('ralt') or love.keyboard.isDown('lalt')
  if     key == 'i' then
    screen:increaseScale()
  elseif key == 'd' then
    screen:decreaseScale()
  elseif key == 'f11' or (isAltDown and key == 'return') then
    screen:toggleFullscreen()
  end
end

function love.update(dt)
  time = time + dt
end

local function drawFn()
  local quadIndex = math.floor((time * 2.5) % #quads) + 1
  love.graphics.draw(image, quads[quadIndex], 0, 0)
end

function love.draw()
  screen:draw(drawFn) -- Additional arguments will be passed to drawFn.
end

function love.resize(w, h)
  screen:handleResize()
end

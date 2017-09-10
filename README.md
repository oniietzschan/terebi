terebi
======

[![Build Status](https://travis-ci.org/oniietzschan/terebi.svg?branch=master)](https://travis-ci.org/oniietzschan/terebi)
[![Codecov](https://codecov.io/gh/oniietzschan/terebi/branch/master/graph/badge.svg)](https://codecov.io/gh/oniietzschan/terebi)
[![Alex](https://img.shields.io/badge/alex-never_racist-brightgreen.svg)](http://alexjs.com/)

A simple library to handle pixel-perfect scaling of window content in Love2D.

Example
-------

```lua
local Terebi = require 'terebi'

function love.load(arg)
  -- Set nearest-neighbour scaling. Calling this is optional.
  Terebi.initializeLoveDefaults()

  -- Parameters: game width, game height, starting scale factor
  screen = Terebi.newScreen(320, 240, 2)
    -- This color will used for fullscreen letterboxing when content doesn't fit exactly. (Optional)
    :setBackgroundColor(64, 64, 64)
end

function love.keypressed(key)
  if     key == 'i' then
    screen:increaseScale()
  elseif key == 'd' then
    screen:decreaseScale()
  elseif key == 'f' then
    screen:toggleFullscreen()
  end
end

function love.draw()
  screen:draw(function()
    -- <Your drawing logic goes here.>
  end)
end



```

Additional Functionality
-------

```lua
-- Sets the scale factor.
screen:setScale(3)

-- Gets the current scale factor.
screen:getScale()

-- Sets scale to the largest factor which can fit on the current monitor.
screen:setMaxScale()
```

Todo
----

* Works with window resizing.
* High DPI scaling.

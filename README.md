terebi
======

[![Build Status](https://travis-ci.org/oniietzschan/terebi.svg?branch=master)](https://travis-ci.org/oniietzschan/terebi)
[![Codecov](https://codecov.io/gh/oniietzschan/terebi/branch/master/graph/badge.svg)](https://codecov.io/gh/oniietzschan/terebi)
![Love Versions](https://img.shields.io/badge/Love2d-11%2C%200.10-blue.svg)

A simple library to handle pixel-perfect scaling of window content in Love2D. Its features are:

* Simple interface for switching between fullscreen and windowed modes.
* Centers and letterboxes the view when scaled content does not exactly fit fullscreen resolution, with configurable letterbox color.
* HighDPI support with no additional code changes.
* A handful of utility functions for converting window coordinates to game coordinates, and vice versa.

Example
-------

```lua
local Terebi = require 'terebi'
local screen

function love.load(arg)
  -- Set nearest-neighbour scaling. Calling this is optional.
  Terebi.initializeLoveDefaults()

  -- Parameters: game width, game height, starting scale factor
  screen = Terebi.newScreen(320, 240, 2)
    -- This color will used for fullscreen letterboxing when content doesn't fit exactly. (Optional)
    :setBackgroundColor(0.25, 0.25, 0.25)
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

local function drawFn()
  -- <Your drawing logic goes here.>
end

function love.draw()
  screen:draw(drawFn) -- Additional arguments will be passed to drawFn.
end

function love.resize(w, h)
  screen:handleResize()
end
```

Additional Functionality
------------------------

```lua
-- Sets the scale factor.
screen:setScale(3)

-- Gets the current scale factor.
screen:getScale()

-- Sets scale to the largest factor which can fit on the current monitor.
screen:setMaxScale()

-- Gets the position of the mouse cursor in virtual screen (game) coordinates.
local mouseX, mouseY = screen:getMousePosition()

-- Converts window coordinates to virtual screen (game) coordinates.
local gameX, gameY = screen:windowToScreen(windowX, windowY)

-- Converts virtual screen (game) coordinates to window coordinates.
local windowX, windowY = screen:screenToWindow(gameX, gameY)
```

Installation
------------

The most simple way to install terebi is to simply copy `terebi.lua` into your game directory and `require 'terebi'`.

Todo
----

* Support rescaling after manual window resize. (love.resize, oh my god!!)
* Support the ability to start the game at the highest scale window which will fit on the screen.
  * "You can also prevent the window from being created before main.lua is loaded, by doing t.window = false in love.conf. You will need to call love.window.setMode before calling any love.graphics functions though."

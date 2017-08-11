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

  input = initializeSomeDopeAsHeckInputLibrary()
end

function love.update(dt)
  if input:pressed('i') then
    screen:increaseScale()
  end
  if input:pressed('d') then
    screen:decreaseScale()
  end
  if input:pressed('f') then
    screen:toggleFullscreen()
  end
end

function love.draw()
  screen:draw(function()
    -- <Your drawing logic goes here.>
  end)
end

```

Todo
----

* Works with maximize window controls
* High DPI scaling.
* Maximum scale should take window borders into consideration. (Unless borderless!)

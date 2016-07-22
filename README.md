terebi
======

A simple library to handle pixel-perfect scaling of window content in Love2D.

example
-------

    local Terebi = require 'terebi'

    function love.load(arg)
      -- Set nearest-neighbour scaling, disables mouse. Calling this is optional.
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
      lg.setCanvas(screen:getCanvas())

      -- Your drawing logic starts here.
      lg.setColor(150, 181 , 218)
      lg.rectangle('fill', 50, 50, 50, 50)
      -- Your drawing logic ends here.

      screen:draw()
    end

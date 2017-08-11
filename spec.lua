require 'busted'

local Terebi = require 'terebi'

local noop = function()
  return spy.new(function() end)
end

describe('Terebi:', function()
  before_each(function()
    _G.love = {
      graphics = {},
      window = {},
    }
    _G.love.graphics.newCanvas = spy.new(function(w, h)
      return {w, h}
    end)
    _G.love.window.getDesktopDimensions = spy.new(function()
      return 1600, 1200
    end)
    _G.love.window.getFullscreen = spy.new(function()
      return false
    end)
    _G.love.window.getMode = spy.new(function()
      return 640, 480, {'flags'}
    end)
  end)

  describe('When calling initializeLoveDefaults:', function()
    before_each(function()
      _G.love.graphics.setDefaultFilter = noop()
      _G.love.graphics.setLineStyle = noop()
    end)

    it('It should call correct love2d methods.', function()
      Terebi.initializeLoveDefaults()

      assert.spy(love.graphics.setDefaultFilter).was.called_with('nearest', 'nearest')
      assert.spy(love.graphics.setLineStyle).was.called_with('rough')
    end)
  end)

  describe('When creating a new Screen:', function()
    it('It should have correct default attributes', function()
      local screen = Terebi.newScreen(320, 240, 2)

      assert.spy(love.graphics.newCanvas).was.called_with(320, 240)

      assert.are.same({0, 0, 0}, screen._backgroundColor)
      assert.are.same(320, screen._width)
      assert.are.same(240, screen._height)
      assert.are.same(2, screen._scale)
      assert.are.same(2, screen._savedScale)
    end)

    it('It should throw an error when passed invalid parameters', function()
      assert.error(function() Terebi.newScreen(nil, 240, 2) end)
      assert.error(function() Terebi.newScreen(320, nil, 2) end)
      assert.error(function() Terebi.newScreen(320, 240, nil) end)
    end)
  end)

  describe('When calling Screen methods:', function()
    local screen

    before_each(function()
      screen = Terebi.newScreen(320, 240, 2)
    end)

    describe('When calling setBackgroundColor:', function ()
      it('setBackgroundColor should set background color', function()
        screen:setBackgroundColor(10, 20, 30)
        assert.are.same({10, 20, 30}, screen._backgroundColor)
      end)

      it('setBackgroundColor should throw an error when passed non-numbers', function()
        assert.error(function() screen:setBackgroundColor(nil, 1, 1) end)
        assert.error(function() screen:setBackgroundColor(1, nil, 1) end)
        assert.error(function() screen:setBackgroundColor(1, 1, nil) end)
      end)
    end)

    it('getScale should return scale', function()
      assert.are.same(2, screen:getScale())
    end)

    describe('When changing Screen scale:', function()
      before_each(function()
        _G.love.window.setMode = noop()
      end)

      describe('When calling setScale:', function ()
        it('setScale should set the scale', function()
          screen:setScale(1)

          assert.are.same(1, screen._scale)
          assert.spy(love.window.setMode).was.called_with(320, 240, {'flags'})
        end)

        it('setScale should set floor the scale when it is a non-integer', function()
          screen:setScale(1.5)

          assert.are.same(1, screen._scale)
          assert.spy(love.window.setMode).was.called_with(320, 240, {'flags'})
        end)

        it('setScale should set scale to 1 when passed a number below 1', function()
          screen:setScale(0)

          assert.are.same(1, screen._scale)
          assert.spy(love.window.setMode).was.called_with(320, 240, {'flags'})
        end)

        it('setScale should throw an error when passed a non-number', function()
          assert.error(function() screen:setScale(nil) end)
        end)
      end)

      describe('When calling increaseScale:', function ()
        it('increaseScale should set the scale', function()
          screen:increaseScale()

          assert.are.same(3, screen._scale)
          assert.spy(love.window.setMode).was.called_with(960, 720, {'flags'})
        end)

        it('increaseScale should not set scale above maximum scale', function()
          screen
            :setScale(5)
            :increaseScale()

          assert.are.same(5, screen._scale)
          assert.spy(love.window.setMode).was.called_with(1600, 1200, {'flags'})
        end)
      end)

      describe('When calling decreaseScale:', function ()
        it('decreaseScale should set the scale', function()
          screen:decreaseScale()

          assert.are.same(1, screen._scale)
          assert.spy(love.window.setMode).was.called_with(320, 240, {'flags'})
        end)

        it('decreaseScale should not set scale below 1', function()
          screen
            :setScale(1)
            :decreaseScale()

          assert.are.same(1, screen._scale)
          assert.spy(love.window.setMode).was.called_with(320, 240, {'flags'})
        end)
      end)

      describe('When calling setMaxScale:', function ()
        it('setMaxScale should set the scale', function()
          screen:setMaxScale()

          assert.are.same(5, screen._scale)
          assert.spy(love.window.setMode).was.called_with(1600, 1200, {'flags'})
        end)
      end)

      describe('When calling toggleFullscreen:', function ()
        it('toggleFullscreen should toggle fullscreen and maximize scale', function()
          _G.love.window.setFullscreen = noop()

          screen:toggleFullscreen()

          assert.are.same(5, screen._scale)
          assert.spy(love.window.setMode).was.called_with(1600, 1200, {'flags'})
          assert.spy(love.window.setFullscreen).was.called_with(true)
        end)

        it('toggleFullscreen should restore scale when toggled on then off', function()
          local isFullscreen = false
          _G.love.window.setFullscreen = spy.new(function(val)
            -- When exiting fullscreen, love will change the window res to the fullscreen res.
            if val == false and isFullscreen == true then
              _G.love.window.getMode = spy.new(function()
                return 1600, 1200, {'flags'}
              end)
            end
            isFullscreen = val
          end)
          _G.love.window.getFullscreen = spy.new(function()
            return isFullscreen
          end)

          screen
            :toggleFullscreen()
            :toggleFullscreen()

          assert.are.same(2, screen._scale)
          assert.are.same(false, isFullscreen)
          assert.spy(love.window.setMode).was.called_with(640, 480, {'flags'})
          assert.spy(love.window.setFullscreen).was.called(2)
        end)
      end)
    end)

    describe('When calling draw:', function ()
      local originalCanvas
      local terebiCanvas
      local drawSpy
      local drawFunc

      before_each(function()
        originalCanvas = {id = 'originalCanvas'}
        terebiCanvas = screen._canvas

        _G.love.graphics.getCanvas = spy.new(function()
          return originalCanvas
        end)
        _G.love.graphics.setCanvas = noop()
        _G.love.graphics.clear = noop()
        _G.love.graphics.draw = noop()

        drawSpy = noop()
        drawFunc = function(...) drawSpy(...) end
      end)

      it('should draw to canvas', function()
        screen:draw(drawFunc, 'arg1', 'arg2')

        assert.spy(love.graphics.setCanvas).was.called(2)
        assert.spy(love.graphics.setCanvas).was.called_with(terebiCanvas)
        assert.spy(love.graphics.clear).was.called()
        assert.spy(drawSpy).was.called_with('arg1', 'arg2')
        assert.spy(love.graphics.setCanvas).was.called_with(originalCanvas)
        assert.spy(love.graphics.draw).was.called_with(terebiCanvas, 0, 0, 0, 2, 2)
      end)

      it('should draw background when screen would have letterboxing', function()
        _G.love.graphics.getColor = spy.new(function()
          return 10, 20, 30, 255
        end)
        _G.love.graphics.getDimensions = spy.new(function()
          return 640, 480
        end)
        _G.love.graphics.rectangle = noop()
        _G.love.graphics.setColor = noop()

        screen._scale = 1
        screen._drawOffsetX = 160
        screen._drawOffsetY = 120
        screen:draw(drawFunc, 'arg1', 'arg2')

        assert.spy(love.graphics.setCanvas).was.called(2)
        assert.spy(love.graphics.setCanvas).was.called_with(terebiCanvas)
        assert.spy(love.graphics.clear).was.called()
        assert.spy(drawSpy).was.called_with('arg1', 'arg2')
        assert.spy(love.graphics.setCanvas).was.called_with(originalCanvas)
        assert.spy(love.graphics.getColor).was.called()
        assert.spy(love.graphics.getDimensions).was.called()
        assert.spy(love.graphics.rectangle).was.called_with('fill', 0, 0, 640, 480)
        assert.spy(love.graphics.setColor).was.called_with(10, 20, 30)
        assert.spy(love.graphics.draw).was.called_with(terebiCanvas, 160, 120, 0, 1, 1)
      end)

      it('should throw error when draw function is not provided', function()
        assert.error(function() screen:draw() end)
      end)
    end)
  end)
end)

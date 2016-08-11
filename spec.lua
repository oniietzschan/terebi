require 'busted'

local Terebi = require 'terebi'

local noop = function()
  return function() end
end

_G.love = {
  graphics = {
    setDefaultFilter = noop(),
    setLineStyle = noop(),
  },
  mouse = {
    setVisible = noop(),
  },
  window = {
  },
}

describe('Terebi:', function()
  describe('When calling initializeLoveDefaults:', function()
    it('It should call correct love2d methods.', function()
      spy.on(love.graphics, 'setDefaultFilter')
      spy.on(love.graphics, 'setLineStyle')
      spy.on(love.mouse, 'setVisible')

      Terebi.initializeLoveDefaults()

      assert.spy(love.graphics.setDefaultFilter).was.called_with('nearest', 'nearest')
      assert.spy(love.graphics.setLineStyle).was.called_with('rough')
      assert.spy(love.mouse.setVisible).was.called_with(false)
    end)
  end)
end)
local Terebi = {
  _VERSION     = 'terebi v0.4.0',
  _URL         = 'https://github.com/oniietzschan/terebi',
  _DESCRIPTION = 'Graphics scaling library for Love2D.',
  _LICENSE     = [[
    Massachusecchu... あれっ！ Massachu... chu... chu... License!

    Copyright (c) 1789 Retia Adolf

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED 【AS IZ】, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE. PLEASE HAVE A FUN AND BE GENTLE WITH THIS SOFTWARE.
  ]]
}



function Terebi.initializeLoveDefaults()
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.graphics.setLineStyle('rough')
end



local Screen = {}
local ScreenMetaTable = {__index = Screen}

function Terebi.newScreen(...)
  return setmetatable({}, ScreenMetaTable)
    :initialize(...)
end

function Screen:initialize(width, height, scale)
  assert(type(width) == 'number')
  assert(type(height) == 'number')
  assert(type(scale) == 'number')

  self._width = width
  self._height = height
  self._canvas = love.graphics.newCanvas(width, height)

  return self
    :setBackgroundColor(0, 0, 0)
    :setScale(scale)
    :_saveScale()
end

function Screen:setBackgroundColor(r, g, b)
  assert(type(r) == 'number')
  assert(type(g) == 'number')
  assert(type(b) == 'number')

  self._backgroundColor = {r, g, b}

  return self
end

function Screen:getScale()
  return self._scale
end

function Screen:setScale(scale)
  assert(type(scale) == 'number')

  self._scale = math.floor(math.max(1, math.min(scale, self:_getMaxScale())))

  return self
    :_resizeWindow()
    :_updateDrawOffset()
end

function Screen:_resizeWindow()
  local currentW, currentH, flags = love.window.getMode()
  local newW, newH = love.window.fromPixels(self._width * self._scale, self._height * self._scale)
  if not love.window.getFullscreen() and (currentW ~= newW or currentH ~= newH) then
    love.window.setMode(newW, newH, flags)
  end

  return self
end

function Screen:_saveScale()
  self._savedScale = self._scale

  return self
end

function Screen:_restoreScale()
  return self:setScale(self._savedScale)
end

function Screen:increaseScale()
  return self
    :setScale(self._scale + 1)
    :_saveScale()
end

function Screen:decreaseScale()
  return self
    :setScale(self._scale - 1)
    :_saveScale()
end

function Screen:toggleFullscreen()
  if love.window.getFullscreen() then
    love.window.setFullscreen(false)
    self:_restoreScale()

  else
    self:_saveScale()
    love.window.setFullscreen(true)
    self
      :setMaxScale()
      :_updateDrawOffset()
  end

  return self
end

function Screen:setMaxScale()
  return self:setScale(self:_getMaxScale())
end

function Screen:_getMaxScale()
  local desktopW, desktopH = self:_getDesktopDimensions()
  local maxScaleX = math.floor(desktopW / self._width)
  local maxScaleY = math.floor(desktopH / self._height)

  return math.min(maxScaleX, maxScaleY)
end

function Screen:_updateDrawOffset()
  if love.window.getFullscreen() then
    -- When fullscreen, center screen on monitor
    local desktopW, desktopH = self:_getDesktopDimensions()
    local scaledWidth  = self._width * self._scale
    local scaledHeight = self._height * self._scale
    self._drawOffsetX = math.floor((desktopW - scaledWidth) / 2)
    self._drawOffsetY = math.floor((desktopH - scaledHeight) / 2)

  else
    self._drawOffsetX = 0
    self._drawOffsetY = 0
  end

  return self
end

function Screen:_getDesktopDimensions()
  return love.window.toPixels(love.window.getDesktopDimensions())
end

function Screen:draw(drawFunc, ...)
  assert(type(drawFunc) == 'function', type(drawFunc))

  love.graphics.push('all')
  love.graphics.setCanvas(self._canvas)
  love.graphics.clear()
  drawFunc(...)
  love.graphics.pop()

  -- Draw background if it would be visible
  if self._drawOffsetX ~= 0 or self._drawOffsetY ~= 0 then
    local r, g, b = love.graphics.getColor()
    love.graphics.setColor(unpack(self._backgroundColor))
    love.graphics.rectangle('fill', 0, 0, love.graphics.getDimensions())
    love.graphics.setColor(r, g, b)
  end
  -- Draw screen
  love.graphics.draw(self._canvas, self._drawOffsetX, self._drawOffsetY, 0, self._scale, self._scale)

  return self
end

function Screen:getMousePosition()
  return self:windowToScreen(love.mouse.getPosition())
end

function Screen:windowToScreen(x, y)
  assert(type(x) == 'number')
  assert(type(y) == 'number')

  return (x - self._drawOffsetX) / self._scale,
         (y - self._drawOffsetY) / self._scale
end

function Screen:screenToWindow(x, y)
  assert(type(x) == 'number')
  assert(type(y) == 'number')

  return x * self._scale + self._drawOffsetX,
         y * self._scale + self._drawOffsetY
end



return Terebi

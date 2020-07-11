--[[

terebi v2.1.0
=============

Resolution scaling for pixel perfectionist in Love2D, by shru.

https://github.com/oniietzschan/terebi

License
-------

shru-chan hereby dedicates this source code and associated documentation
(the "App") to the public domain. shru makes this dedication for the
benefit of the Gamers everywhere and to the detriment of trolls and bullies.
Anyone is free to copy, modify, publish, use, sell, distribute, recite in a
spooky voice, or fax the App by any means they desire, so long as they
adhere to one condition:

Please consider buying shru some ice cream. Azuki preferred, but all
flavours except Licorice will be accepted.

In jurisdictions that do not: (a) recognize donation of works to the public
domain; nor (b) consider incitement to be a legally enforcable crime: shru
advocates immediate forceful regime-change.

--]]

local FLOAT = 'float'
local INTEGER = 'integer'

local SCALING_SHADER_GSGL = [[
number phase = 0.0001;
extern number edge;
extern number width;
extern number height;
vec4 effect(vec4 c, Image tex, vec2 tc, vec2 sc) {
  // For some reason offsetting the position slightly in both directions produces more consistent results.
  // I don't totally understand why this is necessary, but it probably has to do with fuzzy float comparisons.
  tc.x = tc.x + phase;
  tc.y = tc.y + phase;
  c = Texel(tex, tc);
  vec2 locationWithinTexel = vec2(
    fract(tc.x * width),
    fract(tc.y * height)
  );
  if (locationWithinTexel.x > edge) { // Horizontal Border
    vec2 neighbourCoords = vec2(tc.x + (1 / width), tc.y);
    c += Texel(tex, neighbourCoords);
    if (locationWithinTexel.y > edge) { // Diagonal Border
      neighbourCoords = vec2(tc.x, tc.y + (1 / height));
      c += Texel(tex, neighbourCoords);
      neighbourCoords = vec2(tc.x + (1 / width), tc.y + (1 / height));
      c += Texel(tex, neighbourCoords);
      c /= 4;
    } else {  // Strictly Horizontal Border
      c /= 2;
    }
  } else if (locationWithinTexel.y > edge) { // Strictly Vertical Border
    vec2 neighbourCoords = vec2(tc.x, tc.y + (1 / height));
    c += Texel(tex, neighbourCoords);
    c /= 2;
  }
  return c;
}
]]

local Terebi = {}

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
  assert(type(scale) == 'number')

  self._shader = love.graphics.newShader(SCALING_SHADER_GSGL)

  return self
    :setMode(FLOAT)
    :setBackgroundColor(0, 0, 0)
    :setDimensions(width, height, scale)
end

function Screen:setMode(mode)
  assert(mode == FLOAT or mode == INTEGER, 'mode must be "float" or "integer", got: ' .. tostring(mode))
  self._mode = mode
  return self
end

function Screen:getDimensions()
  return self._width, self._height
end

function Screen:setDimensions(width, height, scale, isSkipWindowResize)
  assert(type(width) == 'number')
  assert(type(height) == 'number')
  scale = scale or self._scale

  self._width = width
  self._height = height
  self._canvas = love.graphics.newCanvas(width, height)

  self._shader:send("width", self._width)
  self._shader:send("height", self._height)

  return self
    :setScale(scale, isSkipWindowResize)
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

function Screen:setScale(scale, isSkipWindowResize)
  assert(type(scale) == 'number')

  self._scale = math.max(1, math.min(scale, self:_getMaxScale()))
  if self._mode == INTEGER then
    self._scale = math.floor(self._scale)
  end

  self._shader:send("edge", 1 - (0.5 / self._scale))

  if isSkipWindowResize ~= true then
    self:_resizeWindow()
  end
  return self:_updateDrawOffset()
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

function Screen:increaseScale(isSkipWindowResize)
  return self
    :setScale(self._scale + 1, isSkipWindowResize)
    :_saveScale()
end

function Screen:decreaseScale(isSkipWindowResize)
  return self
    :setScale(self._scale - 1, isSkipWindowResize)
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

function Screen:handleResize()
  local skipResize = love.window.isMaximized()
  return self
    :setScale(self:_getMaxScaleForWindow(), skipResize)
end

function Screen:_getMaxScaleForWindow()
  local w, h = love.window.getMode()
  return self:_getMaxScaleForDimensions(w, h)
end

function Screen:_getMaxScaleForDimensions(w, h)
  local maxScaleX = w / self._width
  local maxScaleY = h / self._height
  if self._mode == INTEGER then
    maxScaleX = math.floor(maxScaleX)
    maxScaleY = math.floor(maxScaleY)
  end

  return math.min(maxScaleX, maxScaleY)
end

function Screen:_updateDrawOffset()
  local w, h = love.window.getMode()
  local scaledWidth  = self._width * self._scale
  local scaledHeight = self._height * self._scale
  self._drawOffsetX = math.floor((w - scaledWidth) / 2)
  self._drawOffsetY = math.floor((h - scaledHeight) / 2)

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
  local isNonIntegerScale = math.floor(self._scale) ~= self._scale
  if isNonIntegerScale then
    love.graphics.setShader(self._shader)
  end
  love.graphics.draw(self._canvas, self._drawOffsetX, self._drawOffsetY, 0, self._scale, self._scale)
  if isNonIntegerScale then
    love.graphics.setShader()
  end

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

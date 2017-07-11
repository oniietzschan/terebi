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
  self._width = width
  self._height = height
  self._canvas = love.graphics.newCanvas(width, height)

  return self
    :setScale(scale)
    :_saveScale()
end

function Screen:getScale()
  return self._scale
end

function Screen:setScale(scale)
  local desktopW, desktopH = love.window.getDesktopDimensions()
  if scale <= 0 or (self._width * scale > desktopW) or (self._height * scale > desktopH) then
    return self
  end

  self._scale = scale

  return self
    :_resizeWindow()
    :_updateDrawOffset()
end

function Screen:_resizeWindow()
  local currentW, currentH, flags = love.window.getMode()
  local newW = self._scale * self._width
  local newH = self._scale * self._height
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
    self
      :_saveScale()
      :setMaxScale()
    love.window.setFullscreen(true)
    self:_updateDrawOffset()
  end

  return self
end

function Screen:setMaxScale()
  local desktopW, desktopH = love.window.getDesktopDimensions()
  local maxScaleX = math.floor(desktopW / self._width)
  local maxScaleY = math.floor(desktopH / self._height)
  local scale = math.min(maxScaleX, maxScaleY)

  return self:setScale(scale)
end

function Screen:_updateDrawOffset()
  if love.window.getFullscreen() then
    -- When fullscreen, center screen on monitor
    local desktopW, desktopH = love.window.getDesktopDimensions()
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

function Screen:draw(drawFunc, ...)
  local previousCanvas = love.graphics.getCanvas()

  love.graphics.setCanvas(self._canvas)
  love.graphics.clear()
  drawFunc(...)

  love.graphics.setCanvas(previousCanvas)
  love.graphics.draw(self._canvas, self._drawOffsetX, self._drawOffsetY, 0, self._scale, self._scale)

  return self
end



return Terebi

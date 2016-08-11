local Terebi = {}



function Terebi.initializeLoveDefaults()
  love.mouse.setVisible(false)

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
  self.width = width
  self.height = height
  self.canvas = love.graphics.newCanvas(width, height)

  return self
    :setScale(scale)
end

function Screen:getCanvas()
  return self.canvas
end

function Screen:setScale(scale)
  local desktopW, desktopH = love.window.getDesktopDimensions()
  if scale <= 0 or (self.width * scale > desktopW) or (self.height * scale > desktopH) then
    return
  end

  self.scale = scale

  self:resizeWindow()
  self:updateDrawOffset()

  return self
end

function Screen:resizeWindow()
  local currentW, currentH, flags = love.window.getMode()
  local newW = self.scale * self.width
  local newH = self.scale * self.height
  if not love.window.getFullscreen() and (currentW ~= newW or currentH ~= newH) then
    love.window.setMode(newW, newH, flags)
  end
end

function Screen:increaseScale()
  self:setScale(self.scale + 1)

  return self
end

function Screen:decreaseScale()
  self:setScale(self.scale - 1)

  return self
end

function Screen:toggleFullscreen()
  if love.window.getFullscreen() then
    love.window.setFullscreen(false)
    self:setScale(2)

  else
    self:setMaxScale()
    love.window.setFullscreen(true)
    self:updateDrawOffset()
  end
end

function Screen:setMaxScale()
  local desktopW, desktopH = love.window.getDesktopDimensions()
  local maxScaleX = math.floor(desktopW / self.width)
  local maxScaleY = math.floor(desktopH / self.height)
  local scale = math.min(maxScaleX, maxScaleY)
  self:setScale(scale)
end

function Screen:updateDrawOffset()
  if love.window.getFullscreen() then
    -- When fullscreen, center screen on monitor
    local desktopW, desktopH = love.window.getDesktopDimensions()
    local scaledWidth  = self.width * self.scale
    local scaledHeight = self.height * self.scale
    self.drawOffsetX = math.floor((desktopW - scaledWidth) / 2)
    self.drawOffsetY = math.floor((desktopH - scaledHeight) / 2)

  else
    self.drawOffsetX = 0
    self.drawOffsetY = 0
  end
end

function Screen:draw()
  love.graphics.setCanvas()
  love.graphics.setColor(255, 255, 255, 255)

  love.graphics.draw(self.canvas, self.drawOffsetX, self.drawOffsetY, 0, self.scale, self.scale)

  return self
end



return Terebi

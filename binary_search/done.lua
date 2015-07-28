
local state = {}

local W, H
local graphics
local P, Q

function state.load ()
  W, H = love.window.getDimensions()
  graphics = love.graphics
  graphics.setFont(graphics.newFont(96))
end

function state.keypressed ()
  setState 'start'
end

function state.mousepressed ()
  setState 'start'
end

function state.draw ()
  graphics.setColor(120, 120, 255, 255)
  graphics.printf("=)", 0, H/2 - graphics.getFont():getHeight()/2, W, 'center')
end

return state

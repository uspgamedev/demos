
local state = {}

local W, H
local graphics
local P, Q

function state.load ()
  W, H = love.window.getDimensions()
  graphics = love.graphics
  P, Q = 1, 1000
  graphics.setFont(graphics.newFont(18))
end

function state.keypressed ()
  setState 'guess'
end

function state.mousepressed ()
  setState 'guess'
end

function state.draw ()
  graphics.setColor(255, 255, 255, 255)
  graphics.printf(string.format("Pick a number from %d to %d", P, Q),
                  0, H/2 - graphics.getFont():getHeight()/2, W, 'center')
end

return state

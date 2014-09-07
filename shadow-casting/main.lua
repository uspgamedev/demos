local Wall = require "wall"
local LightSource = require "light_source"

local W, H = love.graphics.getWidth(), love.graphics.getHeight()

local light = nil
local wall = nil

function love.load()
	light = LightSource.new(W/2, H/2)
	wall = Wall.new(500, 100, 750, 300)

	love.graphics.setBackgroundColor(40, 170, 160)
end

function love.update(dt)

end

function love.draw()
	light:draw()
	wall:draw()
end

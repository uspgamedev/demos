local Wall = require "wall"
local LightSource = require "light_source"

local W, H = love.graphics.getWidth(), love.graphics.getHeight()

local sources = {}
local bodies = {}

_G.properties = {
	entities = bodies,
	width = W,
	height = H
}

local _wall = nil

function love.load()
	table.insert(sources, LightSource.new(W/2, H/2))
	table.insert(bodies, Wall.new(500, 100, 750, 300))

	love.graphics.setBackgroundColor(40, 170, 160)
end

local function get_light(x, y)
	for i,v in pairs(table) do
		if math.abs(x-v.position[1])<10 and math.abs(y-v.position[2])<10 then
			return i
		end
	end

	return 0
end

function love.mousepressed(x, y, button)
	if button == 'r' then
		_wall = Wall.new(x, y, x, y)
	end

	for _,v in pairs(sources) do
		v:mousepressed(x, y, button)
	end
end

function love.mousereleased(x, y, button)
	if love.keyboard.isDown('lctrl') and button == 'l' then
		table.insert(sources, LightSource.new(x, y))
	elseif love.keyboard.isDown('lshift') and button == 'l' then
		table.remove(sources, get_light(x, y))
	elseif button == 'r' and _wall then
		table.insert(bodies, _wall)
		_wall = nil
	end

	for _,v in pairs(sources) do
		v:mousereleased(x, y, button)
	end
end

function love.keypressed(key)
	if key == "escape" then
		_wall = nil
	elseif key == 'c' then
		for i,v in pairs(bodies) do
			bodies[i] = nil
		end
	end
end

function love.update(dt)
	if _wall then
		_wall.points[3], _wall.points[4] = love.mouse.getX(), love.mouse.getY()
	end

	for _,v in pairs(sources) do
		v:update()
	end
end

function love.draw()
	if _wall then
		_wall:draw()
	end

	for _,v in pairs(sources) do
		v:draw()
	end
	for _,v in pairs(bodies) do
		v:draw()
	end
end

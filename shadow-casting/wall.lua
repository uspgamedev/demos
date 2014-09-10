local Shadow = require "shadow"

local wall = {
	shadow = nil,
	points = nil
}

local Wall = {}

function Wall.new(x1, y1, x2, y2)
	local inst = setmetatable({}, {__index = wall})

	inst.points = {x1, y1, x2, y2}
	inst.shadow = Shadow.new()

	return inst
end

function wall:draw()
	local lw = love.graphics.getLineWidth()
	
	love.graphics.setColor(75, 75, 75)
	love.graphics.setLineWidth(lw*5)
	love.graphics.line(unpack(self.points))
	love.graphics.setLineWidth(lw)

	self.shadow:draw()
end

return Wall
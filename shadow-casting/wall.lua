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
	love.graphics.setColor(50, 50, 50)
	love.graphics.line(unpack(self.points))

	self.shadow:draw()
end

return Wall
local wall = {
	points = nil
}

local Wall = {}

function Wall.new(x1, y1, x2, y2)
	local inst = setmetatable({}, {__index = wall})

	inst.points = {x1, y1, x2, y2}

	return inst
end

function wall:draw()
	love.graphics.setColor(25, 25, 25)
	love.graphics.line(unpack(self.points))
end

return Wall
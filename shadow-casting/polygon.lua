local polygon = {
	vertices = nil
}

local Polygon = {}

function Polygon.new(...)
	local inst = setmetatable({}, {__index = polygon})

	inst.vertices = {...}

	return inst
end

function polygon:draw()
	love.graphics.polygon("fill", self.vertices)
end

return Polygon
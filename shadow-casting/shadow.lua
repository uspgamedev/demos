local shadow = {
	vertices = nil,
	active = nil
}

local Shadow = {}

function Shadow.new(...)
	local inst = setmetatable({}, {__index = shadow})

	inst.vertices = {...}
	inst.active = #(inst.vertices)>0

	return inst
end

function shadow:draw()
	if not self.active then return end

	love.graphics.setColor(0, 0, 0)
	love.graphics.polygon("fill", self.vertices)
end

return Shadow
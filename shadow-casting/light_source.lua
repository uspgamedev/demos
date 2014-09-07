local light_source = {
	position = nil
}

local LightSource = {}

function LightSource.new(x, y)
	local inst = setmetatable({}, {__index = light_source})

	inst.position = {x, y}

	return inst
end

function light_source:draw()
	local x, y = unpack(self.position)

	love.graphics.push()

	love.graphics.setColor(200, 200, 100)
	love.graphics.circle("fill", x, y, 10, 5)
	love.graphics.translate(x, y)
	love.graphics.rotate(math.pi/5)
	love.graphics.circle("fill", 0, 0, 10, 5)
	
	love.graphics.pop()
end

function light_source:update()

end

return LightSource

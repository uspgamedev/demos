local light_source = {
	position = nil,
	dragged = nil
}

local LightSource = {}

function LightSource.new(x, y)
	local inst = setmetatable({}, {__index = light_source})

	inst.position = {x, y}
	inst.dragged = false

	return inst
end

function light_source:mousepressed(x, y, button)
	if button == 'l' then
		if math.abs(x-self.position[1])<10 and math.abs(y-self.position[2])<10 then
			self.dragged = true
		end
	end
end

function light_source:mousereleased(x, y, button)
	if button == 'l' then
		if self.dragged then
			self.dragged = false
		end
	end
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
	local W, H = _G.properties.width, _G.properties.height
	local px, py = unpack(self.position)

	if self.dragged then
		self.position[1], self.position[2] = love.mouse.getX(), love.mouse.getY()
	end

	for _,v in pairs(_G.properties.entities) do
		local x1, y1, x2, y2 = unpack(v.points)
		local polygon = v.shadow.vertices

		polygon[1], polygon[2] = x1, y1
		polygon[3], polygon[4] = W*(x1-px), H*(y1-py)
		polygon[5], polygon[6] = H*(x2-px), H*(y2-py)
		polygon[7], polygon[8] = x2, y2
	
		v.shadow.active = true
	end
end

return LightSource

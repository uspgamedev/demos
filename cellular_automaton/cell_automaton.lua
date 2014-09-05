local Stack = require "stack"

local automaton = {
	current = nil,
	transformed = nil,
	size_x = 0, size_y = 0,
	properties = {
		neighbouring = 4,
		limitant = 2,
		auto_remove = false
	},
	stack = nil,
	stack_index = 0
}

local CellAutomaton = {}

local function new_table(n)
	local t = {}
	for i=0, n-1 do t[i] = {} end
	return t
end

function automaton:transform()
	local current, transformed = self.current, self.transformed
	local limitant, neighbouring = self.properties.limitant, self.properties.neighbouring
	local auto_remove = self.properties.auto_remove

	self.stack:push(current)

	for i=0, self.size_x-1 do
		for j=0, self.size_y-1 do
			local encounters = 0

			for p=-1, neighbouring-2 do
				for q=-1, neighbouring-2 do
					local x, y = i + p, j + q
					if ((x >= 0  and y >= 0) and (x < self.size_x and y < self.size_y)) and current[x][y] then
						encounters = encounters + 1
					end
				end
			end

			if encounters > limitant then
				transformed[i][j] = true
			elseif auto_remove then
				transformed[i][j] = false
			else
				transformed[i][j] = current[i][j]
			end
		end
	end

	self.current = self.transformed
	self.transformed = new_table(self.size_x)
end

function automaton:next()
	self:transform()
	self.stack_index = (self.stack_index+1)%(self.stack.size)
	return self.stack[self.stack_index+1]
end

function automaton:prev()
	if self.stack.size < 2 then return self.current end
	self.stack_index = (self.stack_index-1)%(self.stack.size)
	self.stack:pop()
	self.current = self.stack:peek()
	return self.current
end

function automaton:force_push()
	self.stack:push(self.current)
end

function CellAutomaton.new(map, _width, _height, _properties)
	local inst = setmetatable({}, {__index = automaton})
	
	inst.current = map
	inst.stack = Stack.new()
	inst.transformed = new_table(_height)
	inst.size_x, inst.size_y = _width, _height
	inst.properties = _properties

	return inst
end

return CellAutomaton
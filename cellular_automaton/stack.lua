local master_stack = {size = 0}
local Stack = {}

function Stack.new()
	return setmetatable({}, {__index = master_stack})
end

function master_stack.push(self, map)
	self[self.size] = map
	self.size = self.size + 1
end

function master_stack.pop(self)
	self.size = self.size - 1
	return table.remove()
end

return Stack
local master_stack = {size = 0}
local Stack = {}

function Stack.new()
	return setmetatable({}, {__index = master_stack})
end

function master_stack.push(self, map)
	self.size = self.size + 1
	self[self.size] = map
end

function master_stack.pop(self)
	self.size = self.size - 1
	return table.remove(self)
end

function master_stack.peek(self)
	return self[self.size]
end

function master_stack.dequeue(self)
	return table.remove(self, 1)
end

return Stack
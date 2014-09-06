local List = {}

local L = {}
local meta = {__index = L}

function List.new(...)
	return setmetatable({}, meta):init(...)
end

function L:init()
	self.head = {}
	self.size = 0
	self.last = self.head
	return self
end

function L:spliceList(l)
	self.last.next = l.head.next
	if self.last.next then
		self.last.next.prev = self.last
		self.last = l.last
	end
end

function L:addList(l)
	local i = l.head.next
	while i do
		self:add(i.value)
		i = i.next
	end
end

function L:add(v)
	assert(v)
	self.last.next = {value = v, prev = self.last}
	self.last = self.last.next
	self.size = self.size + 1
end

function L:removeNode(n)
	n.prev.next = n.next

	if n.next then n.next.prev = n.prev
	else self.last = n.prev	end

	self.size = self.size - 1
end

return List
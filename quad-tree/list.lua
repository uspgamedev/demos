local List = {}

local L = {}
local meta = {__index = L}

function List.new()
	return setmetatable({}, meta):init()
end

function L:init()
	self.head = {}
	self.size = 0
	self.last = self.head
	return self
end

function L:spliceList(l)
	self.last.next = l.head.next
	if self.last.next then self.last.next.prev = self.last end
	self.last = l.last
end

function L:addList(l)
	local i = l.head.next
	while i do
		self:add(i.value)
		i = i.next
	end
end

function L:add(v)
	self.last.next = {value = v, prev = self.last}
	self.last = self.last.next
	self.size = self.size + 1
end

return List
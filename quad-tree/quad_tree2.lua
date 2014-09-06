local List = require "list"

local LIMIT = 6
local MAX_LEVEL = 5

local QuadTree = {}

local QT = {}
local meta = {__index = QT}

function QuadTree.new(...)
	return setmetatable({}, meta):init(...)
end

function QT:init(bounds, level)
	self.level = level or 1
	self.bounds = bounds
	self.bodies = List.new()
	return self
end

function QT:getIndex(rect)
	local mx = self.bounds[1] + self.bounds[3]/2
	local my = self.bounds[2] + self.bounds[4]/2

	local up = rect[2] + rect[4] < my
	local down = rect[2] > my
	local left = rect[1] + rect[3] < mx
	local right = rect[1] > mx

	return up and (left and 1 or right and 2 or 0) or
		down and (left and 3 or right and 4 or 0) or 0 --cryptic code
end

function QT:subdivide()
	local b = self.bounds
	local w2, h2 = b[3]/2, b[4]/2
	self.sect = {
		QuadTree.new({b[1], b[2], w2, h2}, self.level + 1),
		QuadTree.new({b[1] + w2, b[2], w2, h2}, self.level + 1),
		QuadTree.new({b[1], b[2] + h2, w2, h2}, self.level + 1),
		QuadTree.new({b[1] + w2, b[2] + h2, w2, h2}, self.level + 1)
	}

	local n = self.bodies.head.next
	while n do
		local i = self:getIndex(n.value.rect)
		if i > 0 then
			self.bodies:removeNode(n)
			self.sect[i]:add(n.value)
		end
		n = n.next
	end
end

function QT:add(r)
	if self.sect then
		local i = self:getIndex(r.rect)
		if i > 0 then
			self.sect[i]:add(r)
			return
		end
	end

	self.bodies:add(r)

	if not self.sect and self.level < MAX_LEVEL and self.bodies.size > LIMIT then
		self:subdivide()
	end
end

function QT:query(rect)
	local l = List.new()

	l:addList(self.bodies)

	if self.sect then
		local mx = self.bounds[1] + self.bounds[3]/2
		local my = self.bounds[2] + self.bounds[4]/2

		local up = rect[2] < my
		local down = rect[2] + rect[4] > my
		local left = rect[1] < mx
		local right = rect[1] + rect[3] > mx

		if up and left    then l:spliceList(self.sect[1]:query(rect)) end
		if up and right   then l:spliceList(self.sect[2]:query(rect)) end
		if down and left  then l:spliceList(self.sect[3]:query(rect)) end
		if down and right then l:spliceList(self.sect[4]:query(rect)) end
	end

	return l
end

return QuadTree
local LIMIT = 6
local MAX_LEVEL = 5

local QuadTree = {}

local QT = {}
local meta = {__index = QT}

function QuadTree.new(...)
	return setmetatable({}, meta):init(...)
end

local function collidesRect(a, b)
	if a[1] > b[1] + b[3] then return false end
	if a[1] + a[3] < b[1] then return false end
	if a[2] > b[2] + b[4] then return false end
	if a[2] + a[4] < b[2] then return false end
	return true
end

function QT:init(bounds, level)
	self.level = level or 1
	self.bounds = bounds
	self.bodies = {}
	return self
end

function QT:getIndex(rect)
	local mx = self.bounds[1] + self.bounds[3]/2
	local my = self.bounds[2] + self.bounds[4]/2

	local up = rect[2] + rect[4] < my
	local down = rect[2] > my
	local left = rect[1] + rect[3] < mx
	local right = rect[1] > mx

	return up and (left and 1 or right and 2) or
		down and (left and 3 or right and 4) --cryptic code
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

	local i = 1
	while self.bodies[i] do
		local ind = self:getIndex(self.bodies[i].rect)
		if ind then
			self.sect[ind]:add(self.bodies[i])
			self.bodies[i] = self.bodies[#self.bodies]
			self.bodies[#self.bodies] = nil
		else
			i = i + 1
		end
	end
end

function QT:add(r)
	if self.sect then
		local i = self:getIndex(r.rect)
		if i then
			self.sect[i]:add(r)
			return
		end
	end

	self.bodies[#self.bodies + 1] = r

	if not self.sect and self.level < MAX_LEVEL and #self.bodies > LIMIT then
		self:subdivide()
	end
end

function QT:query(rect)
	return self:query_intern({}, rect)
end

function QT:query_intern(t, rect)
	for _, e in ipairs(self.bodies) do
		if rect.id < e.rect.id then t[#t + 1] = e end
	end

	if self.sect then
		local mx = self.bounds[1] + self.bounds[3]/2
		local my = self.bounds[2] + self.bounds[4]/2

		local up = rect[2] < my
		local down = rect[2] + rect[4] > my
		local left = rect[1] < mx
		local right = rect[1] + rect[3] > mx

		if up and left    then self.sect[1]:query_intern(t, rect) end
		if up and right   then self.sect[2]:query_intern(t, rect) end
		if down and left  then self.sect[3]:query_intern(t, rect) end
		if down and right then self.sect[4]:query_intern(t, rect) end
	end

	return t
end

return QuadTree
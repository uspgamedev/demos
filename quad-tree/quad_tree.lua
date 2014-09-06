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

function QT:subdivide()
	local b = self.bounds
	local w2, h2 = b[3]/2, b[4]/2
	self.sect = {
		QuadTree.new({b[1], b[2], w2, h2}, self.level + 1),
		QuadTree.new({b[1] + w2, b[2], w2, h2}, self.level + 1),
		QuadTree.new({b[1], b[2] + h2, w2, h2}, self.level + 1),
		QuadTree.new({b[1] + w2, b[2] + h2, w2, h2}, self.level + 1)
	}

	for _, r in ipairs(self.bodies) do
		for i = 1, 4 do
			self.sect[i]:add(r)
		end
	end
	self.bodies = nil
end

function QT:add(r)
	if not collidesRect(self.bounds, r.rect) then return end
	if self.sect then
		for i = 1, 4 do self.sect[i]:add(r) end
		return
	end

	self.bodies[#self.bodies + 1] = r

	if self.level < MAX_LEVEL and #self.bodies > LIMIT then
		self:subdivide()
	end
end

function QT:query(rect)
	return self:query_intern({}, {}, rect)
end

function QT:query_intern(seen, collided, rect)
	if not collidesRect(self.bounds, rect) then return nil, 0 end
	local count = 0
	if self.sect then
		for i = 1, 4 do
			local t, c = self.sect[i]:query_intern(seen, collided, rect)
			count = count + c
		end
	else
		for _, r in ipairs(self.bodies) do
			if not seen[r] and rect.id < r.rect.id and collidesRect(rect, r.rect) then
				collided[r] = true
				count = count + 1
			end
			seen[r] = true
		end
	end

	return collided, count
end

return QuadTree
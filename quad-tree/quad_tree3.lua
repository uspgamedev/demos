local LIMIT = 6
local MAX_LEVEL = 5

local QuadTree = {}

local QT = {}
local meta = {__index = QT}

function QuadTree.new(...)
	return setmetatable({}, meta):init(...)
end

local function newNode(bounds, level)
  local node = {}
	node.level = level or 1
	node.bounds = bounds
	node.bodies = {}
	return node
end

local function collidesRect(a, b)
	if a[1] > b[1] + b[3] then return false end
	if a[1] + a[3] < b[1] then return false end
	if a[2] > b[2] + b[4] then return false end
	if a[2] + a[4] < b[2] then return false end
	return true
end

function QT:init(bounds)
  self.root = newNode(bounds, 1)
	self.allbodies = {}
	return self
end

function QT:add(body, node)
  node = node or self.root
	if node.level < MAX_LEVEL and #node.bodies+1 > LIMIT then
		self:subdivide(node)
    local sects = {}
	  for i = 1, 4 do 
	    if collidesRect(node.bounds, body.rect) then
        table.insert(sects, i)
      end
    end
    if #sects == 1 then
      self:add(node.sect[sects[1]], body)
      return
    end
  end
  node.bodies[body] = true
  self.allbodies[body] = node
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

function QT:query(rect)
	return self:query_intern({}, rect)
end

function QT:query_intern(seen, rect)
	if not collidesRect(self.bounds, rect) then return nil, 0 end
	local count = 0
	if self.sect then
		for i = 1, 4 do
			local t, c = self.sect[i]:query_intern(seen, rect)
			count = count + c
		end
	else
		for _, r in ipairs(self.bodies) do
			if not seen[r] and rect.id < r.rect.id then
				seen[r] = true
				count = count + 1
			end
		end
	end

	return seen, count
end

return QuadTree

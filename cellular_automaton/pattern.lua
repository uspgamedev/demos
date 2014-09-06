local pattern = {
	matrix = nil,
	width = 0,
	height = 0
}

local Pattern = {}

function pattern:equals(map, x, y)
	local pat = self.matrix

	for i=0, self.width-1 do
		for j=0, self.height-1 do
			if map[x+i][y+j] ~= pat[i][j] then
				return false
			else
				print(i, j)
			end
		end
	end

	return true 
end

function pattern:assign(map, x, y)
	local pat = self.matrix

	for i=0, self.width-1 do
		for j=0, self.height-1 do
			map[x+i][y+j] = pat[i][j]
		end
	end
end

function Pattern.new(matrix, width, height)
	local inst = setmetatable({}, {
		__index = pattern,
		__eq = function (pat1, pat2)
			if pat1.width ~= pat2.width or pat1.height ~= pat2.height then
				return false
			end

			local width, height = pat1.width, pat1.height
			local m1, m2 = pat1.matrix, pat2.matrix

			for i=0, width-1 do
				for j=0, height-1 do
					if m1[i][j] ~= m2[i][j] then
						return false
					end
				end
			end

			return true
		end})

	inst.matrix = {}
	for i=0, width-1 do
		inst.matrix[i] = {}
	end

	for i=0, width-1 do
		for j=0, height-1 do
			local val = matrix[i + j*width]
			inst.matrix[i][j] = (val==1)
		end
	end

	inst.width, inst.height = width, height

	return inst
end

return Pattern
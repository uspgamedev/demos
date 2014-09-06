local Pattern = require "pattern"

local pair = {
	pattern = nil,
	anti_pattern = nil
}

local PatternPair = {}

function PatternPair.new(pattern, anti_pattern)
	local inst = setmetatable({}, {__index = pair})

	inst.pattern, inst.anti_pattern = pattern, anti_pattern

	return inst
end

function pair:search(map, target, width, height)
	local pat, anti = self.pattern, self.anti_pattern
	local count = 0
	local pat_width, pat_height = pat.width, pat.height

	for i=0, width-pat_width do
		for j=0, height-pat_height do
			if pat:equals(map, i, j) then
				anti:assign(target, i, j)
				count = count + 1
			elseif target[i][j] == nil then
				target[i][j] = map[i][j]
			end
		end
	end

	return count
end

return PatternPair

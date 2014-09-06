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

	for i=0, (width-1)-pat_width do
		for j=0, (height-1)-pat_height do
			if pat:equals(map, i, j) then
				anti:assign(target, i, j)
				count = count + 1
			else
				for m=i, i+(pat_width-1) do
					for n=j, j+(pat_height-1) do
						target[m][n] = map[m][n]
					end
				end
			end
		end
	end

	return count
end

return PatternPair

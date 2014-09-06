local Pattern = require "pattern"

local pattern_generator = {
	pattern = nil,
	density = 1.0
}

local PatternGenerator = {}

function PatternGenerator.new(pattern, density)
	local inst = setmetatable({}, {__index = pattern_generator})

	inst.pattern = pattern
	inst.density = density or 1.0

	return inst
end

function pattern_generator:generate(map)
	local width, height = #map-1, #map[0]-1
	local pat_width, pat_height = self.pattern.width, self.pattern.height
	local pat = self.pattern.matrix

	for i=0, width-1 do
		for j=0, height-1 do
			map[i][j] = pat[i%pat_width][j%pat_height]
		end
	end

	return map
end

return PatternGenerator

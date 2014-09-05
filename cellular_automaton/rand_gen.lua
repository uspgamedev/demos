local generator = {
	seed = 0,
	density = 0.5
}

local RandomGenerator = {}

function RandomGenerator.new(density, seed)
	local inst = setmetatable({}, {__index = generator})

	inst.seed = seed or math.random()
	inst.density = density or 0.25

	return inst
end

function generator:generate(map, action)
	local width, height = #map-1, #map[0]-1
	local total = width*height*self.density

	if action == nil then action = true end

	for i=0, total do
		map[math.random(0, width)][math.random(0, height)] = action
	end

	return map
end

return RandomGenerator

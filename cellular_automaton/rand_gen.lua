local generator = {
	seed = 0
}

local RandomGenerator = {}

function RandomGenerator.new(seed)
	local inst = setmetatable({}, {__index = generator})

	if not seed then 
		inst.seed = math.random()
	else
		inst.seed = seed
	end

	return inst
end

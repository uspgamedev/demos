local QuadTree = require "quad_tree"

local rects = {}
local size = 40

local qt = QuadTree.new{0, 0, 800, 600}

local white = {255, 255, 255}
local red = {255, 0, 0}
local green = {0, 255, 0}

local function trueCollides(a, b)
	local d = (a[1] - b[1])^2 + (a[2] - b[2])^2
	return d <= size^2
end

function love.load()
	math.randomseed(os.time())
	local rand = math.random
	rand() rand()
	for i = 1, 100 do
		local e = {rand(800 - size), rand(600 - size), size, size}
		rects[#rects + 1] = e
		qt:add(e)
		e.color = white
	end

	for _, e in ipairs(rects) do
		local cols, n = qt:query({}, e)
		for r in pairs(cols) do
			if r ~= e and trueCollides(r, e) then r.color = red end
		end
	end
end

function draw_quad(q, color)
	love.graphics.setColor(color)
	love.graphics.rectangle('line', unpack(q.bounds))
	if q.sect then
		local c = color
		for i = 1, 4 do
			draw_quad(q.sect[i], c)
		end
	end
end

function love.draw()

	draw_quad(qt, {0, 255, 0,  100})
	for _, e in ipairs(rects) do
		love.graphics.setColor(e.color)
		love.graphics.circle('fill', e[1] + e[3]/2, e[2] + e[4]/2, e[3]/2)
	end
end
local QuadTree = require "quad_tree"

local rects = {}
local size = 20

local qt = QuadTree.new{0, 0, 800, 600}

local white = {255, 255, 255}
local red = {255, 0, 0}
local green = {0, 255, 0}

local function trueCollides(a, b)
	local d = (a[1] - b[1])^2 + (a[2] - b[2])^2
	return d <= size^2
end

local rand = math.random
function addRandomBall()
	local e = {
		rect = {rand(800 - size), rand(600 - size), size, size},
		speed = {rand(300) - 150, rand(200) - 100},
		color = white
	}
	rects[#rects + 1] = e
end

function love.load()
	math.randomseed(os.time())
	rand() rand()
end

function love.update(dt)
	qt = QuadTree.new{0, 0, 800, 600}
	for _, e in ipairs(rects) do
		e.rect[1] = e.rect[1] + e.speed[1] * dt
		e.rect[2] = e.rect[2] + e.speed[2] * dt
		if e.rect[1] < 0 then
			e.speed[1] = -e.speed[1]
			e.rect[1] = 0
		end
		if e.rect[1] + e.rect[3] > 800 then
			e.speed[1] = -e.speed[1]
			e.rect[1] = 800 - e.rect[3]
		end
		if e.rect[2] < 0 then
			e.speed[2] = -e.speed[2]
			e.rect[2] = 0
		end
		if e.rect[2] + e.rect[4] > 600 then
			e.speed[2] = -e.speed[2]
			e.rect[2] = 600 - e.rect[4]
		end
		qt:add(e)
		e.color = white
	end

	for _, e in ipairs(rects) do
		local cols, n = qt:query({}, e.rect)
		if cols then
			for r in pairs(cols) do
				if r ~= e and trueCollides(r.rect, e.rect) then r.color = red end
			end
		end
	end
end

function draw_quad(q, color)
	love.graphics.setColor(color)
	love.graphics.rectangle('line', unpack(q.bounds))
	if q.sect then
		local c = {color[1], color[2], color[3], color[4] * .9}
		for i = 1, 4 do
			draw_quad(q.sect[i], c)
		end
	end
end

function love.draw()
	draw_quad(qt, {0, 255, 0,  100})
	for _, e in ipairs(rects) do
		love.graphics.setColor(e.color)
		local r = e.rect
		love.graphics.circle('fill', r[1] + r[3]/2, r[2] + r[4]/2, r[3]/2)
	end
end

function love.mousepressed(x, y, but)
	if but == 'l' then addRandomBall() end
end
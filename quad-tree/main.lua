local QuadTree = require "quad_tree"

local rects = {}
local size = 20
local last_dt = 0

local qt = QuadTree.new{0, 0, 800, 600}

local white = {255, 255, 255}
local red = {255, 0, 0}
local green = {0, 255, 0}

local using_quadtree = true

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
	addRandomBall()
end

function noob_collision()
	for i = 1, #rects do
		local r = rects[i]
		for j = i + 1, #rects, 1 do
			if trueCollides(r.rect, rects[j].rect) then
				rects[j].color = red
				r.color = red
			end
		end
	end
end

function quad_collision()
	qt = QuadTree.new{0, 0, 800, 600}
	for _, e in ipairs(rects) do
		qt:add(e)
	end
	
	for _, e in ipairs(rects) do
		local cols, n = qt:query(e.rect)
		if cols then
			for r in pairs(cols) do
				if r ~= e and trueCollides(r.rect, e.rect) then r.color = red end
			end
		end
	end
end

function love.update(dt)
	last_dt = dt
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
		e.color = white
	end

	(using_quadtree and quad_collision or noob_collision)()
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
	if using_quadtree then
		draw_quad(qt, {0, 255, 0,  100})
	end

	for _, e in ipairs(rects) do
		love.graphics.setColor(e.color)
		local r = e.rect
		love.graphics.circle('fill', r[1] + r[3]/2, r[2] + r[4]/2, r[3]/2)
	end

	love.graphics.setColor(white)
	love.graphics.print("Balls: " .. #rects, 10, 10)
	love.graphics.print("dt: " .. last_dt, 10, 25)
end

function love.mousepressed(x, y, but)
	if but == 'l' then for i = 1, 3 do addRandomBall() end end
	if but == 'r' then using_quadtree = not using_quadtree end
end
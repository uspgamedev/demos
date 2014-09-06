local QuadTree = require "quad_tree"
local QuadTree2 = require "quad_tree2"

local rects = {}
local size = 20
local last_dt = 0

local qt = QuadTree.new{0, 0, 1024, 768}

local white = {255, 255, 255}
local red = {255, 0, 0}
local green = {0, 255, 0}

local collision_alg = 2

local function trueCollides(a, b)
	local d = (a[1] - b[1])^2 + (a[2] - b[2])^2
	return d <= size^2
end

local rand = math.random
local id = 0
function addRandomBall()
	local e = {
		rect = {rand(1024 - size), rand(768 - size), size, size, id = id},
		speed = {rand(300) - 150, rand(200) - 100},
		color = white
	}
	id = id + 1
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
				r.color = green
			end
		end
	end
end

function quad_collision()
	qt = QuadTree.new{0, 0, 1024, 768}
	for _, e in ipairs(rects) do
		qt:add(e)
	end
	
	for _, e in ipairs(rects) do
		local cols, n = qt:query(e.rect)
		if n > 0 then e.color = green end
		if cols then
			for r in pairs(cols) do
				if r ~= e and trueCollides(r.rect, e.rect) then r.color = red end
			end
		end
	end
end

function quad2_collision()
	qt = QuadTree2.new{0, 0, 1024, 768}
	for _, e in ipairs(rects) do
		qt:add(e)
	end

	for _, e in ipairs(rects) do
		local cols = qt:query(e.rect)
		if #cols > 0 then e.color = green end
		for _, r in ipairs(cols) do
			if e ~= r and trueCollides(e.rect, r.rect) then r.color = red end
		end
	end
end

local collision = {noob_collision, quad_collision, quad2_collision}

function love.update(dt)
	last_dt = dt
	for _, e in ipairs(rects) do
		e.rect[1] = e.rect[1] + e.speed[1] * dt
		e.rect[2] = e.rect[2] + e.speed[2] * dt
		if e.rect[1] < 0 then
			e.speed[1] = -e.speed[1]
			e.rect[1] = 0
		end
		if e.rect[1] + e.rect[3] > 1024 then
			e.speed[1] = -e.speed[1]
			e.rect[1] = 1024 - e.rect[3]
		end
		if e.rect[2] < 0 then
			e.speed[2] = -e.speed[2]
			e.rect[2] = 0
		end
		if e.rect[2] + e.rect[4] > 768 then
			e.speed[2] = -e.speed[2]
			e.rect[2] = 768 - e.rect[4]
		end
		e.color = white
	end

	collision[collision_alg]()
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
	if collision_alg > 1 then
		draw_quad(qt, {0, 255, 0, 100})
	end

	for _, e in ipairs(rects) do
		love.graphics.setColor(e.color)
		local r = e.rect
		love.graphics.circle('fill', r[1] + r[3]/2, r[2] + r[4]/2, r[3]/2)
	end

	love.graphics.setColor(white)
	love.graphics.print("Balls: " .. #rects, 10, 10)
	love.graphics.print("dt: " .. last_dt, 10, 25)
	love.graphics.print("Collision: " .. collision_alg, 10, 40)
end

function love.mousepressed(x, y, but)
	if but == 'l' then for i = 1, 25 do addRandomBall() end end
	if but == 'r' then
		collision_alg = (collision_alg % 3) + 1
	end
end
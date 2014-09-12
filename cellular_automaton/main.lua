local CellAutomaton = require "cell_automaton"
local RandomGenerator = require "rand_gen"
local PatternPair = require "pattern_pair"
local Pattern = require "pattern"
local PatternGenerator = require "pattern_gen"

-- (Width, height) in pixels.
local W, H = love.graphics.getWidth(), love.graphics.getHeight()
-- (Width, height) in (lines, columns).
local width, height = 100, 100
-- Tiled map.
local map = {}
-- (true) color.
local true_color = {50, 50, 50}
-- (false) color.
local false_color = {200, 200, 200}
-- Grid mode.
local grid_mode = false
-- Transformation stack.
local automaton = nil
-- Modification marker.
local diff = true
-- Random generator.
local random = nil
-- Pattern generator.
local pattern_gen = nil

-- Here goes all the Cellular Automaton configuration options:

-- Randomization properties
local randomization_density = 0.1
-- Algorithm properties
local automaton_properties = {
	auto_remove = false,
	neighbouring = 3,
	limitant = 1,
	uses_patterns = false,
	patterns = {
		PatternPair.new(
			Pattern.new(
				{{1, 0, 1},
				 {0, 1, 0},
				 {1, 0, 1}}, 3, 3),
			Pattern.new(
				{{0, 1, 0},
				 {1, 0, 1},
				 {0, 1, 0}}, 3, 3)
		)
	}
}

-- No more Cellular Automaton configuration options. Ye be forbidden to booty down 'ere! D:<

function love.load()
	for i=0, width-1 do
		map[i] = {}
		for j=0, height-1 do
			map[i][j] = false
		end
	end

	random = RandomGenerator.new(randomization_density)
	pattern_gen = PatternGenerator.new(Pattern.new(
				{{1, 0, 1, 0},
				 {0, 1, 0, 1},
				 {1, 0, 1, 0},
				 {0, 1, 0, 1}}, 4, 4))
end

function love.update(dt)
	local dx, dy = W/width, H/height
	local x, y = love.mouse.getX(), love.mouse.getY()
	local px, py = math.floor(x/dx), math.floor(y/dy)
	
	if love.mouse.isDown('l') then
		map[px][py] = true
		diff = true
	elseif love.mouse.isDown('r') then
		map[px][py] = false
		diff = true
	end
end

local function apply_automaton(action)
	if diff then
		print("Diff. Recreating...")
		automaton = CellAutomaton.new(map, width, height, automaton_properties)
		map = automaton:next()
	end

	print("Applying...")
	
	if action then
		map = automaton:next()
	else
		map = automaton:prev()
	end

	print("Done")
	
	diff = false
end

function love.keyreleased(key)
	if key == "escape" then
		love.event.quit()
	elseif key == 'c' then
		for i=0, width-1 do
			for j=0, height-1 do
				map[i][j] = false
			end
		end
	elseif key == 'g' then
		grid_mode = not grid_mode
	elseif key == '.' then
		apply_automaton(true)
	elseif key == ',' then
		apply_automaton(false)
	elseif key == 'r' then
		map = random:generate(map)
		diff = true
	elseif key == 'p' then
		map = pattern_gen:generate(map)
		diff = true
	elseif key == 'm' then
		automaton_properties.uses_patterns = not automaton_properties.uses_patterns
	elseif key == 'a' then
		automaton_properties.auto_remove = not automaton_properties.auto_remove
	end
end

function draw_lines()
	local x_step, y_step = W/width, H/height

	love.graphics.setColor(100, 100, 100)

	for i=0, W-1, x_step do
		love.graphics.line(i, 0, i, H)
	end

	for i=0, H-1, y_step do
		love.graphics.line(0, i, W, i)
	end
end

function draw_map()
	local rel_x, rel_y = W/width, H/height

	for i=0, width-1 do
		for j=0, height-1 do
			love.graphics.setColor(map[i][j] and true_color or false_color)	
			love.graphics.rectangle("fill", i*rel_x, j*rel_y, rel_x, rel_y)
		end
	end
end

function love.draw()
	draw_map()

	if grid_mode then
		draw_lines()
	end

	love.graphics.setColor(0, 0, 0)
	love.graphics.print("Grid mode: "..tostring(grid_mode)..
		"\nPattern mode: "..tostring(automaton_properties.uses_patterns)..
		"\nAuto-remove mode: "..tostring(automaton_properties.auto_remove), 
		10, H-50, nil, 1.2, 1.2)
end


local yield = coroutine.yield

local W, H
local graphics

local input, stack
local calculator

local MAX_SIZE = 16
local DW, DH = 40, 24
local DELAY = .5

local VALID = {
  [0] = true,
  [1] = true,
  [2] = true,
  [3] = true,
  [4] = true,
  [5] = true,
  [6] = true,
  [7] = true,
  [8] = true,
  [9] = true,
  ['+'] = true,
  ['-'] = true,
  ['*'] = true,
  ['/'] = true,
}

local OP = {
  ['+'] = function (x, y) return x + y end,
  ['-'] = function (x, y) return x - y end,
  ['*'] = function (x, y) return x * y end,
  ['/'] = function (x, y) return x / y end,
}

local function process ()
  for i,token in ipairs(input) do
    if type(token) == 'number' then
      table.insert(stack, token)
    elseif type(token) == 'string' then
      -- WARNING: order must be inverted
      local y, x = table.remove(stack), table.remove(stack)
      table.insert(stack, OP[token](x, y))
    end
    yield()
  end
  yield(true)
end

local function makeUpdater ()
  return coroutine.wrap(function (dt)
    local time = DELAY
    local finished
    while true do
      time = time - dt
      while time < 0 do
        time = time + DELAY
        finished = calculator()
      end
      if finished then
        love.update = nil
      else
        dt = yield()
      end
    end
  end)
end

function love.load ()
  graphics = love.graphics
  W, H = love.window.getDimensions()
  input, stack = {}, {}
  calculator = coroutine.wrap(process)
  graphics.setFont(graphics.newFont(22))
end

function love.keypressed (key)
  if key == 'return' then
    love.update = makeUpdater()
  elseif key == 'escape' then
    love.update = nil
    love.load()
  end
end

function love.textinput (key)
  if love.update then return end
  local token = tonumber(key) or key
  if VALID[token] and #input < 16 then
    table.insert(input, token)
  end
end

function love.draw ()
  graphics.setColor(255, 255, 255, 255)
  do -- Input
    graphics.push()
    graphics.translate(W/10, 64)
    graphics.print("Input:", 0, 0)
    for i,token in ipairs(input) do
      graphics.printf(token, (i-1)*DW, 64, DW, 'center')
    end
    graphics.pop()
  end
  do -- Stack
    graphics.push()
    graphics.translate(W/10, 128 + 32 + 16)
    graphics.setColor(40, 40, 40, 255)
    graphics.rectangle('fill', -DW/4, -DH/2, 1.5*DW, (MAX_SIZE + 1)*DH)
    graphics.setColor(200, 150, 20, 255)
    graphics.rectangle('line', -DW/4, -DH/2, 1.5*DW, (MAX_SIZE + 1)*DH)
    graphics.setColor(255, 255, 255, 255)
    for i,token in ipairs(stack) do
      graphics.printf(token, 0, (MAX_SIZE - i)*DH, DW, 'center')
    end
    graphics.pop()
  end
end

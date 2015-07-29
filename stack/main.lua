
local yield = coroutine.yield

local W, H
local graphics
local transfer
local buttons
local fonts

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
  while #input > 0 do
    local token = input[1]
    if type(token) == 'number' then
      table.insert(stack, token)
    elseif type(token) == 'string' then
      -- WARNING: order must be inverted
      local y, x = table.remove(stack), table.remove(stack)
      table.insert(stack, OP[token](x, y))
    end
    table.remove(input, 1)
    yield(#input <= 0)
  end
end

local function makeUpdater ()
  return coroutine.wrap(function (dt)
    local finished
    while true do
      while transfer < 1 do
        transfer = math.min(transfer + dt, 1)
        dt = yield()
      end
      transfer = 0
      if calculator() then
        love.update = nil
        break
      end
      local time = DELAY
      while time > 0 do
        time = time - dt
        dt = yield()
      end
    end
  end)
end

local function makeButton (token, x, y, w, h)
  return {
    token = token,
    x = x, y = y, w = w, h = h
  }
end

function love.load ()
  graphics = love.graphics
  W, H = love.window.getDimensions()
  transfer = 0
  input, stack = {}, {}
  calculator = coroutine.wrap(process)
  buttons = {}
  fonts = {
    normal = graphics.newFont(22),
    button = graphics.newFont(32)
  }
  buttons[1] = makeButton(1, W/3, H/3, 64, 64)
  buttons[2] = makeButton(2, W/3 + 96, H/3, 64, 64)
  buttons[3] = makeButton(3, W/3 + 2*96, H/3, 64, 64)
  buttons[4] = makeButton(4, W/3, H/3 + 96, 64, 64)
  buttons[5] = makeButton(5, W/3 + 96, H/3 + 96, 64, 64)
  buttons[6] = makeButton(6, W/3 + 2*96, H/3 + 96, 64, 64)
  buttons[7] = makeButton(7, W/3, H/3 + 2*96, 64, 64)
  buttons[8] = makeButton(8, W/3 + 96, H/3 + 2*96, 64, 64)
  buttons[9] = makeButton(9, W/3 + 2*96, H/3 + 2*96, 64, 64)
  buttons[10] = makeButton(0, W/3, H/3 + 3*96, 64 + 96, 64)
  buttons[11] = makeButton('=', W/3 + 2*96, H/3 + 3*96, 64, 64)
  buttons[12] = makeButton('+', W/3 + 3*96, H/3, 64, 64)
  buttons[13] = makeButton('-', W/3 + 3*96, H/3 + 96, 64, 64)
  buttons[14] = makeButton('*', W/3 + 3*96, H/3 + 2*96, 64, 64)
  buttons[15] = makeButton('/', W/3 + 3*96, H/3 + 3*96, 64, 64)
end

function love.mousepressed (x, y, button)
  for i,button in ipairs(buttons) do
    if  x > button.x and x < button.x + button.w and
        y > button.y and y < button.y + button.h then
      if button.token == '=' then
        love.update = makeUpdater()
      else
        table.insert(input, button.token)
      end
    end
  end
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
  graphics.setFont(fonts.normal)
  graphics.setColor(255, 255, 255, 255)
  do -- Input
    graphics.push()
    graphics.translate(W/10, 32)
    graphics.print("Input:", 0, 0)
    for i,token in ipairs(input) do
      if i > 1 or transfer <= 0 then
        graphics.printf(token, (i-1)*DW, 64, DW, 'center')
      end
    end
    graphics.pop()
  end
  do -- Buttons
    graphics.setFont(fonts.button)
    local h = fonts.button:getHeight()
    for _,button in ipairs(buttons) do
      graphics.push()
      graphics.translate(button.x, button.y)
      graphics.setColor(120, 120, 120, 255)
      graphics.rectangle('fill', 0, 0, button.w, button.h)
      graphics.setColor(255, 255, 255, 255)
      graphics.printf(button.token, 0, button.h/2 - h/2, button.w, 'center')
      graphics.pop()
    end
    graphics.setFont(fonts.normal)
  end
  do -- Stack
    graphics.push()
    graphics.translate(W/10, 128 + 32 + 16)
    graphics.setColor(40, 40, 40, 255)
    graphics.rectangle('fill', -DW/4, -DH/2, 1.5*DW, (MAX_SIZE + 1)*DH)
    graphics.setColor(200, 150, 20, 255)
    graphics.rectangle('line', -DW/4, -DH/2, 1.5*DW, (MAX_SIZE + 1)*DH)
    graphics.setColor(255, 255, 255, 255)
    -- Falling number
    if transfer > 0 then
      graphics.printf(input[1],
                      0, (transfer)*(MAX_SIZE-#stack-1)*DH,
                      DW, 'center')
      if type(input[1]) == 'string' then
        graphics.rectangle('line', 0, (MAX_SIZE - #stack)*DH - 2, DW, 2*DH + 4)
      end
    end
    -- Stack content
    for i,token in ipairs(stack) do
      graphics.printf(token, 0, (MAX_SIZE - i)*DH, DW, 'center')
    end
    graphics.pop()
  end
end


local yield = coroutine.yield

local W, H
local graphics
local transfer
local buttons
local fonts

local input, stack
local calculator
local processor

local MAX_SIZE = 16
local DW, DH = 40, 24
local DELAY = .5
local TRANSFER = .6

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
    if token == 'ERR' then
      print("Oooppps")
    elseif type(token) == 'number' then
      table.insert(stack, token)
    elseif type(token) == 'string' then
      if  type(stack[#stack]) ~= 'number' or type(stack[#stack - 1]) ~= 'number'
          then
        stack = { 'ERR' }
      else
        -- WARNING: order must be inverted
        local y, x = table.remove(stack), table.remove(stack)
        table.insert(stack, OP[token](x, y))
      end
    end
    table.remove(input, 1)
    yield(#input <= 0)
  end
end

local function makeUpdater ()
  return coroutine.wrap(function (dt)
    local finished
    while true do
      while transfer < TRANSFER do
        transfer = math.min(transfer + yield(), 1)
      end
      -- Pause if operator
      if type(input[1]) == 'string' then
        local wait = 1
        while wait > 0 do
          wait = wait - yield()
        end
      end
      transfer = 0
      if calculator() then
        processor = nil
        break
      end
      local time = DELAY
      while time > 0 do
        time = time - yield()
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
  W, H = graphics.getDimensions()
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
  buttons[16] = makeButton('CLEAR', W/3 + 4*96, H/3, 128, 64)
  graphics.setBackgroundColor(90, 90, 90, 255)
end

function love.mousereleased (x, y, button)
  if processor then return end
  for i,button in ipairs(buttons) do
    if  x > button.x and x < button.x + button.w and
        y > button.y and y < button.y + button.h then
      if button.token == '=' then
        processor = makeUpdater()
      elseif button.token == 'CLEAR' then
        processor = nil
        love.load()
      else
        table.insert(input, button.token)
      end
    end
  end
end

function love.keypressed (key)
  if key == 'return' then
    processor = makeUpdater()
  elseif key == 'escape' then
    processor = nil
    love.load()
  end
end

function love.textinput (key)
  if processor then return end
  local token = tonumber(key) or key
  if VALID[token] and #input < 16 then
    table.insert(input, token)
  end
end

function love.update (dt)
  if love.mouse.isDown(1) then
    local x, y = love.mouse.getPosition()
    for _,button in ipairs(buttons) do
      if  x > button.x and x < button.x + button.w and
          y > button.y and y < button.y + button.h then
        button.pressed = true
      end
    end
  end
  if processor then
    processor(dt)
  end
end

function love.draw ()
  graphics.setFont(fonts.normal)
  graphics.setColor(255, 255, 255, 255)
  do -- Input
    graphics.push()
    graphics.translate(W/10, 32)
    graphics.print("Input:", 0, 0)
    graphics.setColor(0, 0, 0, 255)
    graphics.rectangle('fill', 0, 64 - DH/2, MAX_SIZE*DW, 2*DH)
    graphics.setColor(255, 255, 255, 255)
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
      if button.pressed then
        graphics.translate(button.x + 4, button.y + 4)
      else
        graphics.translate(button.x, button.y)
      end
      button.pressed = false
      graphics.setColor(120, 120, 180, 255)
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
    graphics.setColor(150, 80, 40, 255)
    graphics.rectangle('fill', -DW/4, -DH/2, 1.5*DW, (MAX_SIZE + 1)*DH)
    graphics.setColor(200, 150, 20, 255)
    graphics.rectangle('line', -DW/4, -DH/2, 1.5*DW, (MAX_SIZE + 1)*DH)
    graphics.setColor(255, 255, 255, 255)
    -- Falling number
    if transfer > 0 then
      graphics.printf(input[1],
                      0, (transfer/TRANSFER)*(MAX_SIZE-#stack-1.5)*DH,
                      DW, 'center')
      if type(input[1]) == 'string' then
        graphics.rectangle('line', -4, (MAX_SIZE - #stack)*DH - 2,
                           DW + 8, 2*DH + 4)
      end
    end
    -- Stack content
    for i,token in ipairs(stack) do
      local view
      if  type(token) == 'number' and
          math.abs(math.floor(token) - token) > 1e-10 then
        view = string.format("%.2f", token)
      else
        view = token
      end
      graphics.printf(view, 0, (MAX_SIZE - i)*DH, DW, 'center')
    end
    graphics.pop()
  end
end

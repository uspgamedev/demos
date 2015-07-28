
local W, H
local graphics
local smallfont
local bigfont
local biggerfont

local buttons

local current
local searcher
local P, Q

local function makeButton (x, y, text, color)
  return {
    x = x,
    y = y,
    text = text,
    color = color,
    focus = 0
  }
end

local function getButton (x, y)
  for _,button in ipairs(buttons) do
    if x > button.x - 100 and x < button.x + 100 and
       y > button.y - 25 and y < button.y + 25 then
      return button
    end
  end
end

local function binsearch ()
  return coroutine.wrap(function (p, q)
    while true do
      local m = math.floor((p+q)/2)
      if coroutine.yield(m) then
        p, q = m+1, q
      else
        p, q = p, m
      end
    end
  end)
end

function love.load ()
  -- Aux
  W, H = love.window.getDimensions()
  graphics = love.graphics
  searcher = binsearch()
  smallfont = graphics.newFont(16)
  bigfont = graphics.newFont(42)
  biggerfont = graphics.newFont(64)
  P, Q = 1, 1000
  current = searcher(P, Q)
  -- UI
  buttons = {
    makeButton(W/2, 4*H/6, "YES", {100, 255, 100, 255}),
    makeButton(W/3, 5*H/6, "SMALLER", {255, 255, 255, 255}),
    makeButton(2*W/3, 5*H/6, "GREATER", {255, 255, 255, 255}),
  }
  -- Graphics setup
  graphics.setPointStyle 'smooth'
  graphics.setPointSize(10)
end

function love.keypressed (key)
  if key == 'left' then
    current = searcher(false)
  elseif key == 'right' then
    current = searcher(true)
  end
end

function love.mousepressed (x, y, button)
  for _,button in ipairs(buttons) do
    local d2 = (x - button.x)^2 + (y - button.y)^2
    if d2 < 100*100 then
      if button.text == 'SMALLER' then
        current = searcher(false)
      elseif button.text == 'GREATER' then
        current = searcher(true)
      end
    end
  end
end

function love.update (dt)
  local focused_button = getButton(love.mouse.getPosition())
  if focused_button then
    focused_button.focus = math.min(focused_button.focus + dt, .2)
  end
  for _,button in ipairs(buttons) do
    if button ~= focused_button then
      button.focus = math.max(button.focus - dt, 0)
    end
  end
end

function love.draw ()
  graphics.setColor(255, 255, 255, 255)
  -- Interval line
  graphics.setFont(smallfont)
  graphics.line(W/8, 64, 7*W/8, 64)
  graphics.point(W/8, 64)
  graphics.printf(P, W/8 - 16, 64 + 12, 32, 'center')
  graphics.point(7*W/8, 64)
  graphics.printf(Q, 7*W/8 - 16, 64 + 12, 32, 'center')
  -- Big number
  graphics.setFont(biggerfont)
  graphics.printf(current.."?", W/2 - 100, H/3, 200, 'center')
  -- Actions
  graphics.setFont(bigfont)
  for _,button in ipairs(buttons) do
    graphics.setColor(button.color)
    graphics.push()
    graphics.translate(button.x, button.y)
    graphics.scale(1 + button.focus, 1 + button.focus)
    graphics.printf(button.text, -100, -25, 200, 'center')
    graphics.pop()
  end
end


local W, H
local graphics
local smallfont
local bigfont
local biggerfont

local buttons

local current, p, q
local searcher
local P, Q
local tries

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
      if coroutine.yield(m, p, q) then
        p, q = m+1, q
      else
        p, q = p, m
      end
      tries = tries + 1
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
  tries = 1
  current, p, q = searcher(P, Q)
  -- UI
  buttons = {
    makeButton(W/2, 4*H/6, "YES", {100, 255, 100, 255}),
    makeButton(W/3, 5*H/6, "SMALLER", {200, 0, 0, 255}),
    makeButton(2*W/3, 5*H/6, "GREATER", {200, 0, 0, 255}),
  }
  -- Graphics setup
  graphics.setPointStyle 'smooth'
  graphics.setPointSize(10)
end

function love.keypressed (key)
  if key == 'left' then
    current, p, q = searcher(false)
  elseif key == 'right' then
    current, p, q = searcher(true)
  elseif key == 'escape' then
    love.load()
  end
end

function love.mousepressed (x, y, button)
  local button = getButton(x, y)
  if not button then return end
  if button.text == 'SMALLER' then
    current, p, q = searcher(false)
  elseif button.text == 'GREATER' then
    current, p, q = searcher(true)
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
  graphics.setLineWidth(1)
  graphics.line(W/8, 64, 7*W/8, 64)
  graphics.setLineWidth(4)
  graphics.setColor(100, 100, 255, 255)
  graphics.line(W/8 + (6*W/8)*((p-P)/(Q-P)), 64,
                W/8 + (6*W/8)*((q-P)/(Q-P)), 64)
  graphics.setColor(255, 255, 255, 255)
  graphics.point(W/8, 64)
  graphics.printf(P, W/8 - 16, 64 + 12, 32, 'center')
  graphics.point(7*W/8, 64)
  graphics.printf(Q, 7*W/8 - 16, 64 + 12, 32, 'center')
  graphics.setColor(200, 0, 0, 255)
  graphics.point(W/8 + (6*W/8)*(current/(Q - P)), 64)
  -- Tries counter
  graphics.setColor(200, 200, 0, 255)
  graphics.setFont(smallfont)
  graphics.print("#"..tries, W/8, H/4)
  -- Big number
  graphics.setColor(255, 255, 255, 255)
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

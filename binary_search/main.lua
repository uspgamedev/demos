
local W, H
local current
local searcher

local function binsearch ()
  return coroutine.wrap(function (P, Q)
    while true do
      local m = math.floor((P+Q)/2)
      if coroutine.yield(m) then
        P, Q = m+1, Q
      else
        P, Q = P, m
      end
    end
  end)
end

function love.load ()
  W, H = love.window.getDimensions()
  love.graphics.setFont(love.graphics.newFont(42))
  searcher = binsearch()
  current = searcher(1, 1000)
end

function love.keypressed (key)
  if key == 'left' then
    current = searcher(false)
  elseif key == 'right' then
    current = searcher(true)
  end
end

function love.draw ()
  local g = love.graphics
  g.printf(current, W/2 - 100, H/2 - 50, 200, 'center')
end

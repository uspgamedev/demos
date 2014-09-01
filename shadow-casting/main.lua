
local lines

function love.load (...)
  lines = {}
  for i=1,10 do
    local x, y = love.math.random(), love.math.random()
    table.insert(lines, {})
  end
end


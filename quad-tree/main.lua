max_elem = 5

function contains(b, p)
  if p[1] < b[1] or p[1] > b[1] + b[3] then return false end
  if p[2] < b[2] or p[2] > b[2] + b[4] then return false end
  return true
end

function collides(b1, b2)
  if b1[1] > b2[1] + b2[3] then return false end
  if b1[1] + b1[3] < b2[1] then return false end
  if b1[2] > b2[2] + b2[4] then return false end
  if b1[2] + b1[4] < b1[2] then return false end
  return true
end

function raw_q(bounds)
  return {bounds = bounds, elem = {}}
end

function subdivide(q)
  local b = q.bounds
  q.sons = {
    raw_q{b[1], b[2], b[3]/2, b[4]/2},
    raw_q{b[1] + b[3]/2, b[2], b[3]/2, b[4]/2},
    raw_q{b[1], b[2] + b[4]/2, b[3]/2, b[4]/2},
    raw_q{b[1] + b[3]/2, b[2] + b[4]/2, b[3]/2, b[4]/2}
  }
  for i = 1, max_elem do
    for j = 1, 4 do
      if add_point(q.sons[j], q.elem[i]) then break end
    end
  end
  q.elem = nil
end

function add_point(q, p)
  if not contains(q.bounds, p) then return false end
  if q.elem and #q.elem < max_elem then
    q.elem[#q.elem+1] = p
    return true
  end
  if not q.sons then subdivide(q) end
  for i = 1, 4 do
    if add_point(q.sons[i], p) then return true end
  end
  error "waaaaa"
end

function push(na, nb)
  if not nb then return na end
  na.next = nb
  nb.prev = na
  return nb
end

function query_area(q, bound)
  local a = {}
  local cur = a
  if not collides(bound, q.bounds) then return a end
  if q.sons then
    for i = 1, 4 do
      cur = push(cur, query_area(q.sons[i], bound).next)
    end
  else
    for i = 1, #q.elem do
      if contains(bound, q.elem[i]) then
        cur = push(cur, {q.elem[i]})
      end
    end
  end
  return a
end

quad = raw_q{0, 0, 800, 600}
size = 30
elems = {}
local r = math.random
r() r()
local red = {255, 0, 0}
local white = {255, 255, 255}
local green = {0, 255, 0}
for i = 1, 100 do
  local e = {r(800-size), r(600-size)}
  e.color = white
  elems[#elems + 1] = e
  add_point(quad, e)
end

for i = 1, 100 do
  local e = elems[i]
  local q = query_area(quad, {e[1], e[2], size, size}).next
  if q.next then e.color = red end
  while q.next do
    q = q.next
    q[1].color = red
  end
end

function draw_quad(q, color)
  love.graphics.setColor(color)
  love.graphics.rectangle('line', unpack(q.bounds))
  if q.sons then
    local c = {color[1] * .8, color[2] * .8, color[3] * .8, color[4] * .8}
    for i = 1, 4 do
      draw_quad(q.sons[i], c)
    end
  end
end

function love.draw()
  draw_quad(quad, {0, 255, 0, 100})
  for _, e in ipairs(elems) do
    love.graphics.setColor(e.color)
    love.graphics.rectangle('fill', e[1], e[2], size, size)
  end
end
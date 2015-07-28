
local states = {
 guess = require 'guess',
 done = require 'done',
 start = require 'start'
}

local callbacks = {
  'update', 'draw', 'keypressed', 'mousepressed'
}

local first_state = 'start'

function setState (name)
  local state = states[name]
  for _,callback in ipairs(callbacks) do
    love[callback] = state[callback]
  end
  state.load()
end

function love.load ()
  setState(first_state)
end

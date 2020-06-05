local tick_handler
script = {}
function script.on_nth_tick(interval, handler)
  tick_handler = handler
end

global = {}


local EntityQueue = require "EntityQueue"
local task = function()
  return false
end
local q = EntityQueue.new("test", 1, task)
q:on_init()

local en = {
  valid = true,
  unit_number = 1,
}
local en2 = {
  valid = true,
  unit_number = 2,
}
local en3 = {
  valid = true,
  unit_number = 3,
}
q:register(en)
q:register(en2)
tick_handler{nth_tick=1}
q:unregister(en)
q:unregister(en3)
tick_handler{nth_tick=1}
tick_handler{nth_tick=1}
-- Tiny event bus between the script modules (avoids require cycles). Handlers are registered once
-- when control.lua is loaded, in a fixed order.
local bus = {handlers = {}}

function bus.on(name, fn)
  local list = bus.handlers[name]
  if not list then
    list = {}
    bus.handlers[name] = list
  end
  list[#list + 1] = fn
end

function bus.emit(name, ...)
  local list = bus.handlers[name]
  if not list then return end
  for i = 1, #list do list[i](...) end
end

return bus

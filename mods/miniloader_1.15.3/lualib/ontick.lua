--[[
    Utilities for managing the on_tick event, periodically invoking
    handlers.
]]

local event = require "lualib.event"

local M = {}

local on_tick_handlers = {}
local function on_tick_meta_handler(e)
  for handler, interval in pairs(on_tick_handlers) do
    if e.tick % interval == 0 then
      handler(e)
    end
  end
end

function M.register(f, interval)
  if not interval then
    interval = 12
  end
  if interval < 0 then
    error("invalid interval")
  end
  on_tick_handlers[f] = interval
  event.register(defines.events.on_tick, on_tick_meta_handler)
end

function M.unregister(f)
  on_tick_handlers[f] = nil
  if not next(on_tick_handlers) then
    event.unregister(defines.events.on_tick, on_tick_meta_handler)
  end
end

return M

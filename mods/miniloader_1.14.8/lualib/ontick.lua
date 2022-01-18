--[[
    Utilities for managing the on_tick event, periodically invoking
    handlers.
]]

local event = require "lualib.event"

local M = {}

local on_tick_handlers = {}
local function on_tick_meta_handler(e)
  for handler, config in pairs(on_tick_handlers) do
    if (e.tick - config[2]) % config[1] == 0 then
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
  math.randomseed(game.tick)
  local offset = math.random(interval) - 1
  on_tick_handlers[f] = { interval, offset }
  event.register(defines.events.on_tick, on_tick_meta_handler)
end

function M.unregister(f)
  on_tick_handlers[f] = nil
  if not next(on_tick_handlers) then
    event.unregister(defines.events.on_tick, on_tick_meta_handler)
  end
end

return M
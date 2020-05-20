local M = {}

--[[
  handlers[event_id] = { [handler1] = true, [handler2] = true, ... }
]]
local handlers_for = {}

local function dispatch(event)
  for handler in pairs(handlers_for[event.name]) do
    handler(event)
  end
end

--[[
  nth_tick_handlers_for[interval] = { [handler1] = true, ... }
]]
local nth_tick_handlers_for = {}

local function dispatch_nth_tick(event)
  for handler in pairs(nth_tick_handlers_for[event.nth_tick]) do
    handler(event)
  end
end

function M.register(events, handler)
  if type(events) ~= "table" then
    events = {events}
  end

  for _, event_id in ipairs(events) do
    -- debug("registering for " .. (event_names[event_id] or event_id))
    local handlers = handlers_for[event_id]
    if not handlers then
      handlers = {}
      handlers_for[event_id] = handlers
    end

    if not next(handlers) then
      script.on_event(event_id, dispatch)
    end

    handlers[handler] = true
  end
end

function M.unregister(events, handler)
  if type(events) ~= "table" then
    events = {events}
  end

  for _, event_id in ipairs(events) do
    -- debug("unregistering for " .. (event_names[event_id] or event_id))
    local handlers = handlers_for[event_id]
    if handlers then
      handlers[handler] = nil
      if not next(handlers) then
        script.on_event(event_id, nil)
      end
    end
  end
end

function M.register_nth_tick(interval, handler)
  local handlers = nth_tick_handlers_for[interval]
  if not handlers then
    handlers = {}
    nth_tick_handlers_for[interval] = handlers
  end
  if not next(handlers) then
    script.on_nth_tick(interval, dispatch_nth_tick)
  end
  handlers[handler] = true
end

function M.unregister_nth_tick(interval, handler)
  local handlers = nth_tick_handlers_for[interval]
  if handlers then
    handlers[handler] = nil
    if not next(handlers) then
      script.on_nth_tick(interval, nil)
    end
  end
end

return M
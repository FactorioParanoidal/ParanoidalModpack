local M = {}

local event_names = {}
for name, id in pairs(defines.events) do
  event_names[id] = name
end

--[[
  handlers[event_id] = { [handler1] = true, [handler2] = true, ... }
]]
local handlers_for = {}

local function dispatch(event)
  for handler in pairs(handlers_for[event.name]) do
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

return M
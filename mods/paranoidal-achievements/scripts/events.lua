-- One event dispatch for the whole mod. script.on_event keeps one handler per event, so the
-- milestones and the achievements add their handlers here and control.lua registers each event once.
--   events.on(event, fn, filter): event = an id of defines.events or a custom-input name. With a filter
--   the handler shares the event with the others; the event is filtered only when every handler of
--   it has a filter (the lists are joined), so a handler must still check what it gets.
--   events.register() is called once, at the end of control.lua.

local events = {}

local handlers = {}   -- event -> list of functions, in the order they were added
local filters = {}    -- event -> joined filter list, or false when a handler takes every event
local order = {}      -- events in the order they were first added (deterministic registration)

function events.on(event, fn, filter)
  if event == nil then error("events.on: unknown event") end
  local list = handlers[event]
  if not list then
    list = {}
    handlers[event] = list
    order[#order + 1] = event
  end
  list[#list + 1] = fn
  if filter == nil or #filter == 0 then
    filters[event] = false
  elseif filters[event] ~= false then
    local joined = filters[event] or {}
    for _, item in ipairs(filter) do joined[#joined + 1] = item end
    filters[event] = joined
  end
end

function events.register()
  for _, event in ipairs(order) do
    local list = handlers[event]
    local handler
    if #list == 1 then
      handler = list[1]
    else
      handler = function(e)
        for i = 1, #list do list[i](e) end
      end
    end
    local filter = filters[event]
    script.on_event(event, handler, filter or nil)
  end
end

return events

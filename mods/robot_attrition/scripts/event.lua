Event = { listeners = {} }

-- can add multiple listeners to the same event.
-- event_key can be a uint of native events (defines.events)
-- event_key can be a string for custom input of virtual events
-- if a virtual event is added, set virtual = true
  -- on_init, on_load, on_configuration_changed get triggered automatically as virtual events
Event.addListener = function(event_key, add_callback, virtual)
  if not Event.listeners[event_key] then
    Event.listeners[event_key] = {}
    Event.listeners[event_key].callbacks = {}
    Event.listeners[event_key].sequence = function (event)
      for _, callback in pairs(Event.listeners[event_key].callbacks) do
        callback(event)
      end
    end
    if not virtual then -- custom input eventsm only works after on_init
        script.on_event(event_key, Event.listeners[event_key].sequence)
    end
    table.insert(Event.listeners[event_key].callbacks, add_callback)
  else
    for _, callback in pairs(Event.listeners[event_key].callbacks) do
      if callback == add_callback then return end
    end
    if not exists then
      table.insert(Event.listeners[event_key].callbacks, add_callback)
    end
  end
end

-- can add multiple listneers to the same event.
Event.removeListener = function(event_key, remove_callback)
  if not Event.listeners[event_key] then return end
  for _, callback in pairs(Event.listeners[event_key].callbacks) do
    if callback == remove_callback then
      Event.listeners[event_key].callbacks[_] = nil
    end
  end
end

Event.trigger = function(event_key, event_data)
  if Event.listeners[event_key] then
    Event.listeners[event_key].sequence(event_data)
  end
end

script.on_init(function(event) Event.trigger("on_init", event) end)
script.on_load(function(event) Event.trigger("on_load", event) end)
script.on_configuration_changed(function(event) Event.trigger("on_configuration_changed", event) end)

return Event

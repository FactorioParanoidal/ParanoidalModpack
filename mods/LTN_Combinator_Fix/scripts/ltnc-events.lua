ltnc_events = {
  map_gui_opened   = {},
  map_gui_closed   = {},
  map_checked      = {},
  map_text_changed = {},
  map_elem_changed = {},
  map_clicked      = {},
  map_slider       = {},
}

ltnc_events.on_gui_opened = function(event)
  if not event.entity or not ltnc_events.map_gui_opened[event.entity.name] then return end
  ltnc_events.map_gui_opened[event.entity.name](event)
end

ltnc_events.on_gui_closed = function(event)
  if not event.element or not ltnc_events.map_gui_closed[event.element.name] then return end
  ltnc_events.map_gui_closed[event.element.name](event)
end

ltnc_events.on_gui_clicked = function(event) 
  if not event.element or not ltnc_events.map_clicked[event.element.name] then return end
  ltnc_events.map_clicked[event.element.name](event)
end

ltnc_events.on_gui_text_changed = function(event) 
  if not event.element or not ltnc_events.map_text_changed[event.element.name] then return end
  ltnc_events.map_text_changed[event.element.name](event)
end

ltnc_events.on_gui_checked_state = function(event) 
  if not event.element or not ltnc_events.map_checked[event.element.name] then return end
  ltnc_events.map_checked[event.element.name](event)
end

ltnc_events.on_gui_elem_changed = function(event) 
  if not event.element or not ltnc_events.map_elem_changed[event.element.name] then return end
  ltnc_events.map_elem_changed[event.element.name](event)
end

ltnc_events.on_gui_slider_changed = function(event) 
  if not event.element or not ltnc_events.map_slider[event.element.name] then return end
  ltnc_events.map_slider[event.element.name](event)
end

script.on_event({defines.events.on_gui_opened}, ltnc_events.on_gui_opened)
script.on_event({defines.events.on_gui_closed}, ltnc_events.on_gui_closed)
script.on_event({defines.events.on_gui_click}, ltnc_events.on_gui_clicked)
script.on_event({defines.events.on_gui_text_changed}, ltnc_events.on_gui_text_changed)
script.on_event({defines.events.on_gui_checked_state_changed}, ltnc_events.on_gui_checked_state)
script.on_event({defines.events.on_gui_elem_changed}, ltnc_events.on_gui_elem_changed)
script.on_event({defines.events.on_gui_value_changed}, ltnc_events.on_gui_slider_changed)
--script.on_event("ltnc-tab-key-event", ltnc.gui.on_tab_key)

return ltnc_events
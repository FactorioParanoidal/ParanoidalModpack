local circuit = require "circuit"
local event = require "lualib.event"
local ontick = require "lualib.ontick"
local util = require "lualib.util"

-- how often to poll ControlBehavior settings when a miniloader-inserter GUI is open
local POLL_INTERVAL = 15

local monitored_entities = {}

local function should_monitor_entity(entity)
  return util.is_miniloader(entity) or util.is_miniloader_inserter(entity)
end

local function monitor_open_guis(_)
  if not next(monitored_entities) then
    ontick.unregister(monitor_open_guis)
  end
  for k, entity in pairs(monitored_entities) do
    if entity.valid then
      circuit.sync_filters(entity)
      circuit.sync_behavior(entity)
    else
      monitored_entities[k] = nil
    end
  end
end

local function on_gui_opened(ev)
  local entity = ev.entity
  if entity and should_monitor_entity(entity) then
    monitored_entities[entity.unit_number] = entity
    ontick.register(monitor_open_guis, POLL_INTERVAL)
  end
end

local function on_gui_closed(ev)
  local entity = ev.entity
  if entity and should_monitor_entity(entity) then
    circuit.sync_behavior(entity)
    circuit.sync_filters(entity)
    monitored_entities[entity.unit_number] = nil
  end
end

event.register(defines.events.on_gui_opened, on_gui_opened)
event.register(defines.events.on_gui_closed, on_gui_closed)

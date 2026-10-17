local starting_items = require("src.starting_items")
local ground_water_pump = require("src.ground_water_pump")
local sea_pump = require("src.sea-pump")

-- Derive the filter from the same saved prototype name used by the removal handler.
local function refresh_death_filter()
  local data = storage.SP_data
  if not (data and data.prototype_data and data.prototype_data.sea_pump_name) then
    script.set_event_filter(defines.events.on_entity_died, nil)
    return
  end
  script.set_event_filter(defines.events.on_entity_died, {
    { filter = "name", name = sea_pump:get_pump_name() },
  })
end

-- initialisation
local on_configuration_changed = require("src.mod-config")
script.on_configuration_changed(function(event)
  on_configuration_changed(event)
  refresh_death_filter()
end)
script.on_init(function()
  starting_items:on_init()
  sea_pump:on_init()
  refresh_death_filter()
end)
script.on_load(refresh_death_filter)

-- built events
script.on_event(defines.events.on_built_entity, function(event)
  sea_pump:on_build_entity(event.entity, event.tags or {})
end)
script.on_event(defines.events.on_robot_built_entity, function(event)
  sea_pump:on_build_entity(event.created_entity, event.tags or {})
end)
script.on_event(defines.events.script_raised_built, function(event)
  sea_pump:on_build_entity(event.entity, {})
end)
script.on_event(defines.events.script_raised_revive, function(event)
  sea_pump:on_build_entity(event.entity, {})
end)
script.on_event(defines.events.on_post_entity_died, function(event)
  sea_pump:on_build_entity(event.ghost, {})
end)

script.on_event(defines.events.on_player_rotated_entity, function(event)
  ground_water_pump:on_player_rotated_entity(event.entity, event.previous_direction, event.player_index)
end)

-- destroy events
script.on_event(defines.events.on_entity_died, function(event)
  sea_pump:on_remove_entity(event.entity)
end)
script.on_event(defines.events.on_player_mined_entity, function(event)
  sea_pump:on_remove_entity(event.entity)
end)
script.on_event(defines.events.on_robot_mined_entity, function(event)
  sea_pump:on_remove_entity(event.entity)
end)
script.on_event(defines.events.script_raised_destroy, function(event)
  sea_pump:on_remove_entity(event.entity)
end)

-- blueprint events
script.on_event(defines.events.on_player_setup_blueprint, function(event)
  sea_pump:on_blueprint_setup(event.player_index)
end)
script.on_event(defines.events.on_player_configured_blueprint, function(event)
  sea_pump:on_blueprint_setup(event.player_index)
end)

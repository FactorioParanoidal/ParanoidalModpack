require "scripts.turbine"

function built_entity(event)
  local entity = event.created_entity or event.entity
	if entity.name == "wind-turbine-2" then
    return built_interface(entity)
	end
end


script.on_event(defines.events.on_tick, function(event)
  check_interfaces()
end)

script.on_nth_tick(24999, change_wind_day)
script.on_nth_tick(2499, change_wind_hour)
script.on_nth_tick(249, tick_wind)

script.on_event(defines.events.on_built_entity, built_entity)
script.on_event(defines.events.on_robot_built_entity, built_entity)
script.on_event(defines.events.script_raised_revive, built_entity)
script.on_event(defines.events.script_raised_built, built_entity)
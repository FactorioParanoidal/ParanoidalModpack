require "entitytracker"
--require "eventhandling"

function initGlobal(markDirty)
	if not global.dragonindustries then
		global.dragonindustries = {}
	end
	local di = global.dragonindustries
	di.dirty = markDirty
end

script.on_configuration_changed(function(data)
	initGlobal(true)
	
	
end)

script.on_init(function()
	initGlobal(true)
end)

script.on_load(function()

end)

function onCommand(event)

end

function onEntityRotated(event)

end

function onEntityAdded(event)

end

function onEntityRemoved(event)

end

function onEntityDied(event)
	onEntityRemoved(event)
end

function onGameTick(event)	
	local tick = event.tick
end

script.on_event(defines.events.on_console_command, onCommand)

script.on_event(defines.events.on_entity_died, onEntityDied)
script.on_event(defines.events.on_pre_player_mined_item, onEntityRemoved)
script.on_event(defines.events.on_robot_pre_mined, onEntityRemoved)
script.on_event(defines.events.script_raised_destroy, onEntityRemoved)

script.on_event(defines.events.on_built_entity, onEntityAdded)
script.on_event(defines.events.on_robot_built_entity, onEntityAdded)

script.on_event(defines.events.on_player_rotated_entity, onEntityRotated)

--script.on_event(defines.events.on_entity_damaged, onEntityDamaged)

script.on_event(defines.events.on_tick, onGameTick)
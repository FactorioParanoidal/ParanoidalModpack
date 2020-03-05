--[[ Copyright (c) 2018 Optera
 * Part of Train Overhaul
 *
 * See LICENSE.md in the project directory for license information.
--]]

-- register events according to mod settings
script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	if event.setting == "train-overhaul-nuclear-loco-explosion" then
		if settings.global["train-overhaul-nuclear-loco-explosion"].value then
			script.on_event(defines.events.on_entity_died, OnEntityDied)
		else
			script.on_event(defines.events.on_entity_died, nil)
		end
	end
end)

-- trigger nuclear explosion when nuclear locomotive gets destroyed
function OnEntityDied(event)
	if event.entity.name == "nuclear-locomotive" then
		event.entity.surface.create_entity{name = "atomic-rocket", position = event.entity.position, force = event.entity.force, target = event.entity, speed = 1000}
	end
end

---- Bootstrap ----
do
local function init_events()
	if settings.global["train-overhaul-nuclear-loco-explosion"].value then
		script.on_event(defines.events.on_entity_died, OnEntityDied)
	else
		script.on_event(defines.events.on_entity_died, nil)
	end
end

script.on_load(function()
	init_events()
end)

script.on_init(function()
	init_events()
end)

script.on_configuration_changed(function(data)
	init_events()
end)
end
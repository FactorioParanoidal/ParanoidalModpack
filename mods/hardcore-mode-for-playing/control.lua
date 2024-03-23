require("__automated-utility-protocol__.util.main")
require("scripts.init_event")
require("scripts.disabling_events")
require("scripts.player_mined_events")
local function on_runtime_mod_setting_changed(event)
	if settings.global["disable-hand-resource-mining"].value then
		script.on_event(
			{ defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity },
			on_player_mined_entity
		)
		script.on_event({ defines.events.on_player_mined_item }, on_player_mined_item)
	else
		script.on_event({ defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity }, nil)
		script.on_event({ defines.events.on_player_mined_item }, nil)
	end
	if
		settings.global["disable-hand-crafting"].value
		or settings.global["enable-technology-research-reevaluting"].value
		or settings.global["disable-production-entities-beyond-factorissimo-building"].value
	then
		script.on_event(defines.events.on_tick, on_tick_disabling_event)
		script.on_event(
			{ defines.events.on_built_entity, defines.events.script_raised_built },
			on_built_disabling_event
		)
		script.on_load(on_load_disabling_event)
	else
		script.on_event(defines.events.on_tick, nil)
		script.on_event({ defines.events.on_built_entity, defines.events.script_raised_built }, nil)
		script.on_load(nil)
	end
end

script.on_event(defines.events.on_runtime_mod_setting_changed, on_runtime_mod_setting_changed)
on_runtime_mod_setting_changed()

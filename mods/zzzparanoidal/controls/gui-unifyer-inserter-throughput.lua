local mod_gui = require("mod-gui")

if not (script.active_mods["GUI_Unifyer"] and script.active_mods["inserter-throughput"]) then
	return
end

local function update_inserter_throughput_button(event)
	if event.setting ~= "inserter-throughput-enabled" or not event.player_index then
		return
	end

	local player = game.get_player(event.player_index)
	if not player then
		return
	end

	local button = mod_gui.get_button_flow(player)["inserter-throughput-toggle"]
	if not (button and button.valid) then
		return
	end

	local enabled = settings.get_player_settings(player)["inserter-throughput-enabled"].value
	button.sprite = enabled and "inserterthroughput_on_button" or "inserterthroughput_off_button"
	button.tooltip = enabled and {"guiu.inserterthroughput_on_button"} or {"guiu.inserterthroughput_off_button"}
end

script.on_event(defines.events.on_runtime_mod_setting_changed, update_inserter_throughput_button)

require("config")

function init()
	global.mapview = global.mapview or {}
	for i, player in pairs(game.players) do
		if global.mapview[i] == nil then
			global.mapview[i] = player.game_view_settings.show_minimap
		end
	end
end

function toggle_view(player_index, view)
	local settings = game.players[player_index].game_view_settings
	settings[view] = not settings[view]
end

function toggle_view_map(event)
	toggle_view(event.player_index, "show_minimap")
	global.mapview[event.player_index] = game.players[event.player_index].game_view_settings.show_minimap
end

function toggle_view_research(event)
	toggle_view(event.player_index, "show_research_info")
end

function toggle_view_toolbar(event)
	toggle_view(event.player_index, "show_controller_gui")
end

function toggle_view_alerts(event)
	toggle_view(event.player_index, "show_alert_gui")
end

if viewsettings.enable_minimap_hotkey then
	script.on_event("toggle_view_map", toggle_view_map)
end

if viewsettings.enable_research_hotkey then
	script.on_event("toggle_view_research", toggle_view_research)
end

if viewsettings.enable_toolbar_hotkey then
	script.on_event("toggle_view_toolbar", toggle_view_toolbar)
end

if viewsettings.enable_alerts_hotkey then
	script.on_event("toggle_view_alerts", toggle_view_alerts)
end

function set_map_view(player, state)
	if player.game_view_settings.show_minimap ~= state then
		toggle_view(player.index, "show_minimap")
	end
end

function updated_selected(event)
	local player = game.players[event.player_index]
	local selected = player.selected
	if global.mapview[event.player_index] then
		if selected and viewsettings.hide_minimap_on[selected.type] then
			set_map_view(player, false)
		else
			set_map_view(player, true)
		end
	end
end

local autohide_minimap = false
for _, bool in pairs(viewsettings.hide_minimap_on) do
	autohide_minimap = autohide_minimap or bool
end
if autohide_minimap then
	script.on_event(defines.events.on_selected_entity_changed, updated_selected)
end

script.on_init(init)
script.on_configuration_changed(init)
script.on_event(defines.events.on_player_created, init)
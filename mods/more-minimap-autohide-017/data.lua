require("config")

function add_hotkey(keyname, sequence)
	data:extend({{
		type = "custom-input",
		name = keyname,
		key_sequence = sequence,
		consuming = "game-only"
	}})
end

if viewsettings.enable_minimap_hotkey then
	add_hotkey("toggle_view_map", "CONTROL + M")
end

if viewsettings.enable_research_hotkey then
	add_hotkey("toggle_view_research", "CONTROL + T")
end

if viewsettings.enable_toolbar_hotkey then
	add_hotkey("toggle_view_toolbar", "CONTROL + B")
end

if viewsettings.enable_alerts_hotkey then
	add_hotkey("toggle_view_alerts", "CONTROL + N")
end

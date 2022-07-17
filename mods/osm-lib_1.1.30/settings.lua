-- Setup hosts
if not OSM then OSM = {} end
if not OSM.lib then OSM.lib = {} end

require("functions.settings-stage")

local debug_mode =
{
	type = "bool-setting",
	name = "OSM-debug-mode",
	setting_type = "startup",
	default_value = false,
	order = "8==D"
}	data:extend({debug_mode})
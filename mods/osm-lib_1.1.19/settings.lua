-- Setup hosts
if not OSM then OSM = {} end
if not OSM.lib then OSM.lib = {} end

require("functions.settings")

data:extend({
	{
		type = "bool-setting",
		name = "view-internal-names",
		setting_type = "startup",
		default_value = false,
		order = "a-8==D"
	}
})
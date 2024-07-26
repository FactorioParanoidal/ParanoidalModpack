----------------------
---- settings.lua ----
----------------------

-- Make settings
data:extend({
	{
		type = "bool-setting",
		name = "osm-pumps-enable-power",
		setting_type = "startup",
		default_value = true,
		order = "a-8==D"
	},
	{
		type = "bool-setting",
		name = "osm-pumps-power-priority",
		setting_type = "startup",
		default_value = false,
		order = "b-8==D"
	},
	{
		type = "bool-setting",
		name = "osm-pumps-burner-offshore-pump",
		setting_type = "startup",
		default_value = false,
		order = "c-8==D"
	},
	{
		type = "bool-setting",
		name = "osm-pumps-enable-ground-water-pumpjacks",
		setting_type = "startup",
		default_value = true,
		order = "d-8==D"
	},
	{
		type = "bool-setting",
		name = "osm-pumps-landfill-goes-boom",
		setting_type = "startup",
		default_value = true,
		order = "e-8==D"
	},
	{
		type = "bool-setting",
		name = "osm-pumps-boiler-start-water",
		setting_type = "runtime-global",
		default_value = true,
		order = "a-8==D"
    }
})


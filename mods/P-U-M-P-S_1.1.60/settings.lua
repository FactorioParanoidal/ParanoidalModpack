----------------------
---- settings.lua ----
----------------------

-- Make settings
data:extend({
	{
		type = "bool-setting",
		name = "osm-pumps-enable-power", -- enable/disable power requirements
		setting_type = "startup",
		default_value = true,
		order = "a-8==D"
	},
	{
		type = "bool-setting",
		name = "osm-pumps-power-priority", -- set power priority
		setting_type = "startup",
		default_value = false,
		order = "b-8==D"
	},
	{
		type = "bool-setting",
		name = "osm-pumps-burner-offshore-pump", -- enable/disable ground water pumpjacks
		setting_type = "startup",
		default_value = true,
		order = "c-8==D"
	},
	{
		type = "bool-setting",
		name = "osm-pumps-enable-ground-water-pumpjacks", -- enable/disable ground water pumpjacks
		setting_type = "startup",
		default_value = true,
		order = "d-8==D"
	},
	{
		type = "bool-setting",
		name = "osm-pumps-landfill-goes-boom", -- enable/disable ground water pumpjacks
		setting_type = "startup",
		default_value = true,
		order = "e-8==D"
	},
	{
		type = "bool-setting",
		name = "osm-pumps-boiler-start-water", -- spawn boiler with 10 water
		setting_type = "runtime-global",
		default_value = true,
		order = "a-8==D"
    }
})


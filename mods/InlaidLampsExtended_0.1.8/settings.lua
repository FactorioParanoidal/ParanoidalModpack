--settings.lua

data:extend({
	{
		type = "double-setting",
		name = "inlaid-lamps-extended-light_intensity",
		setting_type = "startup",
		default_value = 0.9,
		minimum_value = 0.1,
		maximum_value = 1,
		order = "a-a"
	},
	{
		type = "int-setting",
		name = "inlaid-lamps-extended-light_size",
		setting_type = "startup",
		default_value = 40,
		minimum_value = 1,
		maximum_value = 100,
		order = "a-b"
	},
	{
		type = "double-setting",
		name = "inlaid-lamps-extended-light_colored_intensity",
		setting_type = "startup",
		default_value = 1,
		minimum_value = 0.1,
		maximum_value = 1,
		order = "a-c"
	},
	{
		type = "int-setting",
		name = "inlaid-lamps-extended-light_colored_size",
		setting_type = "startup",
		default_value = 6,
		minimum_value = 1,
		maximum_value = 100,
		order = "a-d"
	},
	{
		type = "double-setting",
		name = "inlaid-lamps-extended-loc_glow_color_intensity",
		setting_type = "startup",
		default_value = 0.235,
		minimum_value = 0.1,
		maximum_value = 1,
		order = "a-e"
	},
	{
		type = "int-setting",
		name = "inlaid-lamps-extended-loc_glow_size",
		setting_type = "startup",
		default_value = 6,
		minimum_value = 1,
		maximum_value = 100,
		order = "a-f"
	},
	{
		type = "bool-setting",
		name = "inlaid_lamps_extended_change_energy_usage",
		setting_type = "startup",
		default_value = false,
		order = "a-g"
	}
})

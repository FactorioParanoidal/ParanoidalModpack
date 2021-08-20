require("names")

data:extend({
	-- startup settings
	{
		type = "bool-setting",
		name = setting_cheatsy_locs,
		setting_type = "startup",
		default_value = false,
		order = "a",
	},
	{
		type = "bool-setting",
		name = setting_cheatsy_wagons,
		setting_type = "startup",
		default_value = false,
		order = "b",
	},
	{
		type = "double-setting",
		name = setting_cheatsy_speed,
		setting_type = "startup",
		default_value = 259.2,
		minimum_value = 10,
		maximum_value = 7386.4,
		order = "c",
	},
	{
		type = "int-setting",
		name = setting_cheatsy_power,
		setting_type = "startup",
		default_value = 600,
		minimum_value = 100,
		maximum_value = 100000,
		order = "d",
	},
	{
		type = "int-setting",
		name = setting_cheatsy_braking,
		setting_type = "startup",
		default_value = 1,
		minimum_value = 0.1,
		maximum_value = 1000,
		order = "e",
	},
	{
		type = "bool-setting",
		name = setting_recycling,
		setting_type = "startup",
		default_value = true,
		order = "f",
	},
	-- runtime-global settings
	{
		type = "bool-setting",
		name = setting_return_partial_batteries,
		setting_type = "runtime-global",
		default_value = true,
		order = "a",
	},
})

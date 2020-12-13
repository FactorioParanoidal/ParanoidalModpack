data:extend({
	{
		type = "int-setting",
		name = "max_night_brightness_percent",
		setting_type = "runtime-global",
		default_value = 15, -- vanilla value
		minimum_value = 0,
		maximum_value = 75,
		order = "nb-a",
	},
	{
		type = "int-setting",
		name = "min_night_brightness_percent",
		setting_type = "runtime-global",
		default_value = 5,
		minimum_value = 0,
		maximum_value = 100,
		order = "nb-b",
	},
	{
		type = "int-setting",
		name = "night_brightness_period_days",
		setting_type = "runtime-global",
		default_value = 64,
		minimum_value = 4,
		maximum_value = 180,
		order = "nb-c",
	},
	{
		type = "bool-setting",
		name = "nb_debug",
		setting_type = "runtime-global",
		default_value = false,
		order = "nb-y",
	},
	{
		type = "bool-setting",
		name = "nb_reset",
		setting_type = "runtime-global",
		default_value = false,
		order = "nb-z-a",
	},
	{
		type = "bool-setting",
		name = "nb_disabled",
		setting_type = "runtime-global",
		default_value = false,
		order = "nb-z-z",
	},
	
	{
		type = "bool-setting",
		name = "nb_black_night",
		setting_type = "startup",
		default_value = true,
		order = "nb-d",
	}
})
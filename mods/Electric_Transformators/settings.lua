

data:extend({
	{
		type = "int-setting",
		name = "trafos-periodic-check",
		setting_type = "startup",
		default_value = 600,
		minimum_value = 0,
		order = "a1",
	},
	{
		type = "int-setting",
		name = "trafos-efficiency",
		setting_type = "startup",
		default_value = 96,
		minimum_value = 1,
		maximum_value = 100,
		order = "a2",
	},
	{
		type = "bool-setting",
		name = "trafos-hide-alt-overlay",
		setting_type = "startup",
		default_value = false,
		order = "a3",
	},

	{
		type = "double-setting",
		name = "trafos-volume",
		setting_type = "startup",
		default_value = 0.3,
		minimum_value = 0,
		maximum_value = 1,
		order = "a4",
	},

})


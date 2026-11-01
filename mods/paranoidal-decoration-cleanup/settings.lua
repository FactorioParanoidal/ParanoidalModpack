-- Setting names come from UnPollock: values saved in mod-settings.dat keep applying.
data:extend{
	{
		type = "double-setting",
		name = "unpollock-decorative-rate",
		setting_type = "startup",
		default_value = 0.7,
		minimum_value = 0,
		maximum_value = 1,
	},
	{
		type = "string-setting",
		name = "unpollock-fake-rocks",
		setting_type = "startup",
		default_value = "by-order",
		allowed_values = {"keep", "by-control", "by-order", "by-name"},
	},
}

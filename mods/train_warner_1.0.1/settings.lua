data:extend({
	{
		type = "bool-setting",
		name = "train_warner_warn_active",
		default_value = true,
		setting_type = "runtime-per-user"
	},
	{
		type = "int-setting",
		name = "train_warner_warn_radius",
		default_value = 100,
		minimum_value = 10,
		maximum_value = 1000,
		setting_type = "runtime-per-user"
	},
	{
		type = "int-setting",
		name = "train_warner_warn_range",
		default_value = 5,
		minimum_value = 0,
		maximum_value = 50,
		setting_type = "runtime-per-user"
	}
})
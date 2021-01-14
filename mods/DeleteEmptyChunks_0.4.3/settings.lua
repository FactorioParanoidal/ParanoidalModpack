data:extend({
	{
		type = "string-setting",
		name = "DeleteEmptyChunks_surface",
		setting_type = "runtime-global",
		default_value = "nauvis",
		order = "1"
	},
	{
		type = "int-setting",
		name = "DeleteEmptyChunks_radius",
		setting_type = "runtime-global",
		minimum_value = 0,
		default_value = 2,
		order = "2"
	},
	{
		type = "bool-setting",
		name = "DeleteEmptyChunks_paving",
		setting_type = "runtime-global",
		default_value = true,
		order = "3"
	}
})

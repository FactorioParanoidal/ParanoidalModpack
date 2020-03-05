data:extend
({
	{
		type = "bool-setting",
		name = "fmf-enable-duct-invariant",
		order = "aa",
		setting_type = "startup",
		default_value = true
	},
	{
		type = "bool-setting",
		name = "fmf-enable-duct-auto-join",
		order = "aa",
		setting_type = "startup",
		default_value = true
	},
	{
		type = "int-setting",
		name = "fmf-underground-duct-max-length",
		order = "ab",
		setting_type = "startup",
		minimum_value = 10,
		maximum_value = 100,
		default_value = 30
	},
	{
		type = "int-setting",
		name = "fmf-duct-health-multiplier",
		order = "ab",
		setting_type = "startup",
		minimum_value = 2,
		maximum_value = 20,
		default_value = 4
	},
	{
		type = "int-setting",
		name = "fmf-duct-base-level-multiplier",
		order = "ab",
		setting_type = "startup",
		minimum_value = 2,
		maximum_value = 20,
		default_value = 4
	}
})
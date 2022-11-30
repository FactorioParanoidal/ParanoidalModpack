data:extend({
	-- Startup
	{
		type = "bool-setting",
		name = "Factorissimo2-alt-graphics",
		setting_type = "startup",
		default_value = false,
		order = "a-a",
	},
	-- Global
	{
		type = "bool-setting",
		name = "Factorissimo2-free-recursion",
		setting_type = "runtime-global",
		default_value = false,
		order = "a-a",
	},
	{
		type = "bool-setting",
		name = "Factorissimo2-hide-recursion",
		setting_type = "runtime-global",
		default_value = false,
		order = "a-b",
	},
	{
		type = "bool-setting",
		name = "Factorissimo2-hide-recursion-2",
		setting_type = "runtime-global",
		default_value = false,
		order = "a-b-a",
	},
	{
		type = "bool-setting",
		name = "Factorissimo2-better-recursion-2",
		setting_type = "runtime-global",
		default_value = true,
		order = "a-c",
	},
	{
		type = "bool-setting",
		name = "Factorissimo2-same-surface",
		setting_type = "runtime-global",
		default_value = true,
		order = "a-d",
	},
	{
		type = "bool-setting",
		name = "Factorissimo2-indestructible-buildings",
		setting_type = "runtime-global",
		default_value = false,
		order = "a-e",
	},

	-- Per user

	{
		type = "int-setting",
		name = "Factorissimo2-preview-size",
		setting_type = "runtime-per-user",
		minimum_value = 50,
		default_value = 300,
		maximum_value = 1000,
		order = "a-b",
	},
	{
		type = "double-setting",
		name = "Factorissimo2-preview-zoom",
		setting_type = "runtime-per-user",
		minimum_value = 0.2,
		default_value = 1,
		maximum_value = 2,
		order = "a-c",
	},
})

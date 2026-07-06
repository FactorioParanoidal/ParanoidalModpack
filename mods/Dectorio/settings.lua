--settings.lua

data:extend(
	{
		{
			type = "bool-setting",
			name = "dectorio-landscaping",
			setting_type = "startup",
			default_value = true,
			order = "a-a"
		},
		{
			type = "bool-setting",
			name = "dectorio-waterfill",
			setting_type = "startup",
			default_value = true,
			order = "a-b"
		},
		{
			type = "bool-setting",
			name = "dectorio-decoratives",
			setting_type = "startup",
			default_value = true,
			order = "a-c"
		},
		{
			type = "bool-setting",
			name = "dectorio-lawnmower",
			setting_type = "startup",
			default_value = true,
			order = "a-ca"
		},
		{
			type = "bool-setting",
			name = "dectorio-wood",
			setting_type = "startup",
			default_value = true,
			order = "a-d"
		},
		{
			type = "bool-setting",
			name = "dectorio-gravel",
			setting_type = "startup",
			default_value = true,
			order = "a-e"
		},
		{
			type = "bool-setting",
			name = "dectorio-concrete",
			setting_type = "startup",
			default_value = true,
			order = "a-f"
		},
		{
			type = "bool-setting",
			name = "dectorio-painted-concrete",
			setting_type = "startup",
			default_value = true,
			order = "a-g"
		},
		{
			type = "bool-setting",
			name = "dectorio-walls",
			setting_type = "startup",
			default_value = true,
			order = "a-h"
		},
		{
			type = "bool-setting",
			name = "dectorio-signals",
			setting_type = "startup",
			default_value = true,
			order = "a-i"
		},
		{
			type = "bool-setting",
			name = "dectorio-item-group",
			setting_type = "startup",
			default_value = true,
			order = "b-a"
		},
		{
			type = "bool-setting",
			name = "dectorio-vanilla-hazard-concrete-style",
			setting_type = "startup",
			default_value = false,
			order = "c-a"
		},
		{
			type = "bool-setting",
			name = "dectorio-landscaping-blueprintable",
			setting_type = "startup",
			default_value = false,
			order = "c-b"
		},
		{
			type = "bool-setting",
			name = "dectorio-remove-decoratives-near-entity",
			setting_type = "startup",
			default_value = true,
			order = "c-c"
		},
		{
			type = "double-setting",
			name = "dectorio-painted-concrete-speed-modifier",
			setting_type = "startup",
			default_value = 1,
			minimum_value = 0.1,
			maximum_value = 1,
			order = "c-d"
		},
		{
			type = "double-setting",
			name = "dectorio-decorative-removal-probability",
			setting_type = "startup",
			default_value = 1,
			minimum_value = 0,
			maximum_value = 1,
			order = "d-a"
		},
		{
			type = "int-setting",
			name = "dectorio-flooring-stack-size",
			setting_type = "startup",
			default_value = 100,
			minimum_value = 100,
			maximum_value = 5000,
			order = "d-b"
		},
		{
			type = "int-setting",
			name = "dectorio-landscaping-stack-size",
			setting_type = "startup",
			default_value = 100,
			minimum_value = 100,
			maximum_value = 5000,
			order = "d-c"
		},
		{
			type = "int-setting",
			name = "dectorio-walls-stack-size",
			setting_type = "startup",
			default_value = 100,
			minimum_value = 100,
			maximum_value = 5000,
			order = "d-d"
		},
		{
			type = "string-setting",
			name = "dectorio-waterfill-tiles",
			setting_type = "startup",
			default_value = "all",
			allowed_values = {"all", "shallow", "deep"},
			order = "d-e"
		}
	}
)

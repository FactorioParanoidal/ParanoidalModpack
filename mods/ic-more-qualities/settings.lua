data:extend(
	{
		{
			type = "bool-setting",
			name = "ic-more-qualities-quality",
			order = "e",
			setting_type = "startup",
			default_value = true
		},
		{
			type = "bool-setting",
			name = "ic-more-qualities-defects-preview",
			order = "f",
			setting_type = "startup",
			default_value = true
		},
		{
			type = "bool-setting",
			name = "ic-more-qualities-quality-everywhere",
			order = "f-0",
			setting_type = "startup",
			default_value = true
		},
		{
			type = "bool-setting",
			name = "ic-more-qualities-defects-weapons",
			order = "f-00",
			setting_type = "startup",
			default_value = false
		},
		{
			type = "string-setting",
			name = "ic-more-qualities-defects-ingredient-mode",
			order = "f-a",
			setting_type = "startup",
			default_value = "materials",
			allowed_values = { "materials", "intermediate-ingredients", "all-ingredients" }
		},
		{
			type = "double-setting",
			name = "ic-more-qualities-defects-pole-supply-reduction",
			order = "f-b",
			setting_type = "startup",
			default_value = 0.5,
			minimum_value = 0,
			maximum_value = 1.5
		},
		{
			type = "double-setting",
			name = "ic-more-qualities-defects-pole-wire-reduction",
			order = "f-c",
			setting_type = "startup",
			default_value = 1,
			minimum_value = 0,
			maximum_value = 7.5
		},
		{
			type = "double-setting",
			name = "ic-more-qualities-multiplier",
			order = "b",
			setting_type = "startup",
			default_value = 1.0,
			minimum_value = 0.01,
			maximum_value = 1000
		},
		{
			type = "double-setting",
			name = "ic-more-qualities-chance-to-upgrade",
			order = "c",
			setting_type = "startup",
			default_value = 0.2,
			minimum_value = 0.001,
			maximum_value = 1
		},
		{
			type = "double-setting",
			name = "ic-more-qualities-chance-dynamic-bonus",
			order = "d",
			setting_type = "startup",
			default_value = -0.004,
			minimum_value = -1,
			maximum_value = 1
		},
		-- Control post: operations paid by one small alien artifact (user decision 2026-10-31).
		{
			type = "int-setting",
			name = "ic-more-qualities-post-operations-per-material",
			order = "g",
			setting_type = "runtime-global",
			default_value = 4,
			minimum_value = 1,
			maximum_value = 1000
		},
	}
)

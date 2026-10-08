data:extend(
	{
		{
			type = "bool-setting",
			name = "ic-more-qualities-defects-preview",
			order = "f",
			setting_type = "startup",
			default_value = true
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
			name = "ic-more-qualities-initial-loss-percent",
			order = "g-a",
			setting_type = "runtime-global",
			default_value = 33,
			minimum_value = 0,
			maximum_value = 100
		},
		{
			type = "bool-setting",
			name = "ic-more-qualities-loss-exclude-finished",
			order = "g",
			setting_type = "runtime-global",
			default_value = false
		},
		{
			type = "string-setting",
			name = "ic-more-qualities-mode",
			order = "a",
			setting_type = "startup",
			default_value = "full",
			allowed_values = { "full", "only-expand", "rework" }
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
		{
			type = "bool-setting",
			name = "ic-more-qualities-early-quality",
			order = "e",
			setting_type = "startup",
			default_value = false
		},
		{
			type = "string-setting",
			name = "ic-more-qualities-localization-full",
			order = "z-a",
			setting_type = "startup",
			default_value = "normal=nil, uncommon=nil, rare=nil, epic=nil, legendary=nil, uncommon-t5=nil, rare-t1=nil, rare-t2=nil, rare-t3=nil, rare-t4=nil, rare-t5=nil, epic-t1=nil, epic-t2=nil, epic-t3=nil, epic-t4=nil, epic-t5=nil, legendary-t1=nil, legendary-t2=nil, legendary-t3=nil, legendary-t4=nil, legendary-t5=nil, unique-t1=nil, unique-t2=nil, unique-t3=nil, unique-t4=nil, unique-t5=nil, astral-t1=nil, astral-t2=nil, astral-t3=nil, astral-t4=nil, astral-t5=nil, quantum-t1=nil, quantum-t2=nil, quantum-t3=nil, quantum-t4=nil, quantum-t5=nil, infernal-t1=nil, infernal-t2=nil, unbreakable=nil, godly=nil, extreme=nil"
		},
		{
			type = "string-setting",
			name = "ic-more-qualities-localization-only-expand",
			order = "z-b",
			setting_type = "startup",
			default_value = "normal=nil, uncommon=nil, rare=nil, epic=nil, legendary=nil, unique=nil, quantum=nil, infernal=nil, demonic=nil, godly=nil"
		},
		{
			type = "string-setting",
			name = "ic-more-qualities-localization-rework",
			order = "z-c",
			setting_type = "startup",
			default_value = "normal=nil, uncommon=nil, rare=nil, epic=nil, legendary=nil, unique=nil, mystic=nil, unbreakable=nil, infernal=nil, demonic=nil, godly=nil"
		},
	}
)

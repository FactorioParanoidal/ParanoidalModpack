data:extend{
	{
		type = "bool-setting",
		name = "enable-ed",
		setting_type = "runtime-per-user",
		order = "a",
		default_value = true
	},
	{
		type = "double-setting",
		name = "distribution-delay",
		setting_type = "runtime-per-user",
		order = "aa",
		default_value = 0.9,
		minimum_value = 0.01
	},
	{
		type = "bool-setting",
		name = "take-from-car",
		setting_type = "runtime-per-user",
		order = "ab",
		default_value = true
	},
	{
		type = "int-setting",
		name = "max-inventory-cleanup-drop-range",
		order = "ba",
		setting_type = "runtime-per-user",
		default_value = 30,
		minimum_value = 0,
		maximum_value = 100
	},
	{
		type = "string-setting",
		name = "inventory-cleanup-custom-trash",
		order = "bb",
		setting_type = "runtime-per-user",
		default_value = "iron-plate:800 copper-plate:600 steel-plate:600 stone-brick:400 artillery-shell:0",
		allow_blank = true
	},
	{
		type = "bool-setting",
		name = "cleanup-logistic-request-overflow",
		order = "bc",
		setting_type = "runtime-per-user",
		default_value = true
	},
	{
		type = "bool-setting",
		name = "drop-trash-to-chests",
		order = "bd",
		setting_type = "runtime-per-user",
		default_value = true
	},
	{
		type = "string-setting",
		name = "ignored-entities",
		order = "c",
		setting_type = "runtime-per-user",
		default_value = "",
		allow_blank = true
	},
	{
		type = "bool-setting",
		name = "early-autotrash-research",
		order = "a",
		setting_type = "startup",
		default_value = true,
	}
}
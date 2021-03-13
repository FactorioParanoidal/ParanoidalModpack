data:extend{
	{
		type = "bool-setting",
		name = "disable-distribute",
		setting_type = "runtime-global",
		order = "a",
		default_value = false
	},
	{
		type = "bool-setting",
		name = "disable-inventory-cleanup",
		setting_type = "runtime-global",
		order = "b",
		default_value = false
	},
	
	{
		type = "int-setting",
		name = "global-max-inventory-cleanup-range",
		order = "c",
		setting_type = "runtime-global",
		default_value = 1000,
		minimum_value = 0,
	},
	
	{
		type = "bool-setting",
		name = "info",
		setting_type = "runtime-per-user",
		order = "zzz",
		default_value = true,
	},

	-------------- DEPRECATED SETTINGS (moved to new settings gui) --------------
	{
		type = "bool-setting",
		name = "enable-ed",
		setting_type = "runtime-per-user",
		order = "zzz",
		default_value = true,
		hidden = true,
	},
	{
		type = "double-setting",
		name = "distribution-delay",
		setting_type = "runtime-per-user",
		order = "zzz",
		default_value = 0.9,
		minimum_value = 0.01,
		hidden = true,
	},
	{
		type = "bool-setting",
		name = "take-from-car",
		setting_type = "runtime-per-user",
		order = "zzz",
		default_value = true,
		hidden = true,
	},
	{
		type = "int-setting",
		name = "max-inventory-cleanup-drop-range",
		order = "zzz",
		setting_type = "runtime-per-user",
		default_value = 30,
		minimum_value = 0,
		maximum_value = 100,
		hidden = true,
	},
	{
		type = "string-setting",
		name = "inventory-cleanup-custom-trash",
		order = "zzz",
		setting_type = "runtime-per-user",
		default_value = "iron-plate:800 copper-plate:600 steel-plate:600 stone-brick:400 artillery-shell:0",
		allow_blank = true,
		hidden = true,
	},
	{
		type = "bool-setting",
		name = "cleanup-logistic-request-overflow",
		order = "zzz",
		setting_type = "runtime-per-user",
		default_value = true,
		hidden = true,
	},
	{
		type = "bool-setting",
		name = "drop-trash-to-chests",
		order = "zzz",
		setting_type = "runtime-per-user",
		default_value = true,
		hidden = true,
	},
	{
		type = "string-setting",
		name = "ignored-entities",
		order = "zzz",
		setting_type = "runtime-per-user",
		default_value = "",
		allow_blank = true,
		hidden = true,
	},
}
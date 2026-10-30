data:extend({
	{
		type = "int-setting",
		name = "re-default-failure-chance",
		setting_type = "runtime-global",
		minimum_value = 1,
		maximum_value = 100,
		default_value = 50,
		order = "a",
	},
	{
		type = "double-setting",
		name = "re-research-factor",
		setting_type = "runtime-global",
		minimum_value = 20,
		maximum_value = 100,
		default_value = 68.129206905796128549798817963002, -- 100*0.1^(1/6)
		order = "b",
	},
	{
		type = "double-setting",
		name = "re-launch-factor",
		setting_type = "runtime-global",
		minimum_value = 20,
		maximum_value = 100,
		default_value = 89.12509381337455299531086810783, -- 100*0.1^(1/20)
		order = "c",
	},
	{
		-- share of a successful launch that a failed launch adds to the experience of the force
		type = "double-setting",
		name = "re-failure-experience",
		setting_type = "runtime-global",
		minimum_value = 0,
		maximum_value = 100,
		default_value = 30,
		order = "d",
	},
	{
		-- every successful launch of a silo multiplies its success chance by 1 + this / 100
		type = "double-setting",
		name = "re-silo-bonus",
		setting_type = "runtime-global",
		minimum_value = 0,
		maximum_value = 20,
		default_value = 2,
		order = "e",
	},
	{
		-- percentage points of success per quality step of the silo above normal
		type = "double-setting",
		name = "re-quality-bonus",
		setting_type = "runtime-global",
		minimum_value = 0,
		maximum_value = 50,
		default_value = 10,
		order = "f",
	},
	{
		type = "bool-setting",
		name = "re-label-alt-mode",
		setting_type = "runtime-global",
		default_value = false,
		order = "g",
	},
})

-- changed: darkfrei 2021-04-05

data:extend({
	{
		type = "bool-setting",
		name = "re-show-gui-per-user",
		setting_type = "runtime-per-user",
		default_value = true,
		hidden = true
	},
	
	{
		type = "int-setting",
		name = "re-default-failure-chance",
		setting_type = "runtime-global", -- fixed in 1.1.2, darkfrei
		minimum_value = 1,
		maximum_value = 100,
		default_value = 50
	},
	{
		type = "double-setting",
		name = "re-research-factor",
		setting_type = "runtime-global",
		minimum_value = 20,
		maximum_value = 100,
		default_value = 68.129206905796128549798817963002 -- 100*0.1^(1/6)
	},
	{
		type = "double-setting",
		name = "re-launch-factor",
		setting_type = "runtime-global",
		minimum_value = 20,
		maximum_value = 100,
		default_value = 89.12509381337455299531086810783 -- 100*0.1^(1/20)
	},
	
})
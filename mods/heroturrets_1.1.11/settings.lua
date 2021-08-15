data:extend(
{
	{
		type = "int-setting",
		name = "heroturrets-setting-level-up-modifier",
		setting_type = "startup",
		default_value = 0,
		minimum_value = 0,
		maximum_value = 100,
		order = "a"
	},{
		type = "int-setting",
		name = "heroturrets-setting-level-buff-modifier",
		setting_type = "startup",
		default_value = 0,
		minimum_value = 0,
		maximum_value = 100,
		order = "b"
	},
	{
		type = "int-setting",
		name = "heroturrets-setting-ammo-turret-kill-multiplier",
		setting_type = "startup",
		default_value = 1,
		minimum_value = 1,
		maximum_value = 20,
		order = "c"
	},
	{
		type = "int-setting",
		name = "heroturrets-setting-fluid-turret-kill-multiplier",
		setting_type = "startup",
		default_value = 1,
		minimum_value = 1,
		maximum_value = 20,
		order = "d"
	},
	{
		type = "int-setting",
		name = "heroturrets-setting-electric-turret-kill-multiplier",
		setting_type = "startup",
		default_value = 1,
		minimum_value = 1,
		maximum_value = 20,
		order = "e"
	},
	{
		type = "int-setting",
		name = "heroturrets-setting-artillery-turret-kill-multiplier",
		setting_type = "startup",
		default_value = 1,
		minimum_value = 1,
		maximum_value = 20,
		order = "f"
	},
	{
		type = "bool-setting",
		name = "heroturrets-allow-ghost-rank",
		setting_type = "runtime-global",
		default_value = false,
		order = "g"
	},{
		type = "bool-setting",
		name = "heroturrets-allow-artillery-turrets",
		setting_type = "startup",
		default_value = true,
		order = "h"
	},
	--[[{
		type = "bool-setting",
		name = "heroturrets-allow-blueprint-rank",
		setting_type = "runtime-global",
		default_value = false,
		order = "d"
	},]]
	{
		type = "string-setting",
		name = "heroturrets-kill-counter",
		setting_type = "startup",
		default_value = "Fuzzy",
		allowed_values = {"Fuzzy", "Exact","Disable"},
		order = "i"
	},
	{
		type = "string-setting",
		name = "heroturrets-damage-counter",
		setting_type = "startup",
		default_value = "Off",
		allowed_values = {"Off", "On"},
		order = "j"
	},
	{
		type = "string-setting",
		name = "heroturrets-allow-damage",
		setting_type = "startup",
		default_value = "Disabled",
		allowed_values = {"Enabled", "Disabled"},
		order = "k"
	},
	{
		type = "bool-setting",
		name = "heroturrets-use-csv",
		setting_type = "startup",
		default_value = false,
		order = "l"
	},
	{
		type = "string-setting",
		name = "heroturrets-csv-names",
		setting_type = "startup",
		default_value = "Private,Corporal,Sergeant,Master sergeant,Sergeant major,Lieutenant,Captain,Major,Colonel,General",
		order = "m"
	},
})
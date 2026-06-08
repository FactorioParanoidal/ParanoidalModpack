data:extend(
{
	{
		type = "bool-setting",
		name = "heroturrets-hide-ranked-from-ghost-cursor",
		setting_type = "startup",
		default_value = true,
		order = "aa"
	},
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
		maximum_value = 100,
		order = "c"
	},
	{
		type = "int-setting",
		name = "heroturrets-setting-fluid-turret-kill-multiplier",
		setting_type = "startup",
		default_value = 1,
		minimum_value = 1,
		maximum_value = 100,
		order = "d"
	},
	{
		type = "int-setting",
		name = "heroturrets-setting-electric-turret-kill-multiplier",
		setting_type = "startup",
		default_value = 1,
		minimum_value = 1,
		maximum_value = 100,
		order = "e"
	},
	{
		type = "int-setting",
		name = "heroturrets-setting-artillery-turret-kill-multiplier",
		setting_type = "startup",
		default_value = 2,
		minimum_value = 1,
		maximum_value = 100,
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
	{
		type = "bool-setting",
		name = "heroturrets-allow-blueprint-rank",
		setting_type = "runtime-global",
		default_value = false,
		order = "d"
	},
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
		default_value = "Private,Corporal,Sergeant,Master sergeant,Sergeant major,General",
		order = "m"
	},
	{
		type = "bool-setting",
		name = "heroturrets-use-csv-kills",
		setting_type = "startup",
		default_value = false,
		order = "n"
	},
	{
		type = "string-setting",
		name = "heroturrets-csv-kill",
		setting_type = "startup",
		default_value = "150,1000,2500,5000,10000,20000",
		order = "o"
	}
	,
	{
		type = "bool-setting",
		name = "heroturrets-use-csv-damage",
		setting_type = "startup",
		default_value = false,
		order = "p"
	},
	{
		type = "string-setting",
		name = "heroturrets-csv-damage",
		setting_type = "startup",
		default_value = "10000,50000,100000,2000000,6000000,12000000",
		order = "q"
	}
	,
	{
		type = "bool-setting",
		name = "heroturrets-use-csv-buff",
		setting_type = "startup",
		default_value = false,
		order = "r"
	},
	{
		type = "string-setting",
		name = "heroturrets-csv-buff",
		setting_type = "startup",
		default_value = "10,20,30,40,50,60",
		order = "s"
	}
	,
	{
		type = "bool-setting",
		name = "heroturrets-use-csv-health-buff",
		setting_type = "startup",
		default_value = false,
		order = "t"
	},
	{
		type = "string-setting",
		name = "heroturrets-csv-health-buff",
		setting_type = "startup",
		default_value = "10,20,30,40,50,60",
		order = "u"
	},
	{
		type = "bool-setting",
		name = "heroturrets-use-csv-range-buff",
		setting_type = "startup",
		default_value = false,
		order = "v"
	},
	{
		type = "string-setting",
		name = "heroturrets-csv-range-buff",
		setting_type = "startup",
		default_value = "10,20,30,40,50,60",
		order = "w"
	},
	{
		type = "bool-setting",
		name = "heroturrets-use-csv-firerate-buff",
		setting_type = "startup",
		default_value = false,
		order = "x"
	},
	{
		type = "string-setting",
		name = "heroturrets-csv-firerate-buff",
		setting_type = "startup",
		default_value = "10,20,30,40,50,60",
		order = "y"
	},
	{
		type = "bool-setting",
		name = "heroturrets-use-csv-attack-speed-buff",
		setting_type = "startup",
		default_value = false,
		order = "z"
	},
	{
		type = "string-setting",
		name = "heroturrets-csv-attack-speed-buff",
		setting_type = "startup",
		default_value = "10,20,30,40,50,60",
		order = "za"
	}
	,
	{
		type = "bool-setting",
		name = "heroturrets-use-csv-turret-rotation-buff",
		setting_type = "startup",
		default_value = false,
		order = "zb"
	},
	{
		type = "string-setting",
		name = "heroturrets-csv-turret-rotation-buff",
		setting_type = "startup",
		default_value = "10,20,30,40,50,60",
		order = "zc"
	},
	{
		type = "bool-setting",
		name = "heroturrets-max-health-on-rank",
		setting_type = "startup",
		default_value = false,
		order = "zd"
	},
	{
		type = "string-setting",
		name = "heroturrets-setting-run-in-updates",
		setting_type = "startup",
		default_value = "False",
		allowed_values = {"True", "False"},
		order = "ze"
	},
	{
		type = "bool-setting",
		name = "heroturrets-update-ammo-ranges",
		setting_type = "startup",
		default_value = false,
		order = "zf"
	}
})

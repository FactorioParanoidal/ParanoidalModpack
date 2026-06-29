data:extend({
	{
		type = "double-setting",
		name = "Clockwork-cycle-length",
		setting_type = "runtime-global",
		default_value = 4,
		minimum_value = 0.25,
		maximum_value = 1000,
		order = "ab"
	},
	{
		type = "double-setting",
		name = "Clockwork-dusk",
		setting_type = "runtime-global",
		default_value = 0.25,
		minimum_value = 0.01,
		maximum_value = 0.99,
		order = "b"
	},
	{
		type = "double-setting",
		name = "Clockwork-evening",
		setting_type = "runtime-global",
		default_value = 0.45,
		minimum_value = 0.01,
		maximum_value = 0.99,
		order = "c"
	},
	{
		type = "double-setting",
		name = "Clockwork-morning",
		setting_type = "runtime-global",
		default_value = 0.55,
		minimum_value = 0.01,
		maximum_value = 0.99,
		order = "d"
	},
	{
		type = "double-setting",
		name = "Clockwork-dawn",
		setting_type = "runtime-global",
		default_value = 0.75,
		minimum_value = 0.01,
		maximum_value = 0.99,
		order = "ea"
	},
	{
		type = "double-setting",
		name = "Clockwork-starttime",
		setting_type = "runtime-global",
		default_value = 0.71,
		minimum_value = 0.0,
		maximum_value = 1.0,
		order = "eb"
	},
	{
		type = "int-setting",
		name = "Clockwork-darknight-percent",
		setting_type = "runtime-global",
		default_value = 0,
		minimum_value = 0,
		maximum_value = 100,
		order = "ed"
	},
	{
		type = "bool-setting",
		name = "Clockwork-multisurface",
		setting_type = "runtime-global",
		default_value = false,
		order = "fa"
	},
	{
		type = "bool-setting",
		name = "Clockwork-multisurface-ignore-always-day",
		setting_type = "runtime-global",
		default_value = true,
		order = "fb"
	},
{
		type = "bool-setting",
		name = "Clockwork-multisurface-ignore-frozen",
		setting_type = "runtime-global",
		default_value = true,
		order = "fc"
	},
	{
		type = "bool-setting",
		name = "Clockwork-permanight",
		setting_type = "runtime-global",
		default_value = false,
		order = "g"
	},
	{
		type = "int-setting",
		name = "Clockwork-permanight-grace",
		setting_type = "runtime-global",
		default_value = 0,
		minimum_value = 0,
		maximum_value = 600,
		order = "h"
	},
	--[[{
		type = "bool-setting",
		name = "Clockwork-permanight-grace-warn",
		setting_type = "runtime-global",
		default_value = true,
		order = "f"
	},]]
	{
		type = "bool-setting",
		name = "Clockwork-enable-flares",
		setting_type = "startup",
		default_value = true,
		order = "e"
	},	{
		type = "bool-setting",
		name = "Clockwork-flares-simple",
		setting_type = "startup",
		default_value = false,
		order = "ea"
	},
	{
		type = "bool-setting",
		name = "Clockwork-disable-nv",
		setting_type = "startup",
		default_value = false,
		order = "f"
	},
	{
		type = "bool-setting",
		name = "Clockwork-mod-accumulators",
		setting_type = "startup",
		default_value = true,
		order = "g"
	},
	{
		type = "double-setting",
		name = "Clockwork-mod-accumulators-capacity",
		setting_type = "startup",
		default_value = 4,
		minimum_value = 0.25,
		maximum_value = 1000,
		order = "h"
	},
})
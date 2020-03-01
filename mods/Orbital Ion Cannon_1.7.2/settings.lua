data:extend({
	-- Startup
	{
		type = "int-setting",
		name = "ion-cannon-radius",
		setting_type = "startup",
		order = "a",
		default_value = 25,
		minimum_value = 2,
		maximum_value = 500
	},
	{
		type = "int-setting",
		name = "ion-cannon-heatup-multiplier",
		setting_type = "startup",
		order = "b",
		default_value = 2,
		minimum_value = 1,
		maximum_value = 50
	},
	{
		type = "int-setting",
		name = "ion-cannon-laser-damage",
		setting_type = "startup",
		order = "c",
		default_value = 2500,
		minimum_value = 1
	},
	{
		type = "int-setting",
		name = "ion-cannon-explosion-damage",
		setting_type = "startup",
		order = "d",
		default_value = 1000,
		minimum_value = 1
	},
	{
		type = "bool-setting",
		name = "ion-cannon-flames",
		setting_type = "startup",
		order = "e",
		default_value = true
	},
	{
		type = "bool-setting",
		name = "ion-cannon-bob-updates",
		setting_type = "startup",
		order = "f",
		default_value = true
	},
	-- Runtime (global)
	{
		type = "bool-setting",
		name = "ion-cannon-auto-targeting",
		setting_type = "runtime-global",
		order = "a",
		default_value = true
	},
	{
		type = "bool-setting",
		name = "ion-cannon-target-worms",
		setting_type = "runtime-global",
		order = "b",
		default_value = true
	},
	{
		type = "bool-setting",
		name = "ion-cannon-auto-target-visible",
		setting_type = "runtime-global",
		order = "c",
		default_value = true
	},
	{
		type = "int-setting",
		name = "ion-cannon-cooldown-seconds",
		setting_type = "runtime-global",
		order = "d",
		default_value = 300,
		minimum_value = 2
	},
	{
		type = "int-setting",
		name = "ion-cannon-chart-tag-duration",
		setting_type = "runtime-global",
		order = "e",
		default_value = 720,
		minimum_value = 120
	},
	{
		type = "int-setting",
		name = "ion-cannon-min-cannons-ready",
		setting_type = "runtime-global",
		order = "f",
		default_value = 2,
		minimum_value = 0
	},
	{
		type = "bool-setting",
		name = "ion-cannon-cheat-menu",
		setting_type = "runtime-global",
		order = "g",
		default_value = false
	},
	-- Runtime (per player)
	{
		type = "bool-setting",
		name = "ion-cannon-play-voices",
		setting_type = "runtime-per-user",
		order = "a",
		default_value = true
	},
	{
		type = "string-setting",
		name = "ion-cannon-voice-style",
		setting_type = "runtime-per-user",
		order = "b",
		default_value = "CommandAndConquer",
		allowed_values = {"CommandAndConquer", "TiberianSunEVA", "TiberianSunCABAL"}
	},
	{
		type = "bool-setting",
		name = "ion-cannon-play-klaxon",
		setting_type = "runtime-per-user",
		order = "c",
		default_value = true
	},
	{
		type = "int-setting",
		name = "ion-cannon-ready-ticks",
		setting_type = "runtime-per-user",
		order = "d",
		default_value = 300,
		minimum_value = 1
	},
	{
		type = "bool-setting",
		name = "ion-cannon-custom-alerts",
		setting_type = "runtime-per-user",
		order = "e",
		default_value = true
	}
})

-- Setting names are kept from the three merged mods, so saved values and other mods' references stay valid.
data:extend({
	{
		type = "double-setting",
		name = "vehphy-tiremarks-duration",
		setting_type = "startup",
		default_value = 3600,
		maximum_value = 99999,
		minimum_value = 0.01,
		order = "a1",
	},
	{
		type = "int-setting",
		name = "VehicleSnap_amount",
		setting_type = "runtime-per-user",
		minimum_value = 4,
		default_value = 16,
	},
	{
		type = "bool-setting",
		name = "SFX_alternate_effect",
		setting_type = "runtime-global",
		default_value = true,
		order = "e",
	},
})

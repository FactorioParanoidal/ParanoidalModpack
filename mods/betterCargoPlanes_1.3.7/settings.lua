data:extend({
	{
		type = "bool-setting",
		name = "betterCargoPlanes-MilitaryEquipment",
		setting_type = "startup",
		default_value = false,
		order = "aa",
	},


	-- Inventory Size Configuration
	{
		type = "int-setting",
		name = "betterCargoPlanes-inventorySizeT1",
		setting_type = "startup",
		default_value = 120,
		order = "inva"
	},
	{
		type = "int-setting",
		name = "betterCargoPlanes-inventorySizeT2",
		setting_type = "startup",
		default_value = 180,
		order = "invb"
	},

	{
		type = "int-setting",
		name = "betterCargoPlanes-inventorySizeT3",
		setting_type = "startup",
		default_value = 240,
		order = "invc"
	},

	-- Rotation Speed Configuration
	{
		type = "double-setting",
		name = "betterCargoPlanes-rotationSpeedT1",
		setting_type = "startup",
		default_value = 0.006,
		order = "rsa"
	},
	{
		type = "double-setting",
		name = "betterCargoPlanes-rotationSpeedT2",
		setting_type = "startup",
		default_value = 0.006,
		order = "rsb"
	},

	{
		type = "double-setting",
		name = "betterCargoPlanes-rotationSpeedT3",
		setting_type = "startup",
		default_value = 0.006,
		order = "rsc"
	},

})
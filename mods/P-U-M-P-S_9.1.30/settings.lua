----------------------
----- initialise -----
---- settings.lua ----
----------------------

-- Make settings
data:extend({
	{
		type = "bool-setting",
		name = "enable-power", -- enable power requirements
		setting_type = "startup",
		default_value = true,
		order = "a-8"
	},
	{
		type = "bool-setting",
		name = "power-priority", -- set power priority
		setting_type = "startup",
		default_value = false,
		order = "b-8"
	},
	{
		type = "bool-setting",
		name = "boiler-start-water", -- spawn boiler with 10 water
		setting_type = "runtime-global",
		default_value = true,
		order = "a-8"
    }
})


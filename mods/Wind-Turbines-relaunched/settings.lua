local se_loaded = mods['space-exploration']

data:extend{
	{
		type = 'int-setting',
		name = 'texugo-wind-power',
		setting_type = 'startup',
		default_value = 1,
		maximum_value = 20,
		minimum_value = 1,
		order = 'a',
	},
	{
		type = 'bool-setting',
		name = 'texugo-wind-turbine4',
		setting_type = 'startup',
		default_value = true,
		order = 'b',
	},
	{
		type = "string-setting",
		name = "texugo-wind-mode",
		order = "c",
		setting_type = "startup",
		-- fix for #36
		-- mod SE lacks nessecary informations (pressure on planets) due to missing prototypes with surface_properties
		-- so change default if mod is loaded
		default_value = se_loaded and "SURFACE" or "SURFACE+PRESSURE",
		allowed_values = {
			"CLASSICAL",
			"SURFACE",
			-- see above - remove this option if mod SE is loaded
			not se_loaded and "SURFACE+PRESSURE" or nil,
		}
	},
	{
		type = 'bool-setting',
		name = 'texugo-wind-extended-collision-area',
		setting_type = 'startup',
		default_value = false,
		order = 'd',
	},
	{
		type = 'bool-setting',
		name = 'texugo-wind-expensive-recipes',
		setting_type = 'startup',
		default_value = false,
		order = 'e',
	},
}
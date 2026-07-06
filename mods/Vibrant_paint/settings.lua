-- https://wiki.factorio.com/Tutorial:Mod_settings#The_order_property
data:extend(
	{
		{
			type = "bool-setting",
			name = "vibPaint-paintActives",
			localised_name = "Force painting of turrets",
			setting_type = "startup",
			default_value = false,
			localised_description = "Force painting of moving turret components;\nmay cause flickering of paint and oversaturation"
		},
	}
)

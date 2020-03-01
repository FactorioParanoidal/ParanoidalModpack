   data:extend(
{
	{
		type = "fluid",
		name = "liquid-air",
		default_temperature = 100,
		heat_capacity = "1KJ",
		base_color = {r=0, g=0, b=0},
		flow_color = {r=0.5, g=1.0, b=1.0},
		max_temperature = 100,
		icon = "__Bio_Industries__/graphics/icons/liquid-air.png",
		icon_size = 32,
		pressure_to_speed_ratio = 0.4,
		flow_to_energy_ratio = 0.59,
		order = "a[fluid]-b[liquid-air]"
	},

	{
		type = "fluid",
		name = "nitrogen",
		default_temperature = 25,
		heat_capacity = "1KJ",
		base_color = {r=0.0, g=0.0, b=1.0},
		flow_color = {r=0.5, g=0.5, b=0.5},
		max_temperature = 100,
		icon = "__Bio_Industries__/graphics/icons/nitrogen.png",
		icon_size = 32,
		pressure_to_speed_ratio = 0.4,
		flow_to_energy_ratio = 0.59,
		order = "a[fluid]-b[nitrogen]"
	},

	{
		type = "fluid",
		name = "bi-biomass",
		default_temperature = 25,
		heat_capacity = "1KJ",
		base_color = {r=0, g=0, b=0},
		flow_color = {r=0.1, g=1.0, b=0.0},
		max_temperature = 100,
		icon = "__Bio_Industries__/graphics/icons/biomass.png",
		icon_size = 32,
		pressure_to_speed_ratio = 0.4,
		flow_to_energy_ratio = 0.59,
		order = "a[fluid]-b[biomass]"
	}

}
)
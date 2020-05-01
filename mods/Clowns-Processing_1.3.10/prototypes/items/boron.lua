data:extend(
{
	{
		type = "fluid",
		name = "liquid-boric-acid",
		icons = angelsmods.functions.create_liquid_fluid_icon({ "__Clowns-Processing__/graphics/icons/boric-acid.png", 512 }, {{r=203/255,g=146/255,b=146/255},{ 214, 012, 012 },{ 242, 242, 242 }}),--"__Clowns-Processing__/graphics/icons/liquid-boric-acid.png",
		--icon_size = 32,
		default_temperature = 25,
		heat_capacity = "0.1KJ",
		base_color = {r = 1, g = 0.6, b = 0.6},
		flow_color = {r = 1, g = 0.6, b = 0.6},
		max_temperature = 100,
		pressure_to_speed_ratio = 0.4,
		flow_to_energy_ratio = 0.59,
	},
}
)

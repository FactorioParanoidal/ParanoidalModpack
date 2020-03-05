data:extend(
{
	{
		type = "item",
		name = "magnesium-ore",
		icon = "__Clowns-Processing__/graphics/icons/magnesium-ore.png",
		icon_size = 32,
		subgroup = "clowns-magnesium",
		order = "a",
		stack_size = 200,
	},
	{
		type = "item",
		name = "processed-magnesium",
		icon = "__Clowns-Processing__/graphics/icons/processed-magnesium.png",
		icon_size = 32,
		subgroup = "clowns-magnesium",
		order = "b",
		stack_size = 200,
	},
	{
		type = "item",
		name = "pellet-magnesium",
		icon = "__Clowns-Processing__/graphics/icons/pellet-magnesium.png",
		icon_size = 32,
		subgroup = "clowns-magnesium",
		order = "c",
		stack_size = 200
	},
	{
		type = "item",
		name = "ingot-magnesium",
		icon = "__Clowns-Processing__/graphics/icons/ingot-magnesium.png",
		icon_size = 32,
		subgroup = "clowns-magnesium",
		order = "c",
		stack_size = 200
	},
	{
		type = "fluid",
		name = "liquid-molten-magnesium",
		icon = "__Clowns-Processing__/graphics/icons/molten-magnesium.png",
		icon_size = 32,
		default_temperature = 100,
		heat_capacity = "0KJ",
		base_color = {r = 242/255, g = 212/255, b = 194/255},
		flow_color = {r = 242/255, g = 212/255, b = 194/255},
		max_temperature = 100,
		pressure_to_speed_ratio = 0.4,
		flow_to_energy_ratio = 0.59,
		auto_barrel = false
	},
	{
		type = "item",
		name = "clowns-plate-magnesium",
		icon = "__Clowns-Processing__/graphics/icons/plate-magnesium.png",
		icon_size = 32,
		subgroup = "clowns-magnesium-casting",
		order = "f",
		stack_size = 200
	},
}
)
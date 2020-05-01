data:extend(
{
	{
		type = "item",
		name = "solid-white-phosphorus",
		icon = "__Clowns-Processing__/graphics/icons/solid-white-phosphorus.png",
		icon_size = 32,
		subgroup = "clowns-phosphorus",
		order = "b",
		stack_size = 200,
	},
	{
		type = "item",
		name = "phosphorus-ore",
		icon = "__Clowns-Processing__/graphics/icons/phosphorus-ore.png",
		icon_size = 32,
		subgroup = "clowns-phosphorus",
		order = "a",
		stack_size = 200,
	},
	--[[{
	type = "fluid",
	name = "gas-phosphorus",
	icon = "__Clowns-Extended-Minerals__/graphics/icons/liquid-phosphoric-acid.png",
	icon_size = 32,
	default_temperature = 25,
	heat_capacity = "0.1KJ",
	base_color = {r = 1, g = 0.35, b = 0},
	flow_color = {r = 1, g = 0.35, b = 0},
	max_temperature = 100,
	pressure_to_speed_ratio = 0.4,
	flow_to_energy_ratio = 0.59,
},]]
	{
		type = "fluid",
		name = "liquid-phosphoric-acid",
		icons = angelsmods.functions.create_liquid_fluid_icon({ "__Clowns-Processing__/graphics/icons/phosphoric-acid.png", 512 }, {{ r = 244, g = 125, b = 001 },{ 242, 242, 242 },{ 214, 012, 012 }}),--"__Clowns-Processing__/graphics/icons/liquid-phosphoric-acid.png",
		--icon_size = 32,
		default_temperature = 25,
		heat_capacity = "0.1KJ",
		base_color = {r = 0.957, g = 0.49, b = 0},
		flow_color = {r = 0.957, g = 0.49, b = 0},
		max_temperature = 100,
		pressure_to_speed_ratio = 0.4,
		flow_to_energy_ratio = 0.59,
	},
}
)

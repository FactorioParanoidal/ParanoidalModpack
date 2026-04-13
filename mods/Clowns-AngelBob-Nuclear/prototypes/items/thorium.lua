data:extend(
{
	-- thorium ore processing items
	{
		type = "item",
		name = "clowns-solid-thorium-salt", --fluoride (if angels petrochem, chloride if not)
		icons = {{icon="__Clowns-AngelBob-Nuclear__/graphics/icons/ore-5.png",tint={r = 0.8, g = 0.2, b = 0.2, a = 0.6},icon_size=32}},
		subgroup = "clowns-thorium",
		order = "a-b",
		stack_size = 50
	},
	{
		type = "fluid",
		name = "clowns-liquid-thorium-solution",
		icons = angelsmods.functions.create_viscous_liquid_fluid_icon(nil, { {r = 0.8, g = 0.2, b = 0.2, a = 0.6}, nil, {r = 0.8, g = 0.2, b = 0.2, a = 0.6} }),
		default_temperature = 550,
		heat_capacity = "0.1kJ",
		base_color = {r = 0.92, g = 0.72, b = 0.09},
		flow_color = {r = 0, g = 1, b = 0.5},
		max_temperature = 1200,
		pressure_to_speed_ratio = 0.4,
		flow_to_energy_ratio = 0.59,
		subgroup = "clowns-thorium",
		order = "a-a",
	},
	{
		type = "item-subgroup",
		name = "clowns-thorium",
		group = "angels-smelting",
		order = "pb",
	},
}
)
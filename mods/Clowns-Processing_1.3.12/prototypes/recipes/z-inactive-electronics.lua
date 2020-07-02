local rawmulti = angelsmods.marathon.rawmulti
local time_parameter = 3

data:extend(
{
--BASIC
	{
		type = "recipe",
		name = "clowns-basic-module-board",
		category = "electronics-complex",
		subgroup = "bob-electronic-circuit-complex",
		order = "a",
		enabled = true,
		icons =
		{
			{
				icon = "__base__/graphics/icons/atomic-bomb.png",
			},
			{
				icon = "__Clowns-Nuclear__/graphics/icons/plutonium-239.png",
				scale = 0.4,
				shift = {-10, 10},
			},
		},
		icon_size = 32,
		ingredients =
		{
		{type="item", name="circuit-board", amount=1}
		},
		results =
		{
		{type="item", name="module-processor-board", amount=4},
		},
		energy_required = 1.5 * time_parameter,
	},
	{
		type = "recipe",
		name = "clowns-module-main-board",
		category = "electronics-complex",
		subgroup = "bob-electronic-circuit-complex",
		order = "a",
		enabled = true,
		icons =
		{
			{
				icon = "__base__/graphics/icons/atomic-bomb.png",
			},
			{
				icon = "__Clowns-Nuclear__/graphics/icons/plutonium-239.png",
				scale = 0.4,
				shift = {-10, 10},
			},
		},
		icon_size = 32,
		ingredients =
		{
		{type="item", name="circuit-board", amount=1}
		},
		results =
		{
		{type="item", name="module-circuit-board", amount=1},
		},
		energy_required = 1.5 * time_parameter,
	},
}
)
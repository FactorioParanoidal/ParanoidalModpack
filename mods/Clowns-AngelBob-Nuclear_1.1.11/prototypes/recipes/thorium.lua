data:extend(
{
	{
		type = "recipe",
		name = "thorium-processing",
		energy_required = 10,
		enabled = false,
		category = "centrifuging",
		ingredients = {{"thorium-ore", 10}},
		icon = "__Clowns-Nuclear__/graphics/icons/thorium-processing.png",
		icon_size = 32,
		crafting_machine_tint =
		{
			primary = {r = 1, g = 1, b = 0}, -- thorium
			secondary = {r = 1, g = 1, b = 0}, -- thorium
			tertiary = {r = 1, g = 1, b = 0}, -- thorium
		},
		subgroup = "clowns-nuclear-cells",
		order = "z",
		results =
		{
			{type="item", name="thorium-232", amount=1},
		}
	},
	{
		type = "recipe",
		name = "thorium-mixed-oxide",
		energy_required = 50,
		enabled = false,
		ingredients =
		{
			{type="item", name="iron-plate", amount=2},
			{type="item", name="plutonium-239", amount=2},
			{type="item", name="thorium-232", amount=2}
		},
		icon = "__Clowns-Nuclear__/graphics/icons/thorium-nuclear-fuel-mixed-oxide.png",
		icon_size = 32,
		subgroup = "clowns-nuclear-cells",
		order = "d-b",
		results =
		{
			{
				name = "thorium-fuel-cell",
				amount = 2
			},
		},
		allow_decomposition = false
	},
	{
		type = "recipe",
		name = "thorium-fuel-cell",
		energy_required = 10,
		enabled = false,
		ingredients =
		{
			{"iron-plate", 10},
			{"55%-uranium", 1},
			{"thorium-232", 19},
		},
		result = "thorium-fuel-cell",
		result_count = 10,
	},
}
)

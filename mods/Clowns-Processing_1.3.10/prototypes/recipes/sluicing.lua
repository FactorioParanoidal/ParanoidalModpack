data:extend(
{
	{
		type = "recipe",
		name = "sand-sluicing",
		category = "sluicing",
		enabled = false,
		icon = "__angelsrefining__/graphics/icons/solid-sand.png",
		icon_size = 32,
		ingredients = 
		{
			{type="item", name="solid-sand", amount=10},
			{type="fluid", name="water", amount=10}
		},
		results =
		{
			{type="fluid", name="water-thin-mud", amount=10},
			{type="item", name="iron-ore", amount=1, probability = 0.2,},
			{type="item", name="copper-ore", amount=1, probability = 0.1,},
			{type="item", name="crystal-dust", amount=1, probability = 0.1,},
			{type="item", name="gold-ore", amount=1, probability = 0.05,},
			{type="item", name="chrome-ore", amount=1, probability = 0.01,},
			{type="item", name="platinum-ore", amount=1, probability = 0.01,}
		},
		energy_required = 5,
		subgroup = "water-washing",
		order = "k-a",
	},
}
)
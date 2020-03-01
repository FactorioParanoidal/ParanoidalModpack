data:extend(
{
	--[[{
		type = "recipe",
		name = "phospohoric-waste-water-purification",
		category = "water-treatment",
		subgroup = "water-cleaning",
		energy_required = 1,
		enabled = "false",
		ingredients ={
		{type="fluid", name="water-yellow-waste", amount=100}
		},
		results=
		{
		  {type="fluid", name="water-mineralized", amount=20},
		  {type="fluid", name="water-purified", amount=70},
		  {type="item", name="sulfur", amount=1},
		},
		icon = "__angelsrefining__/graphics/icons/water-yellow-waste-purification.png",
		icon_size = 32,
		order = "h",
	},]]
	{
		type = "recipe",
		name = "radioactive-waste-water-purification",
		category = "water-treatment",
		subgroup = "water-cleaning",
		energy_required = 10,
		enabled = false,
		ingredients =
		{
			{type="fluid", name="water-radioactive-waste", amount=100}
		},
		results=
		{
			{type="fluid", name="water-red-waste", amount=100},
			{type="item", name="polonium-210", amount=1},
		},
		icon = "__Clowns-AngelBob-Nuclear__/graphics/icons/water-radioactive-waste-purification.png",
		icon_size = 32,
		order = "k",
	},
}
)
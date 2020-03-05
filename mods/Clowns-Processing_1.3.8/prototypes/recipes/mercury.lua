data:extend(
{
	--WATER TREATMENT
	{
		type = "recipe",
		name = "thermal-filtering-mercury",
		category = "water-treatment",
		subgroup = "water-treatment",
		enabled = false,
		energy_required = 1,
		ingredients =
		{
		  {type="fluid", name="thermal-water", amount=100}
		},
		results=
		{
		  {type="fluid", name="liquid-mercury", amount=40},
		  {type="fluid", name="water-purified", amount=60},
		},
		icons =
		{
			{
				icon = "__Clowns-Processing__/graphics/icons/water-thermal.png",
			},
			{
				icon = "__Clowns-Processing__/graphics/icons/liquid-mercury.png",
				scale = 0.35,
				shift = {10, 10},
			},
		},
		icon_size = 32,
		order = "h"
	},
	--MILITARY
	{
		type = "recipe",
		name = "dimethylmercury-synthesis",
		category = "chemistry",
		subgroup = "petrochem-chlorine",
		enabled = false,
		energy_required = 10,
		ingredients =
		{
			{type="fluid", name="liquid-mercury", amount=10},
			{type="fluid", name="gas-chlor-methane", amount=20},
			{type="item", name="solid-sodium", amount=2},
		},
		results=
		{
			{type="fluid", name="liquid-dimethylmercury", amount=10},
			{type="item", name="solid-salt", amount=2},
		},
		icons =
		{
			{
				icon = "__Clowns-Processing__/graphics/icons/liquid-dimethylmercury.png",
			},
		},
		icon_size = 32,
		order = "z"
	},
}
)
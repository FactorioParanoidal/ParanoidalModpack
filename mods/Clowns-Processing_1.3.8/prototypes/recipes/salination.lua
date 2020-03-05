local intermediatemulti = angelsmods.marathon.intermediatemulti

data:extend(
{
--SALINATION
	{
		type = "recipe",
		name = "intermediate-salination",
		category = "salination-plant",
		subgroup = "water-salination",
		energy_required = 5,
		enabled = false,
		ingredients =
		{
			{type="fluid", name="water-saline", amount=1000}
		},
		results=
		{
			{type="item", name="solid-salt", amount=10},
			{type="item", name="magnesium-ore", amount=5},
		},
		icons =
		{
			{
				icon = "__angelsrefining__/graphics/icons/water-saline.png",
			},
			{
				icon = "__angelsrefining__/graphics/icons/solid-salt.png",
				scale = 0.5,
				shift = {-8, 8},
			},
			{
				icon = "__Clowns-Processing__/graphics/icons/magnesium-ore.png",
				scale = 0.5,
				shift = {8, 8},
			},
		},
		icon_size = 32,
		order = "f",
	},
	{
		type = "recipe",
		name = "advanced-salination",
		category = "salination-plant",
		subgroup = "water-salination",
		energy_required = 5,
		enabled = false,
		ingredients =
		{
			{type="fluid", name="water-saline", amount=1000}
		},
		results=
		{
			{type="item", name="magnesium-ore", amount=10},
		},
		main_product= "",
		icons =
		{
			{
				icon = "__angelsrefining__/graphics/icons/water-saline.png",
			},
			{
				icon = "__Clowns-Processing__/graphics/icons/magnesium-ore.png",
				scale = 0.5,
				shift = {-8, 8},
			},
		},
		icon_size = 32,
		order = "g",
	},
}
)
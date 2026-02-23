local energy = 10

data:extend(
{
	{
		type = "recipe",
		name = "depleted-uranium-reprocessing",
		energy_required = energy/2,
		enabled = false,
		category = "centrifuging",
		ingredients =
		{
			{type="item", name="uranium-238", amount=5},
		},
		icon = "__Clowns-Nuclear__/graphics/icons/0.png",
		icon_size = 64,
		icon_mipmaps = 4,
		subgroup = "clowns-uranium-centrifuging",
		order = "a[uranium]-a",
		results=
		{
			{type="item", name="uranium-ore", amount=10},
		},
		allow_decomposition = false
	},
	{
		type = "recipe",
		name = "clowns-centrifuging-80pc",
		energy_required = energy,
		enabled = false,
		category = "centrifuging",
		ingredients = {{type="item",name="75pc-uranium", amount=5}},
		icon = "__Clowns-Nuclear__/graphics/icons/8.png",
		icon_size = 64,
		icon_mipmaps = 4,
		subgroup = "clowns-uranium-centrifuging",
		order = "a[uranium]-j",
		results=
		{
			{type="item", name="uranium-235", amount=2},
			{type="item", name="75pc-uranium", amount=1},
			{type="item", name="uranium-238", amount=2}
		},
		allow_decomposition = false
	},
	{
		type = "recipe",
		name = "clowns-centrifuging-75pc",
		energy_required = energy,
		enabled = false,
		category = "centrifuging",
		ingredients = {{type="item",name="70pc-uranium", amount=5}},
		icon = "__Clowns-Nuclear__/graphics/icons/7.png",
		icon_size = 64,
		icon_mipmaps = 4,
		subgroup = "clowns-uranium-centrifuging",
		order = "a[uranium]-i",
		results=
		{
			{type="item", name="75pc-uranium", amount=2},
			{type="item", name="70pc-uranium", amount=1},
			{type="item", name="uranium-238", amount=2}
		},
		allow_decomposition = false
	},
	{
		type = "recipe",
		name = "clowns-centrifuging-70pc",
		energy_required = energy,
		enabled = false,
		category = "centrifuging",
		ingredients = {{type="item",name="65pc-uranium", amount=5}},
		icon = "__Clowns-Nuclear__/graphics/icons/6.png",
		icon_size = 64,
		icon_mipmaps = 4,
		subgroup = "clowns-uranium-centrifuging",
		order = "a[uranium]-h",
		results=
		{
			{type="item", name="70pc-uranium", amount=2},
			{type="item", name="65pc-uranium", amount=1},
			{type="item", name="uranium-238", amount=2}
		},
		allow_decomposition = false
	},
	{
		type = "recipe",
		name = "clowns-centrifuging-65pc",
		energy_required = energy,
		enabled = false,
		category = "centrifuging",
		ingredients = {{type="item",name="55pc-uranium", amount=5}},
		icon = "__Clowns-Nuclear__/graphics/icons/5.png",
		icon_size = 64,
		icon_mipmaps = 4,
		subgroup = "clowns-uranium-centrifuging",
		order = "a[uranium]-g",
		results=
		{
			{type="item", name="65pc-uranium", amount=2},
			{type="item", name="55pc-uranium", amount=1},
			{type="item", name="uranium-238", amount=2}
		},
		allow_decomposition = false
	},
	{
		type = "recipe",
		name = "clowns-centrifuging-55pc",
		energy_required = energy,
		enabled = false,
		category = "centrifuging",
		ingredients = {{type="item",name="45pc-uranium", amount=5}},
		icon = "__Clowns-Nuclear__/graphics/icons/4.png",
		icon_size = 64,
		icon_mipmaps = 4,
		subgroup = "clowns-uranium-centrifuging",
		order = "a[uranium]-f",
		results=
		{
			{type="item", name="55pc-uranium", amount=2},
			{type="item", name="45pc-uranium", amount=1},
			{type="item", name="uranium-238", amount=2}
		},
		allow_decomposition = false
	},
	{
		type = "recipe",
		name = "clowns-centrifuging-45pc",
		energy_required = energy,
		enabled = false,
		category = "centrifuging",
		ingredients = {{type="item",name="35pc-uranium", amount=5}},
		icon = "__Clowns-Nuclear__/graphics/icons/3.png",
		icon_size = 64,
		icon_mipmaps = 4,
		subgroup = "clowns-uranium-centrifuging",
		order = "a[uranium]-e",
		results=
		{
			{type="item", name="45pc-uranium", amount=2},
			{type="item", name="35pc-uranium", amount=1},
			{type="item", name="uranium-238", amount=2}
		},
		allow_decomposition = false
	},
	{
		type = "recipe",
		name = "clowns-centrifuging-35pc",
		energy_required = energy,
		enabled = false,
		category = "centrifuging",
		ingredients = {{type="item",name="20pc-uranium", amount=5}},
		icon = "__Clowns-Nuclear__/graphics/icons/2.png",
		icon_size = 64,
		icon_mipmaps = 4,
		subgroup = "clowns-uranium-centrifuging",
		order = "a[uranium]-d",
		results=
		{
			{type="item", name="35pc-uranium", amount=2},
			{type="item", name="20pc-uranium", amount=1},
			{type="item", name="uranium-238", amount=2}
		},
		allow_decomposition = false
	},
	--c is for AB hexafluoride variant
	{
		type = "recipe",
		name = "clowns-centrifuging-20pc-ore",
		energy_required = energy,
		enabled = false,
		category = "centrifuging",
		ingredients = {{type="item", name="uranium-ore", amount=60}},
		icons =
		{
			{
				icon = "__Clowns-Nuclear__/graphics/icons/1.png",
				icon_size = 64,
				icon_mipmaps = 4,
				shift = {0, 0},
			},
			{
				icon = "__base__/graphics/icons/uranium-ore.png",
				icon_size=64,
				icon_mipmaps = 4,
				scale = 0.3,
				shift = {-10, -10},
			},

		},
		subgroup = "clowns-uranium-centrifuging",
		order = "a[uranium]-b",
		results=
		{
			{type="item", name="20pc-uranium", amount=2},
			{type="item", name="uranium-238", amount=4}
		},
		allow_decomposition = false
	},

}
)

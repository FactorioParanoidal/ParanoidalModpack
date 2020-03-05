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
		icon_size = 32,
		subgroup = "clowns-uranium-centrifuging",
		order = "a",
		main_product = "",
		results=
		{
			{type="item", name="uranium-ore", amount=10},
		},
		allow_decomposition = false
	},
	{
		type = "recipe",
		name = "clowns-centrifuging-80%",
		energy_required = energy,
		enabled = false,
		category = "centrifuging",
		ingredients = {{"75%-uranium", 5}},
		icon = "__Clowns-Nuclear__/graphics/icons/8.png",
		icon_size = 32,
		subgroup = "clowns-uranium-centrifuging",
		order = "j",
		main_product = "",
		results=
		{
			{type="item", name="uranium-235", amount=2},
			{type="item", name="75%-uranium", amount=1},
			{type="item", name="uranium-238", amount=2}
		},
		allow_decomposition = false
	},
	{
		type = "recipe",
		name = "clowns-centrifuging-75%",
		energy_required = energy,
		enabled = false,
		category = "centrifuging",
		ingredients = {{"70%-uranium", 5}},
		icon = "__Clowns-Nuclear__/graphics/icons/7.png",
		icon_size = 32,
		subgroup = "clowns-uranium-centrifuging",
		order = "i",
		main_product = "",
		results=
		{
			{type="item", name="75%-uranium", amount=2},
			{type="item", name="70%-uranium", amount=1},
			{type="item", name="uranium-238", amount=2}
		},
		allow_decomposition = false
	},
	{
		type = "recipe",
		name = "clowns-centrifuging-70%",
		energy_required = energy,
		enabled = false,
		category = "centrifuging",
		ingredients = {{"65%-uranium", 5}},
		icon = "__Clowns-Nuclear__/graphics/icons/6.png",
		icon_size = 32,
		subgroup = "clowns-uranium-centrifuging",
		order = "h",
		main_product = "",
		results=
		{
			{type="item", name="70%-uranium", amount=2},
			{type="item", name="65%-uranium", amount=1},
			{type="item", name="uranium-238", amount=2}
		},
		allow_decomposition = false
	},
	{
		type = "recipe",
		name = "clowns-centrifuging-65%",
		energy_required = energy,
		enabled = false,
		category = "centrifuging",
		ingredients = {{"55%-uranium", 5}},
		icon = "__Clowns-Nuclear__/graphics/icons/5.png",
		icon_size = 32,
		subgroup = "clowns-uranium-centrifuging",
		order = "g",
		main_product = "",
		results=
		{
			{type="item", name="65%-uranium", amount=2},
			{type="item", name="55%-uranium", amount=1},
			{type="item", name="uranium-238", amount=2}
		},
		allow_decomposition = false
	},
	{
		type = "recipe",
		name = "clowns-centrifuging-55%",
		energy_required = energy,
		enabled = false,
		category = "centrifuging",
		ingredients = {{"45%-uranium", 5}},
		icon = "__Clowns-Nuclear__/graphics/icons/4.png",
		icon_size = 32,
		subgroup = "clowns-uranium-centrifuging",
		order = "f",
		main_product = "",
		results=
		{
			{type="item", name="55%-uranium", amount=2},
			{type="item", name="45%-uranium", amount=1},
			{type="item", name="uranium-238", amount=2}
		},
		allow_decomposition = false
	},
	{
		type = "recipe",
		name = "clowns-centrifuging-45%",
		energy_required = energy,
		enabled = false,
		category = "centrifuging",
		ingredients = {{"35%-uranium", 5}},
		icon = "__Clowns-Nuclear__/graphics/icons/3.png",
		icon_size = 32,
		subgroup = "clowns-uranium-centrifuging",
		order = "e",
		main_product = "",
		results=
		{
			{type="item", name="45%-uranium", amount=2},
			{type="item", name="35%-uranium", amount=1},
			{type="item", name="uranium-238", amount=2}
		},
		allow_decomposition = false
	},
	{
		type = "recipe",
		name = "clowns-centrifuging-35%",
		energy_required = energy,
		enabled = false,
		category = "centrifuging",
		ingredients = {{"20%-uranium", 5}},
		icon = "__Clowns-Nuclear__/graphics/icons/2.png",
		icon_size = 32,
		subgroup = "clowns-uranium-centrifuging",
		order = "d",
		main_product = "",
		results=
		{
			{type="item", name="35%-uranium", amount=2},
			{type="item", name="20%-uranium", amount=1},
			{type="item", name="uranium-238", amount=2}
		},
		allow_decomposition = false
	},
	{
		type = "recipe",
		name = "clowns-centrifuging-20%-ore",
		energy_required = energy,
		enabled = false,
		category = "centrifuging",
		ingredients = {{"uranium-ore", 60}},
		icons =
		{
			{
				icon = "__Clowns-Nuclear__/graphics/icons/1.png",
				scale = 1,
				shift = {0, 0},
			},
			{
				icon = "__base__/graphics/icons/uranium-ore.png",
				scale = 0.5,
				shift = {-8, -8},
			},

		},
		icon_size = 32,
		subgroup = "clowns-uranium-centrifuging",
		order = "b",
		main_product = "",
		results=
		{
			{type="item", name="20%-uranium", amount=2},
			{type="item", name="uranium-238", amount=4}
		},
		allow_decomposition = false
	},

}
)

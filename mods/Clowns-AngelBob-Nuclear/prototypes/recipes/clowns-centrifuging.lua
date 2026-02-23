local energy = 10

data:extend(
{
	{
		type = "recipe",
		name = "clowns-centrifuging-20pc-hexafluoride",
		energy_required = energy,
		enabled = false,
		category = "centrifuging",
		ingredients = {
			{type = "item", name = "clowns-solid-uranium-hexafluoride", amount = 48}
		},--decent saving yo
		icons =
		{
			{
				icon = "__Clowns-Nuclear__/graphics/icons/1.png",
				icon_size = 64,
				icon_mipmaps = 4,
				scale = 1,
				shift = {0, 0},
			},
			{
				icon = "__Clowns-Processing__/graphics/icons/solid-uranium-hexafluoride.png",
				icon_size=32,
				scale = 1,
				shift = {-16, -16},
			},
		},
		crafting_machine_tint =
		{
			primary = {r = 0, g = 1, b = 0},
			secondary = {r = 0, g = 1, b = 0},
			tertiary = {r = 0, g = 1, b = 0},
		},
		subgroup = "clowns-uranium-centrifuging",
		order = "a[uranium]-c",
		main_product = "",
		results=
		{
			{type="item", name="20pc-uranium", amount=2},
			{type="item", name="uranium-238", amount=3},
			{type = "item", name = "angels-uranium-234", amount = 1, probability = 0.000055}
		},
		allow_decomposition = false
	},
}
)

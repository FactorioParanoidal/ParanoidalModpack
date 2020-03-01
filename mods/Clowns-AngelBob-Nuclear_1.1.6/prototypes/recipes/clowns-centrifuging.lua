local energy = 10

data:extend(
{
	{
		type = "recipe",
		name = "clowns-centrifuging-20%-hexafluoride",
		energy_required = energy,
		enabled = false,
		category = "centrifuging",
		ingredients = {{"solid-uranium-hexafluoride", 48}},--decent saving yo
		icons =
		{
			{
				icon = "__Clowns-Nuclear__/graphics/icons/1.png",
				scale = 1,
				shift = {0, 0},
			},
			{
				icon = "__Clowns-Processing__/graphics/icons/solid-uranium-hexafluoride.png",
				scale = 0.5,
				shift = {-8, -8},
			},
		},
		icon_size = 32,
		crafting_machine_tint =
		{
			primary = {r = 0, g = 1, b = 0},
			secondary = {r = 0, g = 1, b = 0},
			tertiary = {r = 0, g = 1, b = 0},
		},
		subgroup = "clowns-uranium-centrifuging",
		order = "c",
		main_product = "",
		results=
		{
			{type="item", name="20%-uranium", amount=2},
			{type="item", name="uranium-238", amount=3}
		},
		allow_decomposition = false
	},
}
)

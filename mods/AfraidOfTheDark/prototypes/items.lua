data:extend(
{
	----------------------------------------------------------------------------------
	{
		type = "item",
		name = "balloon-light",
		icon = "__AfraidOfTheDark__/graphics/balloon-light-icon.png",
		icon_size = 32,
		-- flags = {"goes-to-quickbar"},
		subgroup = "energy",
		order = "c[light]-s[balloon-light]",
		place_result = "balloon-light",
		stack_size = 50
	},
	----------------------------------------------------------------------------------
	{
		type = "item",
		name = "short-balloon-light",
		icon = "__AfraidOfTheDark__/graphics/short-balloon-light-icon.png",
		icon_size = 32,
		-- flags = {"goes-to-quickbar"},
		subgroup = "energy",
		order = "c[light]-s[balloon-light]",
		place_result = "short-balloon-light",
		stack_size = 50
	},
	----------------------------------------------------------------------------------
	{
		type = "item",
		name = "perfect-night-glasses",
		icon = "__AfraidOfTheDark__/graphics/perfect-night-glasses-icon.png",
		icon_size = 32,
		place_as_equipment_result = "perfect-night-glasses",
		-- flags = { "goes-to-quickbar" },
		subgroup = "equipment",
		order = "f[night-vision]-p[perfect-night-glasses]",
		stack_size = 20,
	},

}
)


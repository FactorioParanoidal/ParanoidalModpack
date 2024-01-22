data:extend(
{
	{
		type = "recipe",
		name = "mixed-oxide",
		energy_required = 50,
		enabled = false,
		ingredients =
		{
			{"iron-plate", 2},
			{"plutonium-239", 2},
			{"uranium-238", 2},
		},
		icon = "__Clowns-Nuclear__/graphics/icons/nuclear-fuel-mixed-oxide.png",
		icon_size = 32,
		subgroup = "clowns-nuclear-cells",
		order = "d-a",
		results =
		{
			{
				name = "uranium-fuel-cell",
				amount = 2
			},
		},
		allow_decomposition = false
	},
	
	
}
)
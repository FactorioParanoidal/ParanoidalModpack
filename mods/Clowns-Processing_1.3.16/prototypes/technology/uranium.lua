data:extend(
{
	{
		type = "technology",
		name = "advanced-uranium-processing-1",
		icon_size = 128,
		icon = "__Clowns-Processing__/graphics/technology/advanced-uranium-processing.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "advanced-uranium-processing"
			},
			{
				type = "unlock-recipe",
				recipe = "solid-uranium-hexafluoride"
			},
			{
				type = "unlock-recipe",
				recipe = "solid-uranium-tetrafluoride"
			},
			{
				type = "unlock-recipe",
				recipe = "solid-uranium-oxide-1"
			},
		},
		prerequisites = {"nuclear-power", "angels-advanced-chemistry-4"},
		unit =
		{
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"utility-science-pack", 1}
			},
			time = 30,
			count = 100
		},
		order = "e"
	},
	
	{
		type = "technology",
		name = "advanced-uranium-processing-2",
		icon_size = 128,
		icon = "__Clowns-Processing__/graphics/technology/advanced-uranium-processing.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "solid-uranium-oxide-2"
			},
			{
				type = "unlock-recipe",
				recipe = "solid-ammonium-diuranate"
			},
			{
				type = "unlock-recipe",
				recipe = "solid-uranyl-nitrate"
			},
		},
		prerequisites = {"advanced-uranium-processing-1"},
		unit =
		{
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"utility-science-pack", 1}
			},
			time = 30,
			count = 100
		},
		order = "e"
	},
}
)
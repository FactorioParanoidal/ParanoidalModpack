data:extend(
{
	-- Alloy Mixer
	{
		type = "technology",
		name = "remelting-alloy-mixer-1",
		icon = "__angelssmelting__/graphics/technology/induction-furnace-tech.png",
		icon_size = 128,
		prerequisites =
		{
			"angels-metallurgy-1",
		},
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "alloy-mixer"
			},
		},
		unit =
		{
			count = 50,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
			},
			time = 30
		},
		order = "c-a"
	},
	{
		type = "technology",
		name = "remelting-alloy-mixer-2",
		icon = "__angelssmelting__/graphics/technology/induction-furnace-tech.png",
		icon_size = 128,
		prerequisites =
		{
			"remelting-alloy-mixer-1",
		},
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "alloy-mixer-2"
			},
		},
		unit =
		{
			count = 50,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
			},
			time = 30
		},
		order = "c-a"
	},
	{
		type = "technology",
		name = "remelting-alloy-mixer-3",
		icon = "__angelssmelting__/graphics/technology/induction-furnace-tech.png",
		icon_size = 128,
		prerequisites =
		{
			"remelting-alloy-mixer-2",
		},
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "alloy-mixer-3"
			},
		},
		unit =
		{
			count = 50,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"production-science-pack", 1},
			},
			time = 30
		},
		order = "c-a"
	},
	{
		type = "technology",
		name = "remelting-alloy-mixer-4",
		icon = "__angelssmelting__/graphics/technology/induction-furnace-tech.png",
		icon_size = 128,
		prerequisites =
		{
			"remelting-alloy-mixer-3",
		},
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "alloy-mixer-4"
			},
		},
		unit =
		{
			count = 50,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"production-science-pack", 1},
				{"utility-science-pack", 1},
			},
			time = 30
		},
		order = "c-a"
	},
}
)
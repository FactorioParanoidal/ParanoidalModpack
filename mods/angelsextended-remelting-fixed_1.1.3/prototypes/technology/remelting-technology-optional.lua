data:extend(
{
	-- Remelting
	{
		type = "technology",
		name = "remelting-tier-0",
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
				recipe = "molten-iron-remelting"
			},
			{
				type = "unlock-recipe",
				recipe = "molten-copper-remelting"
			},
			{
				type = "unlock-recipe",
				recipe = "molten-tin-remelting"
			},
			{
				type = "unlock-recipe",
				recipe = "molten-silver-remelting"
			},
		},
		unit =
		{
			count = 50,
			ingredients = {
				{"automation-science-pack", 1},
			},
			time = 30
		},
		order = "c-a"
	},
	{
		type = "technology",
		name = "remelting-tier-1",
		icon = "__angelssmelting__/graphics/technology/induction-furnace-tech.png",
		icon_size = 128,
		prerequisites =
		{
			"remelting-tier-0",
		},
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "molten-lead-remelting"
			},
			{
				type = "unlock-recipe",
				recipe = "molten-zinc-remelting"
			},
			{
				type = "unlock-recipe",
				recipe = "molten-steel-remelting"
			},
			{
				type = "unlock-recipe",
				recipe = "molten-solder-remelting"
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
		name = "remelting-tier-2",
		icon = "__angelssmelting__/graphics/technology/induction-furnace-tech.png",
		icon_size = 128,
		prerequisites =
		{
			"remelting-tier-1",
			"angels-metallurgy-2",
		},
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "molten-chrome-remelting"
			},
			{
				type = "unlock-recipe",
				recipe = "molten-cobalt-remelting"
			},
			{
				type = "unlock-recipe",
				recipe = "molten-manganese-remelting"
			},
			{
				type = "unlock-recipe",
				recipe = "molten-nickel-remelting"
			},
			{
				type = "unlock-recipe",
				recipe = "molten-silicon-remelting"
			},
			{
				type = "unlock-recipe",
				recipe = "molten-glass-remelting"
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
		name = "remelting-tier-3",
		icon = "__angelssmelting__/graphics/technology/induction-furnace-tech.png",
		icon_size = 128,
		prerequisites =
		{
			"remelting-tier-2",
		},
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "molten-gold-remelting"
			},
			{
				type = "unlock-recipe",
				recipe = "molten-titanium-remelting"
			},
			{
				type = "unlock-recipe",
				recipe = "molten-aluminium-remelting"
			},
			--{
			--	type = "unlock-recipe",
			--	recipe = "molten-tungsten-remelting"
			--},
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
		name = "remelting-tier-4",
		icon = "__angelssmelting__/graphics/technology/induction-furnace-tech.png",
		icon_size = 128,
		prerequisites =
		{
			"remelting-tier-3",
			"angels-metallurgy-3",
		},
		effects =
		{
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
		name = "remelting-tier-5",
		icon = "__angelssmelting__/graphics/technology/induction-furnace-tech.png",
		icon_size = 128,
		prerequisites =
		{
			"remelting-tier-4",
		},
		effects =
		{
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
		name = "remelting-tier-6",
		icon = "__angelssmelting__/graphics/technology/induction-furnace-tech.png",
		icon_size = 128,
		prerequisites =
		{
			"remelting-tier-4",
			"angels-metallurgy-4",
		},
		effects =
		{
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
}
)
data:extend(
	{
		{
			type = "technology",
			name = "nuclear-fuel-1",
			icon_size = 128,
			icon = "__Clowns-Processing__/graphics/technology/nuclear-fuel.png",
			effects =
			{
				{
					type = "unlock-recipe",
					recipe = "nuclear-fuel"
				},
			},
			prerequisites = {
				"nuclear-power",
				"rocket-fuel",
			},
			unit =
			{
				ingredients =
				{
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack",   1 },
					{ "chemical-science-pack",   1 },
					{ "production-science-pack", 1 },
					{ "utility-science-pack",    1 }
				},
				time = 30,
				count = 100
			},
			order = "e-p-b-c"
		},
		{
			type = "technology",
			name = "nuclear-fuel-2",
			icon_size = 128,
			icon = "__Clowns-Processing__/graphics/technology/nuclear-fuel.png",
			effects =
			{
				{
					type = "unlock-recipe",
					recipe = "clowns-hypernuclear-fuel"
				},
			},
			prerequisites = { "nuclear-fuel-1", "nuclear-fuel-reprocessing-2" },
			unit =
			{
				ingredients =
				{
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack",   1 },
					{ "chemical-science-pack",   1 },
					{ "production-science-pack", 1 },
					{ "utility-science-pack",    1 }
				},
				time = 30,
				count = 100
			},
			order = "e-p-b-c"
		},
		{
			type = "technology",
			name = "nuclear-fuel-3",
			icon_size = 128,
			icon = "__Clowns-Processing__/graphics/technology/nuclear-fuel.png",
			effects =
			{
				{
					type = "unlock-recipe",
					recipe = "clowns-turbonuclear-fuel"
				},
			},
			prerequisites = { "nuclear-fuel-2", "thorium-nuclear-fuel-reprocessing-2" },
			unit =
			{
				ingredients =
				{
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack",   1 },
					{ "chemical-science-pack",   1 },
					{ "production-science-pack", 1 },
					{ "utility-science-pack",    1 }
				},
				time = 30,
				count = 100
			},
			order = "e-p-b-c"
		},
		{
			type = "technology",
			name = "radiothermal-fuel-1",
			icon_size = 128,
			icon = "__Clowns-Processing__/graphics/technology/radiothermal-fuel.png",
			effects =
			{
				{
					type = "unlock-recipe",
					recipe = "clowns-radiothermal-fuel"
				},
			},
			prerequisites = { "nuclear-power", "nuclear-fuel-reprocessing-2" },
			unit =
			{
				ingredients =
				{
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack",   1 },
					{ "chemical-science-pack",   1 },
					{ "production-science-pack", 1 },
				},
				time = 30,
				count = 100
			},
			order = "e-p-b-c"
		},
		{
			type = "technology",
			name = "radiothermal-fuel-2",
			icon_size = 128,
			icon = "__Clowns-Processing__/graphics/technology/radiothermal-fuel.png",
			effects =
			{
				{
					type = "unlock-recipe",
					recipe = "clowns-superradiothermal-fuel"
				},
			},
			prerequisites = { "radiothermal-fuel-1" },
			unit =
			{
				ingredients =
				{
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack",   1 },
					{ "chemical-science-pack",   1 },
					{ "production-science-pack", 1 },
				},
				time = 30,
				count = 100
			},
			order = "e-p-b-c"
		},
		{
			type = "technology",
			name = "radiothermal-fuel-3",
			icon_size = 128,
			icon = "__Clowns-Processing__/graphics/technology/radiothermal-fuel.png",
			effects =
			{
				{
					type = "unlock-recipe",
					recipe = "clowns-ultraradiothermal-fuel"
				},
			},
			prerequisites = { "radiothermal-fuel-2" },
			unit =
			{
				ingredients =
				{
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack",   1 },
					{ "chemical-science-pack",   1 },
					{ "production-science-pack", 1 },
				},
				time = 30,
				count = 100
			},
			order = "e-p-b-c"
		},
	}
)

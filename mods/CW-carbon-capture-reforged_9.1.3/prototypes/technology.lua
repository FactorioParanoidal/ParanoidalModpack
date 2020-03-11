data:extend({
	{
		type = "technology",
		name = "CW-air-filtering-1",
		icon = "__CW-carbon-capture-reforged__/graphics/technology/air-filtering-1.png",
		icon_size = "64",
		prerequisites = {"steel-processing", "electronics", "automation"},
		effects =
	{
		{
			type = "unlock-recipe",
			recipe = "CW-air-filter-machine-1",
		},
		{
			type = "unlock-recipe",
			recipe = "CW-empty-air-filter",
		},
		{
			type = "unlock-recipe",
			recipe = "CW-air-filter",
		},

	},
	unit ={
			count = 100,
			ingredients = 
			{
				{"automation-science-pack", 1},
			},
		time = 30
		},
		order = "d-a-a",
	},
	{
		type = "technology",
		name = "CW-air-filtering-2",
		icon = "__CW-carbon-capture-reforged__/graphics/technology/air-filtering-2.png",
		icon_size = "64",
		prerequisites = {"CW-air-filtering-1","automation-2"},
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "CW-air-filter-machine-2"
			},
		},
		unit =
		{
			count = 250,
			ingredients = 
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				
			},
			time = 30
		},
		order = "d-a-a"
	},
	{
		type = "technology",
		name = "CW-air-filtering-3",
		icon = "__CW-carbon-capture-reforged__/graphics/technology/air-filtering-3.png",
		icon_size = "64",
		prerequisites = {"CW-air-filtering-2","automation-3"},
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "CW-air-filter-machine-3"
			},
		},
		unit =
		{
			count = 500,
			ingredients = 
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
			},
			time = 60
		},
		order = "d-a-a"
	},
		{
		type = "technology",
		name = "CW-air-filtering-4",
		icon = "__CW-carbon-capture-reforged__/graphics/technology/air-filtering-4.png",
		icon_size = "64",
		prerequisites = {"CW-air-filtering-3"},
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "CW-air-filter-machine-4"
			},
		},
		unit =
		{
			count = 500,
			ingredients = 
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"production-science-pack", 2}
			},
			time = 75
		},
		order = "d-a-a"
	},
		{
		type = "technology",
		name = "CW-air-filtering-5",
		icon = "__CW-carbon-capture-reforged__/graphics/technology/air-filtering-5.png",
		icon_size = "64",
		prerequisites = {"CW-air-filtering-4"},
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "CW-air-filter-machine-5"
			},
		},
		unit =
		{
			count = 2000,
			ingredients = 
			{
				{"automation-science-pack", 2},
				{"logistic-science-pack", 2},
				{"chemical-science-pack", 2},
				{"production-science-pack", 2},
				{"utility-science-pack", 1}
			},
			time = 90
		},
		order = "d-a-a"
	},
		{
		type = "technology",
		name = "CW-air-filtering-6",
		icon = "__CW-carbon-capture-reforged__/graphics/technology/air-filtering-6.png",
		icon_size = "64",
		prerequisites = {"CW-air-filtering-5"},
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "CW-air-filter-machine-6"
			},
		},
		unit =
		{
			count = 2500,
			ingredients = 
			{
        {"automation-science-pack", 5},
        {"logistic-science-pack", 5},
        {"chemical-science-pack", 5},
        {"production-science-pack", 3},
		{"utility-science-pack", 2},
		{"space-science-pack", 1}
			},
			time = 180
		},
		order = "d-a-a"
	},
	
	{
		type = "technology",
		name = "CW-air-filter-cleaning-1",
		icon = "__CW-carbon-capture-reforged__/graphics/technology/air-filter-cleaning-1.png",
		icon_size = "64",
		prerequisites = {"CW-air-filtering-1"},
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "CW-air-filter-cleaning-1"
			},
		},
		unit =
		{
			count = 400,
			ingredients = 
			{
				{"automation-science-pack", 1}
			},
			time = 30
		},
		order = "d-a-a"
	},
	{
		type = "technology",
		name = "CW-air-filter-cleaning-2",
		icon = "__CW-carbon-capture-reforged__/graphics/technology/air-filter-cleaning-2.png",
		icon_size = "64",
		prerequisites = {"CW-air-filter-cleaning-1"},
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "CW-air-filter-cleaning-2"
			},
		},
		unit =
		{
			count = 500,
			ingredients = 
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1}
			},
			time = 60
		},
		order = "d-a-a"
	},
	{
		type = "technology",
		name = "CW-air-filter-cleaning-3",
		icon = "__CW-carbon-capture-reforged__/graphics/technology/air-filter-cleaning-3.png",
		icon_size = "64",
		prerequisites = {"CW-air-filter-cleaning-2"},
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "CW-air-filter-cleaning-3"
			},
		},
		unit =
		{
			count = 500,
			ingredients = 
			{
				{"automation-science-pack", 2},
				{"logistic-science-pack", 2},
				{"chemical-science-pack", 1},
			},
			time = 90
		},
		order = "d-a-a"
	},
	{
		type = "technology",
		name = "CW-air-filter-cleaning-4",
		icon = "__CW-carbon-capture-reforged__/graphics/technology/air-filter-cleaning-4.png",
		icon_size = "64",
		prerequisites = {"CW-air-filter-cleaning-3"},
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "CW-air-filter-cleaning-4"
			},
		},
		unit =
		{
			count = 750,
			ingredients = 
			{
				{"automation-science-pack", 2},
				{"logistic-science-pack", 2},
				{"chemical-science-pack", 1},
				{"production-science-pack", 1}
			},
			time = 90
		},
		order = "d-a-a"
	},

})

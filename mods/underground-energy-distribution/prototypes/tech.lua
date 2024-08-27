data:extend({{
		type			= "technology",
		name			= "underground-energy-distribution",
		icon			= "__underground-energy-distribution__/graphics/bg-pole.png",
		icon_size		= 256,
		prerequisites	= {"electric-energy-distribution-1"},
		effects			= {
			{type = "unlock-recipe", recipe = "ued-small-db"},
			{type = "unlock-recipe", recipe = "ued-long-distance-db"}
		},
		unit			= {
			count 		= 200,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1}},
			time 		= 30
		},
		order			= "a-b"
	},{
		type			= "technology",
		name			= "underground-energy-distribution-2",
		icon			= "__underground-energy-distribution__/graphics/sb-pole.png",
		icon_size		= 256,
		prerequisites	= {"underground-energy-distribution","electric-energy-distribution-2"},
		effects			= {
			{type = "unlock-recipe", recipe = "ued-large-db"}
		},
		unit			= {
			count		= 200,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1}
			},
			time		= 30
		},
		order			= "a-b"
	}
})
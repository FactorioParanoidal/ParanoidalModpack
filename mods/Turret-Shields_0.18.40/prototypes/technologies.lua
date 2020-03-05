data:extend({
  
  {
		type = "technology",
		name = "turret-shields-base",
		icon = "__Turret-Shields__/graphics/base-research.png",
		icon_size = 128,
		effects ={      {
        type = "unlock-recipe",
        recipe = "ts-shield-disabler"
      },
	        {
        type = "unlock-recipe",
        recipe = "turret-shield-combinator"
      }},
		prerequisites = {"military-2", "turrets"},
		unit =
		{
			count = 75,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},

			},
			time = 30
		},
		upgrade = true,
		enabled = true,
		order = "e-l-a"
	},-------------------------------------------------------------------------------------------------------------------------------
	{
		type = "technology",
		name = "turret-shields-speed-1",
		icon = "__Turret-Shields__/graphics/speed-research.png",
		icon_size = 128,
		effects =
		{{
		type = "nothing",
		effect_description = {"modifier-description.turret-shields-speed-1"},
		}},
		prerequisites = {"turret-shields-base"},
		unit =
		{
			count = 200,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"military-science-pack", 1}
			},
			time = 30
		},
		upgrade = true,
		enabled = true,
		order = "e-l-a"
	},-------------------------------------------------------------------------------------------------------------------------------
  	{
		type = "technology",
		name = "turret-shields-speed-2",
		icon = "__Turret-Shields__/graphics/speed-research.png",
		icon_size = 128,
		effects =
		{{
		type = "nothing",
		effect_description = {"modifier-description.turret-shields-speed-2"},
		}},
		prerequisites = {"turret-shields-speed-1"},
		unit =
		{
			count = 300,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"production-science-pack", 1},
				{"utility-science-pack", 1},
				{"military-science-pack", 1}
			},
			time = 45
		},
		upgrade = true,
		enabled = true,
		order = "e-l-a"
	},-------------------------------------------------------------------------------------------------------------------------------
	{
		type = "technology",
		name = "turret-shields-speed-3",
		icon = "__Turret-Shields__/graphics/speed-research.png",
		icon_size = 128,
		effects =
		{{
		type = "nothing",
		effect_description = {"modifier-description.turret-shields-speed-3"},
		}},
		prerequisites = {"turret-shields-speed-2"},
		unit =
		{
			count_formula = "(L-2)*500",
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"production-science-pack", 1},
				{"utility-science-pack", 1},
				{"military-science-pack", 1},
				{"space-science-pack", 1}
			},
			time = 60
		},
		max_level = "infinite",
		upgrade = true,
		enabled = true,
		order = "e-l-a"
	},-------------------------------------------------------------------------------------------------------------------------------
	{
		type = "technology",
		name = "turret-shields-size-1",
		icon = "__Turret-Shields__/graphics/size-research.png",
		icon_size = 128,
		effects =
		{{
		type = "nothing",
		effect_description = {"modifier-description.turret-shields-size-1"},
		}},
		prerequisites = {"turret-shields-base"},
		unit =
		{
			count = 200,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"military-science-pack", 1}
			},
			time = 30
		},
		upgrade = true,
		enabled = true,
		order = "e-l-a"
	},-------------------------------------------------------------------------------------------------------------------------------
  	{
		type = "technology",
		name = "turret-shields-size-2",
		icon = "__Turret-Shields__/graphics/size-research.png",
		icon_size = 128,
		effects =
		{{
		type = "nothing",
		effect_description = {"modifier-description.turret-shields-size-2"},
		}},
		prerequisites = {"turret-shields-size-1"},
		unit =
		{
			count = 350,
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"production-science-pack", 1},
				{"utility-science-pack", 1},
				{"military-science-pack", 1}
			},
			time = 45
		},
		upgrade = true,
		enabled = true,
		order = "e-l-a"
	},-------------------------------------------------------------------------------------------------------------------------------
	{
		type = "technology",
		name = "turret-shields-size-3",
		icon = "__Turret-Shields__/graphics/size-research.png",
		icon_size = 128,
		effects =
		{{
		type = "nothing",
		effect_description = {"modifier-description.turret-shields-size-3"},
		}},
		prerequisites = {"turret-shields-size-2"},
		unit =
		{
			count_formula = "(L-2)*500",
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"production-science-pack", 1},
				{"utility-science-pack", 1},
				{"military-science-pack", 1},
				{"space-science-pack", 1}
			},
			time = 60
		},
		max_level = "infinite",
		upgrade = true,
		enabled = true,
		order = "e-l-a"
	}
  })



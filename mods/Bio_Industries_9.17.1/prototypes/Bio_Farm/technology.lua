
---- Bio Farm
data:extend({
  
	{
		type = "technology",
		name = "bi_tech_bio_farming",
		icon_size = 128,
		icon = "__Bio_Industries__/graphics/technology/Bio_Farm_Tech_128.png",
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_seedling_mk1"
			},
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_logs_mk1"
			},
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_seed_1"
			},
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_bio_farm"
			},		
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_greenhouse"
			},	
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_arboretum"
			},	
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_arboretum_r1"
			},	
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_resin_pulp"
			},	
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_press_wood"
			},				
		},
		prerequisites = {"optics"},
		unit =
		{
			count = 25,
			ingredients =
			{
			  {"automation-science-pack", 1}
			},
			time = 20
		},
	},

	{
		type = "technology",
		name = "bi-tech-coal-processing-1",
		icon_size = 128,
		icon = "__Bio_Industries__/graphics/technology/Coal_128.png",
		effects = {
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_charcoal"
			},
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_charcoal_2"
			},

			{
				type = "unlock-recipe",
				recipe = "bi_recipe_ash_1"
			},
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_ash_2"
			},
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_woodpulp"
			},
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_seed_2"
			},
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_seedling_mk2"
			},
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_logs_mk2"
			},
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_stone_brick"
			},
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_cokery"
			},
			
		},
		prerequisites = {"advanced-material-processing"},
		unit = 
		{
			count = 150,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1}
			},
			time = 30
		},
	},

	{
		type = "technology",
		name = "bi-tech-coal-processing-2",
		icon_size = 128,
		icon = "__Bio_Industries__/graphics/technology/Coal_128.png",
		effects = {
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_coal"
			},
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_coke_coal"
			},
		},
		prerequisites =	{"bi-tech-coal-processing-1"},
		unit = 
		{
			count = 150,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
			},
			time = 35
		},
		upgrade = true,
	},

	{
		type = "technology",
		name = "bi-tech-coal-processing-3",
		icon_size = 128,
		icon = "__Bio_Industries__/graphics/technology/Coal_128.png",
		effects = {
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_coal_2"
			},
		},
		prerequisites = {"bi-tech-coal-processing-2"},
		unit = 
		{
			count = 250,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"production-science-pack", 1},
			},
			time = 40
		},
		upgrade = true,
	},

	{
		type = "technology",
		name = "bi_tech_fertiliser",
		icon_size = 128,
		icon = "__Bio_Industries__/graphics/technology/Fertiliser_128.png",
		effects = {
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_liquid_air"
			},
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_nitrogen"
			},
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_fertiliser_1"
			},
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_seedling_mk3"
			},
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_seed_3"
			},	
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_logs_mk3"
			},
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_bio_garden"
			},
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_clean_air_1"
			},
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_seed_bomb_basic"
			},
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_seed_bomb_standard"
			},
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_arboretum_r2"
			},
			{
				type = "unlock-recipe",
				recipe = "bi_recipe_arboretum_r4"
			},

		},
		prerequisites = 
		{
			"fluid-handling",
			"bi_tech_bio_farming"
		},
		unit = {
			count = 250,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1}
			},
			time = 30
		}
	},

})


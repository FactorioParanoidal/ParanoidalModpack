if BI.Settings.BI_Bio_Fuel or mods["Natural_Evolution_Buildings"] then

	data:extend(
	{


		{
			type = "technology",
			name = "bi_tech_advanced_biotechnology",
			icon_size = 128,
			icon = "__Bio_Industries__/graphics/technology/Biomass_128.png",
			effects = {
				
				{
					type = "unlock-recipe",
					recipe = "bi_recipe_seed_4"
				},
				{
					type = "unlock-recipe",
					recipe = "bi_recipe_seedling_mk4"
				},
				{
					type = "unlock-recipe",
					recipe = "bi_recipe_logs_mk4"
				},
				{
					type = "unlock-recipe",
					recipe = "bi_recipe_adv_fertiliser_2"
				},
				{
					type = "unlock-recipe",
					recipe = "bi_recipe_seed_bomb_advanced"
				},
				{
					type = "unlock-recipe",
					recipe = "bi_recipe_arboretum_r3"
				},
				{
					type = "unlock-recipe",
					recipe = "bi_recipe_arboretum_r5"
				},
			},
			prerequisites = {
				"bi_tech_fertiliser"
			},
			unit = {
				count = 200,
				ingredients = {
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1},
					{"chemical-science-pack", 1},
				},
				time = 30
			}
		},

	})

end

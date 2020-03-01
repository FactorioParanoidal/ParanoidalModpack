if BI.Settings.Bio_Cannon then

	data:extend({
		{
			type = "technology",
			name = "bi_tech_bio_cannon",
			icon_size = 128,
			icon = "__Bio_Industries__/graphics/technology/Bio_Cannon.png",
			effects = 
			{
				{
					type = "unlock-recipe",
					recipe = "bi_recipe_bio_cannon"
				},
				{
					type = "unlock-recipe",
					recipe = "bi_recipe_bio_cannon_basic_ammo"
				},
				{
					type = "unlock-recipe",
					recipe = "bi_recipe_bio_cannon_poison_ammo"
				},

			},
			prerequisites = {"military-2"},
			unit = 
			{
				count = 300,
				ingredients =
				{
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1},	
					{"military-science-pack", 1},				
				},
				time = 30,
			}
		},
		
	})

end
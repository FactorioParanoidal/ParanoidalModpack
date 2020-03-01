if BI.Settings.Bio_Cannon then

	data:extend({

	-- Hive Buster Turret
	 {
		type = "recipe",
		name = "bi_recipe_bio_cannon",

		normal =
			{
				enabled = false,
				energy_required = 50,
				ingredients = 
				{
				  {"concrete", 100},        
				  {"radar", 1},
				  {"steel-plate", 80},
				  {"electric-engine-unit", 5},
				},
			  result = "bi-bio-cannon-area",
			  result_count = 1,
			},
			expensive =
			{
				enabled = false,
				energy_required = 100,
				ingredients = 
				{
				  {"concrete", 100},      
				  {"radar", 1},
				  {"steel-plate", 120},
				  {"electric-engine-unit", 15},
				},
			  result = "bi-bio-cannon-area",
			  result_count = 1,
			},
		
	 },
	 
	})

end
if BI.Settings.BI_Solar_Additions then

	data:extend({

		--- Bio Solar Farm
		{
			type = "recipe",
			name = "bi_recipe_bio_solar_farm",
			enabled = false,
			energy_required = 60,
			ingredients = 
			{
				{"solar-panel",50},
				{"medium-electric-pole",25},
				{"concrete",400},
						
			},
			result = "bi-bio-solar-farm",
			subgroup = "bio-bio-solar-entity",
			order = "a[bi]",
		},

		
	-- solar boiler
	{
		type = "recipe",
		name = "bi_recipe_solar_boiler_panel",
		enabled = false,
		energy_required = 15,
		ingredients = 
		{
		  {"solar-panel", 30},
		  {"storage-tank", 4},
		  {"boiler", 1},
		},
		result = "bi-solar-boiler-panel",
		subgroup = "bio-bio-solar-entity",
		order = "b[bi]",
	},

	-- solar mat
	{
		type = "recipe",
		name = "bi_recipe_solar_mat",
		enabled = false,
		energy_required = 5,
		ingredients = 
		{
		  {"steel-plate", 1},
		  {"advanced-circuit", 3},
		  {"copper-cable", 4}						
		},
		result = "bi-solar-mat",
		subgroup = "bio-bio-solar-entity",
		order = "c[bi]",
	},
	

	--- BI Accumulator
		{
			type = "recipe",
			name = "bi_recipe_accumulator",
			energy_required = 60,
			enabled = false,
			ingredients =
			{
			  {"accumulator", 50},
			  {"copper-cable", 50},
			  {"concrete",200},
			},
			result = "bi-bio-accumulator",
			subgroup = "bio-bio-solar-entity",
			order = "d[bi]",
		},
		
	-- Large Substation	
	  {
		type = "recipe",
		name = "bi_recipe_huge_substation",
		enabled = false,
		ingredients =
		{
		  {"steel-plate", 10},
		  {"concrete",200},
		  {"substation", 4}
		},
		result = "bi-large-substation",
		subgroup = "bio-bio-solar-entity",
		order = "e[bi]",
	  },
	  

	
	
})

end

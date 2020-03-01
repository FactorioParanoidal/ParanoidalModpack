if BI.Settings.BI_Bio_Fuel then 

	data:extend({

		--- Bio Boiler (ENTITY) ---
		{
			type = "recipe",
			name = "bi_recipe_boiler",
			normal =
			{
				enabled = false,
				energy_required = 10,
				ingredients = 
				{
				  {"boiler",1},
				  {"steel-plate",5},
				  {"concrete",5},
				},
				result = "bi-bio-boiler",
				result_count = 1,
			},
			expensive =
			{
				enabled = false,
				energy_required = 15,
				ingredients = 
				{
				  {"boiler",2},
				  {"steel-plate",5},
				  {"concrete",5},
				},
				result = "bi-bio-boiler",
				result_count = 1,
			},
			
		},
	  
		-- BIO Reactor (ENTITY)--
		{
			type = "recipe",
			name = "bi_recipe_bioreactor",
			normal =
			{
				enabled = false,
				energy_required = 20,
				ingredients = 
				{
				  {"assembling-machine-1",1},
				  {"steel-plate",5},
				  {"electronic-circuit",5},
				},
				result = "bi-bioreactor",
				result_count = 1,
			},
			expensive =
			{
				enabled = false,
				energy_required = 30,
				ingredients = 
				{
				  {"assembling-machine-1",2},
				  {"steel-plate",5},
				  {"electronic-circuit",5},
				},
				result = "bi-bioreactor",
				result_count = 1,
			},
			subgroup = "bio-bio-fuel-fluid",
			order = "a"		
		},
			
		-- CELLULOSE 1 --
		{
			type = "recipe",
			name = "bi_recipe_cellulose_1",
			icon = "__Bio_Industries__/graphics/icons/cellulose.png",
			icon_size = 32,
			category = "chemistry",
			energy_required = 20,
			ingredients =
			{
				{type="item", name="bi-woodpulp", amount=10},
				{type="fluid", name="sulfuric-acid", amount=10}, 
			},
			results=
			{
				{type="item", name="bi-cellulose", amount=10 }
			},
			enabled = false,
			always_show_made_in = true,
			allow_decomposition = false,
			subgroup = "bio-bio-fuel-other",
			order = "[bi-cellulose-1]",
		},
		
		-- CELLULOSE 2 --
		{
			type = "recipe",
			name = "bi_recipe_cellulose_2",
			icon = "__Bio_Industries__/graphics/icons/cellulose_2.png",
			icon_size = 32,
			category = "chemistry",
			energy_required = 5,
			ingredients =
			{
				{type="fluid", name="steam", amount=10},
				{type="item", name="bi-woodpulp", amount=10},
				{type="fluid", name="sulfuric-acid", amount=20}, 
			},
			results=
			{
				{type="item", name="bi-cellulose", amount=10 }
			},
			enabled = false,
			always_show_made_in = true,
			allow_decomposition = false,
			subgroup = "bio-bio-fuel-other",
			order = "[bi-cellulose-2]",
		},
			
		-- PLASTIC 1 --
		{
			type = "recipe",
			name = "bi_recipe_plastic_1",
			icon = "__Bio_Industries__/graphics/icons/plastic_bar_1.png",
			icon_size = 32,
			category = "chemistry",
			--subgroup = "raw-material",
			energy_required = 1,
			ingredients =
			{
				{type="fluid", name="steam", amount=10},
				{type="item", name="wood", amount=10},
				{type="fluid", name="light-oil", amount=20},
			},
			results=
			{
				{type="item", name="plastic-bar", amount=2}
			},
			enabled = false,
			always_show_made_in = true,
			allow_decomposition = false,
			subgroup = "bio-bio-fuel-solid",
			order = "g[plastic-bar-1]",

		},
		
		-- PLASTIC 2 --
			{
			type = "recipe",
			name = "bi_recipe_plastic_2",
			icon = "__Bio_Industries__/graphics/icons/plastic_bar_2.png",
			icon_size = 32,
			category = "chemistry",
			energy_required = 1,
			ingredients =
			{
				{type="item", name="bi-cellulose", amount=1},
				{type="fluid", name="petroleum-gas", amount=10},
			},
			results=
			{
				{type="item", name="plastic-bar", amount=2}
			},
			enabled = false,
			always_show_made_in = true,
			allow_decomposition = false,
			subgroup = "bio-bio-fuel-solid",
			order = "g[plastic-bar-2]",
		},
		
		-- BIOMASS 1 --
		{
			type = "recipe",
			name = "bi_recipe_biomass_1",
			icon = "__Bio_Industries__/graphics/icons/biomass_1.png",
			icon_size = 32,
			category = "biofarm-mod-bioreactor",
			energy_required = 10,
			ingredients =
			{
				{type="fluid", name="water", amount=100},
				{type="item", name="fertiliser", amount=10},
			},
			results=
			{
				{type="fluid", name="bi-biomass", amount=50},
			},
			enabled = false,
			always_show_made_in = true,
			allow_decomposition = false,
			subgroup = "bio-bio-fuel-fluid",
			order = "x[oil-processing]-z1[bi-biomass]"
		},	
		
		-- BIOMASS 2 --
		{
			type = "recipe",
			name = "bi_recipe_biomass_2",
			icon = "__Bio_Industries__/graphics/icons/biomass_2.png",
			icon_size = 32,
			category = "biofarm-mod-bioreactor",
			energy_required = 10,
			ingredients =
			{
				{type="fluid", name="water", amount=90},
				{type="fluid", name="liquid-air", amount=10},
				{type="fluid", name="bi-biomass", amount=10},
				{type="item", name="bi-ash", amount=10},		
			},
			results=
			{
				{type="fluid", name="bi-biomass", amount=100},
			},
			enabled = false,
			always_show_made_in = true,
			allow_decomposition = false,
			subgroup = "bio-bio-fuel-fluid",
			order = "x[oil-processing]-z2[bi-biomass]"
		},	
		
		-- BIOMASS 3 --
		{
			type = "recipe",
			name = "bi_recipe_biomass_3",
			icon = "__Bio_Industries__/graphics/icons/biomass_3.png",
			icon_size = 32,
			category = "biofarm-mod-bioreactor",
			energy_required = 60,
			ingredients =
			{
				{type="fluid", name="water", amount=90},
				{type="fluid", name="liquid-air", amount=10},
				{type="fluid", name="bi-biomass", amount=10},
			},
			results=
			{
				{type="fluid", name="bi-biomass", amount=35},
			},
			enabled = false,
			always_show_made_in = true,
			allow_decomposition = false,
			subgroup = "bio-bio-fuel-fluid",
			order = "x[oil-processing]-z3[bi-biomass]"
		},	
		
		---- Biomass to Light-oil
	  {
		type = "recipe",
		name = "bi_recipe_biomass_conversion_1",
		icon = "__Bio_Industries__/graphics/icons/bio_conversion_1.png", 
		icon_size = 32,
		category = "oil-processing",
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		energy_required = 5,
		ingredients =
		{
			{type="fluid", name="bi-biomass", amount=100},
			{type="fluid", name="water", amount=10},
		},
		results=
		{
			{type="item", name="bi-cellulose", amount=2},
			{type="fluid", name="light-oil", amount=80},
		},  
		subgroup = "bio-bio-fuel-other",
		order = "a[oil-processing]-b[advanced-oil-processing]-y[bi-Fuel_Conversion-1]",
	  },

		---- Biomass to PG
	  {
		type = "recipe",
		name = "bi_recipe_biomass_conversion_2",
		icon = "__Bio_Industries__/graphics/icons/bio_conversion_2.png",
		icon_size = 32,	
		category = "oil-processing",
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		energy_required = 5,
		ingredients =
		{
			{type="fluid", name="bi-biomass", amount=10},
			{type="fluid", name="water", amount=10},
		},
		results=
		{
			{type="fluid", name="petroleum-gas", amount=20}
		},   
		subgroup = "bio-bio-fuel-other",
		order = "a[oil-processing]-b[advanced-oil-processing]-y[bi-Fuel_Conversion-2]",
	  },

		---- Biomass to Lube
	  {
		type = "recipe",
		name = "bi_recipe_biomass_conversion_3",
		icon = "__Bio_Industries__/graphics/icons/bio_conversion_3.png",
		icon_size = 32,	
		category = "oil-processing",
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		energy_required = 2.5,
		ingredients =
		{
			{type="fluid", name="bi-biomass", amount=10},
			{type="fluid", name="water", amount=10},
		},
		results=
		{
			{type="fluid", name="lubricant", amount=10}
		},   
		crafting_machine_tint =
		{
		  primary = {r = 0.000, g = 0.260, b = 0.010, a = 0.000}, -- #00420200
		  secondary = {r = 0.071, g = 0.640, b = 0.000, a = 0.000}, -- #12a30000
		  tertiary = {r = 0.026, g = 0.520, b = 0.000, a = 0.000}, -- #06840000
		},
		subgroup = "bio-bio-fuel-other",
		order = "a[oil-processing]-b[advanced-oil-processing]-y[bi-Fuel_Conversion-3]",
	  },


	  --- Bio Battery 	
		{
			type = "recipe",
			name = "bi_recipe_battery",
			icon = "__Bio_Industries__/graphics/icons/bio_battery.png",
			icon_size = 32,
			category = "chemistry",
			energy_required = 5,
			ingredients =
			{
				{type="item", name="plastic-bar", amount=1},
				{type="fluid", name="bi-biomass", amount=10},
				{type="item", name="bi-cellulose", amount=1},	
			},
			results=
			{
				{type="item", name="battery", amount=1},	
			},
			enabled = false,
			always_show_made_in = true,
			allow_decomposition = false,
			crafting_machine_tint =
			{
				primary = {r = 0.970, g = 0.611, b = 0.000, a = 0.000}, -- #f79b0000
				secondary = {r = 0.000, g = 0.680, b = 0.894, a = 0.357}, -- #00ade45b
				tertiary = {r = 0.430, g = 0.805, b = 0.726, a = 0.000}, -- #6dcdb900
			},
			subgroup = "bio-bio-fuel-solid",
			order = "h",
		},	
		
		  --- Bio Acid
		{
			type = "recipe",
			name = "bi_recipe_acid",
			icon = "__Bio_Industries__/graphics/icons/bio_acid.png",
			icon_size = 32,
			category = "chemistry",
			energy_required = 10,
			ingredients =
			{
				{type="fluid", name="water", amount=90},
				{type="fluid", name="bi-biomass", amount=10},
				{type="item", name="bi-cellulose", amount=5},
			},
			results=
			{
				{type="fluid", name="sulfuric-acid", amount=50}, 
			},
			enabled = false,
			always_show_made_in = true,
			allow_decomposition = false,
			subgroup = "fluid-recipes",
			crafting_machine_tint =
			{
				primary = {r = 0.875, g = 0.735, b = 0.000, a = 0.000}, -- #dfbb0000
				secondary = {r = 0.103, g = 0.940, b = 0.000, a = 0.000}, -- #1aef0000
				tertiary = {r = 0.564, g = 0.795, b = 0.000, a = 0.000}, -- #8fca0000
			},
			subgroup = "bio-bio-fuel-other",
			order = "a",
		},	
		
		-- Sulfuric acid to Sulfur --
		{
			type = "recipe",
			name = "bi_recipe_sulfur",
			icon = "__Bio_Industries__/graphics/icons/bio_sulfur.png",
			icon_size = 32,
			category = "chemistry",
			energy_required = 10,		
			ingredients =
			{
				{type="fluid", name="sulfuric-acid", amount=10}, 
				{type="item", name="bi-ash", amount=10},
			},
			results=
			{
				{type="item", name="sulfur", amount=10}
			},
			enabled = false,
			always_show_made_in = true,
			allow_decomposition = false,
			subgroup = "bio-bio-fuel-solid",
			order = "i1",
		},
		
		-- Sulfuric acid to Sulfur --IF ANGELS INSTALLED (More Expensice)
		{
			type = "recipe",
			name = "bi_recipe_sulfur_angels",
			icon = "__Bio_Industries__/graphics/icons/bio_sulfur.png",
			icon_size = 32,
			category = "chemistry",
			energy_required = 10,		
			ingredients =
			{
				{type="fluid", name="sulfuric-acid", amount=50}, 
				{type="item", name="bi-ash", amount=10},
			},
			results=
			{
				{type="item", name="sulfur", amount=10}
			},
			enabled = false,
			always_show_made_in = true,
			allow_decomposition = false,
			subgroup = "bio-bio-fuel-solid",
			order = "i2",
		},
		
		
	})

end
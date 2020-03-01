data:extend({

	

	--- Seeds from Water (BASIC)
	{
		type = "recipe",
		name = "bi_recipe_seed_1",
		icon = "__Bio_Industries__/graphics/icons/bio_seed1.png",
		icon_size = 32,
		category = "biofarm-mod-greenhouse",	
		energy_required = 200,
		ingredients =
		{
			{type="fluid", name="water", amount=100},
			{type="item", name="wood", amount=20},    	
		},
		results=
		{
			{type="item", name="bi-seed", amount=40},
		},
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		subgroup = "bio-bio-farm-fluid-1",
		order = "a[bi]-ssw-a1[bi_recipe_seed_1]",		
	},
	
	
	--- Seeds from Water & Ash	
	{
		type = "recipe",
		name = "bi_recipe_seed_2",
		icon = "__Bio_Industries__/graphics/icons/bio_seed2.png",
		icon_size = 32,
		category = "biofarm-mod-greenhouse",	
		energy_required = 150,
		ingredients =
		{
			{type="fluid", name="water", amount=40},
			{type="item", name="wood", amount=20},     
			{type="item", name="bi-ash", amount=10},   
		},
		results=
		{
			{type="item", name="bi-seed", amount=50},
		},
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		subgroup = "bio-bio-farm-fluid-1",
		order = "a[bi]-ssw-a1[bi_recipe_seed_2]",	
	},
	
	
	--- Seeds from Water & Fertiliser
	{
		type = "recipe",
		name = "bi_recipe_seed_3",
		icon = "__Bio_Industries__/graphics/icons/bio_seed3.png",
		icon_size = 32,
		category = "biofarm-mod-greenhouse",	
		energy_required = 100,
		ingredients =
		{
			{type="fluid", name="water", amount=40},
			{type="item", name="wood", amount=20},     
			{type="item", name="fertiliser", amount=10},   
		},
		results=
		{
			{type="item", name="bi-seed", amount=60},
		},
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		subgroup = "bio-bio-farm-fluid-1",
		order = "a[bi]-ssw-a1[bi_recipe_seed_3]",	
	},

	
	--- Seeds from Water & Adv-fertiliser 
	{
		type = "recipe",
		name = "bi_recipe_seed_4",
		icon = "__Bio_Industries__/graphics/icons/bio_seed4.png",
		icon_size = 32,
		category = "biofarm-mod-greenhouse",	
		energy_required = 50,
		ingredients =
		{
			{type="item", name="wood", amount=20},     
			{type="item", name="bi-adv-fertiliser", amount=10},   
			{type="fluid", name="water", amount=40},
		},
		results=
		{
			{type="item", name="bi-seed", amount=80},
		},
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		subgroup = "bio-bio-farm-fluid-1",
		order = "a[bi]-ssw-a1[bi_recipe_seed_4]",	
	},

	
	--- Seedlings from Water (BASIC)
	{
		type = "recipe",
		name = "bi_recipe_seedling_mk1",
		icon = "__Bio_Industries__/graphics/icons/Seedling1.png",
		icon_size = 32,
		category = "biofarm-mod-greenhouse",
		energy_required = 400,
		ingredients =
		{
			{type="item", name="bi-seed", amount=20},     
			{type="fluid", name="water", amount=100},
		},
		results=
		{
			{type="item", name="seedling", amount=40},
		},
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		subgroup = "bio-bio-farm-fluid-2",
		order = "b[bi]-ssw-b1[bi-Seedling_Mk1]",
	},

	
	--- Seedlings from Water & Ash
	{
		type = "recipe",
		name = "bi_recipe_seedling_mk2",
		icon = "__Bio_Industries__/graphics/icons/Seedling2.png",
		icon_size = 32,
		category = "biofarm-mod-greenhouse",
		energy_required = 300,
		ingredients =
		{
		  {type="item", name="bi-seed", amount=25},     
		  {type="item", name="bi-ash", amount=10},     
		  {type="fluid", name="water", amount=100},
		},
		results=
		{
			{type="item", name="seedling", amount=60},
		},
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		subgroup = "bio-bio-farm-fluid-2",
		order = "b[bi]-ssw-b1[bi-Seedling_Mk2]",
	},
	
		
	--- Seedlings from Water & Fertiliser
	{
		type = "recipe",
		name = "bi_recipe_seedling_mk3",
		icon = "__Bio_Industries__/graphics/icons/Seedling3.png",
		icon_size = 32,
		category = "biofarm-mod-greenhouse",
		energy_required = 200,
		ingredients =
		{
		  {type="item", name="bi-seed", amount=30},     
		  {type="item", name="fertiliser", amount=10},     
		  {type="fluid", name="water", amount=100},
		},
		results=
		{
			{type="item", name="seedling", amount=90},
		},
		enabled = false,
		always_show_made_in = true,
		subgroup = "bio-bio-farm-fluid-2",
		order = "b[bi]-ssw-b1[bi-Seedling_Mk3]",
	},
	
		
	--- Seedlings from Water & Adv-fertiliser 
	{
		type = "recipe",
		name = "bi_recipe_seedling_mk4",
		icon = "__Bio_Industries__/graphics/icons/Seedling4.png",
		icon_size = 32,
		category = "biofarm-mod-greenhouse",
		energy_required = 100,
		ingredients =
		{
		  {type="item", name="bi-seed", amount=40},     
		  {type="fluid", name="water", amount=100},
		  {type="item", name="bi-adv-fertiliser", amount=10},    
		},
		results=
		{
			{type="item", name="seedling", amount=160},
		},
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		subgroup = "bio-bio-farm-fluid-2",
		order = "b[bi]-ssw-b1[bi-Seedling_Mk4]",
	},
		
	
	--- Raw Wood from Water (BASIC)
	{
		type = "recipe",
		name = "bi_recipe_logs_mk1",
		icon = "__Bio_Industries__/graphics/icons/raw-wood-mk1.png",
		icon_size = 32,
		category = "biofarm-mod-farm",
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		energy_required = 400,
		ingredients =
		{
			{type="item", name="seedling", amount=20},     
			{type="fluid", name="water", amount=100},
		},
		results =
		{
			{type = "item", name = "wood", amount = 40},
			{type = "item", name = "bi-woodpulp", amount = 80},
		},
		main_product = "wood",
		subgroup = "bio-bio-farm-fluid-3",
		order = "c[bi]-ssw-c1[raw-wood1]",
	},
	
		
	--- Raw Wood from Water & Ash
	{
		type = "recipe",
		name = "bi_recipe_logs_mk2",
		icon = "__Bio_Industries__/graphics/icons/raw-wood-mk2.png",
		icon_size = 32,
		category = "biofarm-mod-farm",
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		energy_required = 360,
		ingredients =
		{
		  {type="item", name="seedling", amount=30},     
		  {type="item", name="bi-ash", amount=10},     
		  {type="fluid", name="water", amount=100},
		},
		results =
		{
			{type = "item", name = "wood", amount = 75},
			{type = "item", name = "bi-woodpulp", amount = 150},
		},
		main_product = "wood",
		subgroup = "bio-bio-farm-fluid-3",
		order = "c[bi]-ssw-c1[raw-wood2]",
	},
	
		
	--- Raw Wood from Water & fertiliser
	{
		type = "recipe",
		name = "bi_recipe_logs_mk3",
		icon = "__Bio_Industries__/graphics/icons/raw-wood-mk3.png",
		icon_size = 32,
		category = "biofarm-mod-farm",
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		energy_required = 300,
		ingredients =
		{
		  {type="item", name="seedling", amount=45},     
		  {type="item", name="fertiliser", amount=10},     
		  {type="fluid", name="water", amount=100},
		},
		results =
		{
			{type = "item", name = "wood", amount = 135},
			{type = "item", name = "bi-woodpulp", amount = 270},
		},
		main_product = "wood",		
		subgroup = "bio-bio-farm-fluid-3",
		order = "c[bi]-ssw-c1[raw-wood3]",
	},
	
		
	--- Raw Wood from adv-fertiliser
	{
		type = "recipe",
		name = "bi_recipe_logs_mk4",
		icon = "__Bio_Industries__/graphics/icons/raw-wood-mk4.png",
		icon_size = 32,
		category = "biofarm-mod-farm",
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		energy_required = 100,
		ingredients =
		{
		  {type="item", name="seedling", amount=40},     
		  {type="fluid", name="water", amount=100},
		  {type="item", name="bi-adv-fertiliser", amount=5},    
		},
		results =
		{
			{type = "item", name = "wood", amount = 160},
			{type = "item", name = "bi-woodpulp", amount = 320},
		},
		main_product = "wood",
		subgroup = "bio-bio-farm-fluid-3",
		order = "c[bi]-ssw-c1[raw-wood4]",
	},

	
	--- Bio Greenhouse (ENTITY)
	{
		type = "recipe",
		name = "bi_recipe_greenhouse",
		icon = "__Bio_Industries__/graphics/icons/bio_greenhouse.png",
		icon_size = 32,
		normal =
		{
			enabled = false,
			energy_required = 5,
			ingredients = 
			{
			  {"iron-stick",10},
			  {"stone-crushed",10},
			  {"small-lamp",5},
			},
		  result = "bi-bio-greenhouse",
		  result_count = 1,
		},
		expensive =
		{
			enabled = false,
			energy_required = 8,
			ingredients = 
			{
			  {"iron-stick",15},
			  {"stone-crushed",15},
			  {"small-lamp",5},
			},
		  result = "bi-bio-greenhouse",
		  result_count = 1,
		},
		subgroup = "bio-bio-farm-fluid-entity",
		order = "a[bi]",
	},

	
	--- Bio Farm (ENTITY)
	{
		type = "recipe",
		name = "bi_recipe_bio_farm",
		icon = "__Bio_Industries__/graphics/icons/Bio_Farm_Icon.png",
		icon_size = 32,
		normal =
		{
			enabled = false,
			energy_required = 10,
			ingredients = 
			{
			  {"bi-bio-greenhouse",4},
			  {"copper-cable",10},
			  {"stone-brick",10},
			},
		  result = "bi-bio-farm",
		  result_count = 1,
		},
		expensive =
		{
			enabled = false,
			energy_required = 15,
			ingredients = 
			{
			  {"bi-bio-greenhouse",8},
			  {"copper-cable",20},
			  {"stone-brick",20},
			},
		  result = "bi-bio-farm",
		  result_count = 1,
		},
		subgroup = "bio-bio-farm-fluid-entity",
		order = "b[bi]",
	},
	
	
	-- Woodpulp--
	{
		type = "recipe",
		name = "bi_recipe_woodpulp",
		icon = "__Bio_Industries__/graphics/icons/Woodpulp_raw-wood.png",
		icon_size = 32,
		subgroup = "bio-bio-farm-raw",
		order = "a[bi]-a-b[bi-woodpulp]",
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		allow_as_intermediate = false,
		energy_required = 2.5,
		ingredients = {{"wood",2}},
		result = "bi-woodpulp",
		result_count = 6,
	}, 

 	--- Resin recipe  Pulp
	{
		type = "recipe",
		name = "bi_recipe_resin_pulp",
		icon = "__Bio_Industries__/graphics/icons/bi_resin_pulp.png",
		icon_size = 32,
		subgroup = "bio-bio-farm-raw",
		order = "a[bi]-a-b[bi-resin]",
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		allow_as_intermediate = false,
		energy_required = 3,
		ingredients = 
		{
			 {type="item", name="bi-woodpulp", amount=4},
		},
		result = "resin",
		result_count = 1,

	},
	
	-- Wood - Press Wood
	{
		type = "recipe",
		name = "bi_recipe_press_wood",
		icon = "__Bio_Industries__/graphics/icons/bi_wood_resin_pulp.png",
		icon_size = 32,
		--category = "crafting-machine",
		subgroup = "bio-bio-farm-raw",
		order = "a[bi]-a-c[bi-press_wood]",
		energy_required = 2,	
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		allow_as_intermediate = false,
		ingredients =
		{
			{type="item", name="bi-woodpulp", amount=4},
			{type="item", name="resin", amount=1},
		},
		results=
		{
			{type="item", name="wood", amount=2}
		},

	},

	-- ASH --
	{
		type = "recipe",
		name = "bi_recipe_ash_1",
		icon = "__Bio_Industries__/graphics/icons/ash_raw-wood.png",
		icon_size = 32,
		category = "biofarm-mod-smelting",
		subgroup = "bio-bio-farm-raw",
		order = "a[bi]-a-b[bi-ash]",
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		allow_as_intermediate = false,
		energy_required = 10,
		ingredients = {{"wood",5}},
		result = "bi-ash",
		result_count = 10,		
	},   


	-- ASH 2--
	{
		type = "recipe",
		name = "bi_recipe_ash_2",
		icon = "__Bio_Industries__/graphics/icons/ash_woodpulp.png",
		icon_size = 32,
		category = "biofarm-mod-smelting",
		subgroup = "bio-bio-farm-raw",
		order = "a[bi]-a-b[bi-ash2]",
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		allow_as_intermediate = false,
		energy_required = 5,
		ingredients = {{"bi-woodpulp",12}},
		result = "bi-ash",
		result_count = 10,
	}, 

	
	-- CHARCOAL 1
	{
		type = "recipe",
		name = "bi_recipe_charcoal",
		icon = "__Bio_Industries__/graphics/icons/charcoal_woodpulp.png",
		icon_size = 32,
		subgroup = "bio-bio-farm-raw",
		order = "a[bi]-a-c[charcoal1]",
		category = "biofarm-mod-smelting",
		energy_required = 12.5,
		ingredients = {{"bi-woodpulp",48}},
		result = "bi-charcoal",
		result_count = 18,
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		allow_as_intermediate = false,
	},


	-- CHARCOAL 2
	{
		type = "recipe",
		name = "bi_recipe_charcoal_2",
		icon = "__Bio_Industries__/graphics/icons/charcoal_raw-wood.png",
		icon_size = 32,
		subgroup = "bio-bio-farm-raw",
		order = "a[bi]-a-c[charcoal2]",
		category = "biofarm-mod-smelting",
		energy_required = 20,
		ingredients = {{"wood",20}},
		result = "bi-charcoal",
		result_count = 18,
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		allow_as_intermediate = false,
	},	


	-- COAL 1 --
	{
		type = "recipe",
		name = "bi_recipe_coal",
		icon = "__Bio_Industries__/graphics/icons/coal_mk1.png",
		icon_size = 32,
		category = "biofarm-mod-smelting",
		subgroup = "bio-bio-farm-raw",
		order = "a[bi]-a-d[bi-coal]",
		energy_required = 12,
		ingredients = {{"bi-charcoal",12}},
		result = "coal",
		result_count = 8,
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		allow_as_intermediate = false,
	},


	-- COAL 2 --
	{
		type = "recipe",
		name = "bi_recipe_coal_2",
		icon = "__Bio_Industries__/graphics/icons/coal_mk2.png",
		icon_size = 32,
		category = "biofarm-mod-smelting",
		subgroup = "bio-bio-farm-raw",
		order = "a[bi]-a-d[bi-coal2]",
		energy_required = 18,
		ingredients = {{"bi-charcoal",12}},
		result = "coal",
		result_count = 10,
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		allow_as_intermediate = false,
	},


	-- Pellet-Coke from Coal -- Use to be Coke-Coal
		{
		type = "recipe",
		name = "bi_recipe_coke_coal",
		icon = "__Bio_Industries__/graphics/icons/pellet_coke_1.png",
		icon_size = 32,
		category = "biofarm-mod-smelting",
		subgroup = "bio-bio-farm-raw",
		order = "a[bi]-a-e[bi-coke-coal]-1",
		energy_required = 15,
		ingredients = {{"coal",15}},
		result = "pellet-coke",
		result_count = 6,
		enabled = false,
		always_show_made_in = true,
		allow_as_intermediate = false,
	},

 
 -- CRUSHED STONE --
	{
		type = "recipe",
		name = "bi_recipe_crushed_stone",
		icon = "__Bio_Industries__/graphics/icons/crushed-stone.png",
		icon_size = 32,
		category = "biofarm-mod-crushing",
		subgroup = "bio-bio-farm-raw",
		order = "a[bi]-a-z[stone-crushed]",
		energy_required = 2,
		ingredients = {{"stone",1}},
		result = "stone-crushed",
		result_count = 2,
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		allow_as_intermediate = false,
	},

	
 -- STONE Brick--
	{
		type = "recipe",
		name = "bi_recipe_stone_brick",
		icon = "__Bio_Industries__/graphics/icons/bi_stone_brick.png",
		icon_size = 32,
		--category = "smelting",
		category = "chemistry",
		subgroup = "bio-bio-farm-raw",
		order = "a[bi]-a-z2[stone-brick]",
		energy_required = 5,
		ingredients =
		{
		  {type="item", name="stone-crushed", amount=6},     
		  {type="item", name="bi-ash", amount=2},     
		},
		results =
		{
			{type = "item", name = "stone-brick", amount = 2},
		},
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		allow_as_intermediate = false,
	},
	
	
	-- COKERY (ENTITY)--
	{
		type = "recipe",
		name = "bi_recipe_cokery",	
		normal =
		{
			enabled = false,
			energy_required = 8,
			ingredients = 
			{
			  {"stone-furnace",3},
			  {"steel-plate",10},
			},
		  result = "bi-cokery",
		  result_count = 1,
		},
		expensive =
		{
			enabled = false,
			energy_required = 10,
			ingredients = 
			{
			  {"stone-furnace",3},
			  {"steel-plate",12},
			},
		  result = "bi-cokery",
		  result_count = 1,
		},
		subgroup = "bio-bio-farm-raw-entity",
		order = "a[bi]",
	},


	-- STONE CRUSHER (ENTITY) --
	{
		type = "recipe",
		name = "bi_recipe_stone_crusher",
		normal =
		{
			enabled = false,
			energy_required = 8,
			ingredients = 
			{
			  {"iron-plate",10},
			  {"steel-plate",10},
			  {"iron-gear-wheel",5},
			},
		  result = "bi-stone-crusher",
		  result_count = 1,
		},
		expensive =
		{
			enabled = false,
			energy_required = 10,
			ingredients = 
			{
			  {"iron-plate",12},
			  {"steel-plate",12},
			  {"iron-gear-wheel",8},
			},
		  result = "bi-stone-crusher",
		  result_count = 1,
		},
		subgroup = "bio-bio-farm-raw-entity",
		order = "b[bi]",
	},


	-- LIQUID-AIR --
	{
		type = "recipe",
		name = "bi_recipe_liquid_air",
		category = "chemistry",
		energy_required = 1,
		ingredients = {},
		results=
		{
			{type = "fluid", name = "liquid-air", amount = 10}
		},
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		allow_as_intermediate = false,
		subgroup = "bio-bio-farm-intermediate-product",
		order = "aa",
	},


	-- -NITROGEN --
	{
		type = "recipe",
		name = "bi_recipe_nitrogen",
		category = "chemistry",
		energy_required = 10,
		ingredients =
		{
		  {type="fluid", name="liquid-air", amount=20}
		},
		results=
		{
		  {type="fluid", name="nitrogen", amount=20},
		},
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		allow_as_intermediate = false,
		main_product= "nitrogen",
		subgroup = "bio-bio-farm-intermediate-product",
		order = "ab",
	},

	
	-- fertiliser- Sulfur-
	{
		type = "recipe",
		name = "bi_recipe_fertiliser_1",
		icon = "__Bio_Industries__/graphics/icons/fertiliser_sulfur.png",
		icon_size = 32,
		category = "chemistry",
		energy_required = 5,
		ingredients =
		{
			{type = "item", name = "sulfur", amount = 1},
			{type="fluid", name="nitrogen", amount=10},
			{type="item", name="bi-ash", amount=10}
		},
		results=
		{
			{type="item", name="fertiliser", amount=5}
		},
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		allow_as_intermediate = false,
		subgroup = "bio-bio-farm-intermediate-product",
		order = "b[fertiliser]",
	},

		
	-- Advanced fertiliser 1 --
	{
		type = "recipe",
		name = "bi_recipe_adv_fertiliser_1",
		icon = "__Bio_Industries__/graphics/icons/advanced_fertiliser_32.png",
		icon_size = 32,
		category = "chemistry",
		energy_required = 50,		
		ingredients =
		{
			{type="item", name="fertiliser", amount=25},
			--{type="item", name="bi-biomass", amount=10}, -- <== Need to add during Data Updates
			--{type="fluid", name="NE_enhanced-nutrient-solution", amount=5}, -- Will be added if you have Natural Evolution Buildings Mod installed.
		},
		results=
		{
			{type="item", name="bi-adv-fertiliser", amount=50}
		},
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		allow_as_intermediate = false,
		subgroup = "bio-bio-farm-intermediate-product",
		order = "b[fertiliser]-b[bi-adv-fertiliser-1]",
	},


	-- Advanced fertiliser 2--
	{
		type = "recipe",
		name = "bi_recipe_adv_fertiliser_2",
		icon = "__Bio_Industries__/graphics/icons/advanced_fertiliser_32.png",
		icon_size = 32,
		category = "chemistry",
		energy_required = 50,
		ingredients =
		{
			{type="item", name="fertiliser", amount=20},
			--{type="item", name="bi-biomass", amount=10}, -- <== Need to add during Data Updates
			{type="item", name="bi-woodpulp", amount=10},
		},
		results=
		{
			{type="item", name="bi-adv-fertiliser", amount=20}
		},
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		allow_as_intermediate = false,
		subgroup = "bio-bio-farm-intermediate-product",
		order = "b[fertiliser]-b[bi-adv-fertiliser-2]",
	},
	

	--- Seed Bomb - Basic
	   {
		type = "recipe",
		name = "bi_recipe_seed_bomb_basic",
		normal =
		{
		  enabled = false,
		  energy_required = 8,
		  ingredients =
		  {
			{"bi-seed", 400},
			{"rocket", 1},
		  },
		  result = "bi-seed-bomb-basic",
		},
		expensive =
		{
		  enabled = false,
		  energy_required = 8,
		  ingredients =
		  {
			{"bi-seed", 400},
			{"rocket", 2},
		  },
		  result = "bi-seed-bomb-basic",
		}
	  },

	  
	   --- Seed Bomb - Standard
	   {
		type = "recipe",
		name = "bi_recipe_seed_bomb_standard",
		normal =
		{
		  enabled = false,
		  energy_required = 8,
		  ingredients =
		  {
			{"bi-seed", 400},
			{"fertiliser", 200},
			{"rocket", 1},
		  },
		  result = "bi-seed-bomb-standard",
		},
		expensive =
		{
		  enabled = false,
		  energy_required = 8,
		  ingredients =
		  {
			{"bi-seed", 400},
			{"fertiliser", 200},
			{"rocket", 2},
		  },
		  result = "bi-seed-bomb-standard",
		}
	  },


	  --- Seed Bomb - Advanced 
	   {
		type = "recipe",
		name = "bi_recipe_seed_bomb_advanced",
		normal =
		{
		  enabled = false,
		  energy_required = 8,
		  ingredients =
		  {
			{"bi-seed", 400},
			{"bi-adv-fertiliser", 200},
			{"rocket", 1},
		  },
		  result = "bi-seed-bomb-advanced",
		},
		expensive =
		{
		  enabled = false,
		  energy_required = 8,
		  ingredients =
		  {
			{"bi-seed", 400},
			{"bi-adv-fertiliser", 200},
			{"rocket", 2},
		  },
		  result = "bi-seed-bomb-advanced",
		}
	  },
	  
	  
	 --- 	Arboretum (ENTITY)
	{
		type = "recipe",
		name = "bi_recipe_arboretum",
		icon = "__Bio_Industries__/graphics/icons/Arboretum_Icon.png",
		icon_size = 32,
		normal =
		{
			enabled = false,
			energy_required = 10,
			ingredients = 
			{
			  {"bi-bio-greenhouse",4},
			  {"assembling-machine-2",2},
			  {"stone-brick",10},
			},
		  result = "bi-arboretum-area",
		  result_count = 1,
		},
		expensive =
		{
			enabled = false,
			energy_required = 15,
			ingredients = 
			{
			  {"bi-bio-greenhouse",4},
			  {"assembling-machine-2",4},
			  {"stone-brick",20},
			},
		  result = "bi-arboretum-area",
		  result_count = 1,
		},
		subgroup = "bio-arboretum-fluid",
		order = "1-a[bi]",	
	},
	

 	--- 	Arboretum -  Plant Trees
	{
		type = "recipe",
		name = "bi_recipe_arboretum_r1",
		icon = "__Bio_Industries__/graphics/icons/Seedling_b.png",
		icon_size = 32,
		category = "bi-arboretum",	
		energy_required = 10000,
		ingredients =
		{
			{type="item", name="seedling", amount=1},     
			{type="fluid", name="water", amount=100},
		},
		results=
		{
			{type="item", name="bi-arboretum-r1", amount=1, probability=0},
		},
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		allow_as_intermediate = false,
		subgroup = "bio-arboretum-fluid",
		order = "a[bi]-ssw-a1[bi-arboretum-r1]",		
	},
	
 	--- 	Arboretum - Change Terrain
	{
		type = "recipe",
		name = "bi_recipe_arboretum_r2",
		icon = "__Bio_Industries__/graphics/icons/bi_change_1.png",
		icon_size = 32,
		category = "bi-arboretum",	
		energy_required = 10000,
		ingredients =
		{  
			{type="item", name="fertiliser", amount=1},    
			{type="fluid", name="water", amount=100},			
		},
		results=
		{
			{type="item", name="bi-arboretum-r2", amount=1, probability=0},
		},
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		allow_as_intermediate = false,
		subgroup = "bio-arboretum-fluid",
		order = "a[bi]-ssw-a1[bi-arboretum-r2]",		
	},
	  
 	--- 	Arboretum -  Change Terrain - Advanced
	{
		type = "recipe",
		name = "bi_recipe_arboretum_r3",
		icon = "__Bio_Industries__/graphics/icons/bi_change_2.png",
		icon_size = 32,
		category = "bi-arboretum",	
		energy_required = 10000,
		ingredients =
		{
			{type="item", name="bi-adv-fertiliser", amount=1},    
			{type="fluid", name="water", amount=100},			
		},
		results=
		{
			{type="item", name="bi-arboretum-r3", amount=1, probability=0},
		},
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		allow_as_intermediate = false,
		subgroup = "bio-arboretum-fluid",
		order = "a[bi]-ssw-a1[bi-arboretum-r3]",		
	},
	    
  	--- 	Arboretum -  Plant Trees & Change Terrain
	{
		type = "recipe",
		name = "bi_recipe_arboretum_r4",
		icon = "__Bio_Industries__/graphics/icons/bi_change_plant_1.png",
		icon_size = 32,
		category = "bi-arboretum",	
		energy_required = 10000,
		ingredients =
		{
			{type="item", name="seedling", amount=1},     
			{type="item", name="fertiliser", amount=1},    
			{type="fluid", name="water", amount=100},			
		},
		results=
		{
			{type="item", name="bi-arboretum-r4", amount=1, probability=0},
		},
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		allow_as_intermediate = false,
		subgroup = "bio-arboretum-fluid",
		order = "a[bi]-ssw-a1[bi-arboretum-r4]",		
	},
	  
 	--- 	Arboretum -  Plant Trees & Change Terrain Advanced
	{
		type = "recipe",
		name = "bi_recipe_arboretum_r5",
		icon = "__Bio_Industries__/graphics/icons/bi_change_plant_2.png",
		icon_size = 32,
		category = "bi-arboretum",	
		energy_required = 10000,
		ingredients =
		{
			{type="item", name="seedling", amount=1},     
			{type="item", name="bi-adv-fertiliser", amount=1},    
			{type="fluid", name="water", amount=100},			
		},
		results=
		{
			{type="item", name="bi-arboretum-r5", amount=1, probability=0},
		},
		enabled = false,
		always_show_made_in = true,
		allow_decomposition = false,
		allow_as_intermediate = false,
		subgroup = "bio-arboretum-fluid",
		order = "a[bi]-ssw-a1[bi-arboretum-r5]",		
	},
	  	  	  

	  
	  
})

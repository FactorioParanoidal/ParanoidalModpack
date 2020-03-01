data:extend({

	--- Big Electric Pole
	{
		type = "recipe",
		name = "bi_recipe_big_wooden_pole",
		normal =
		{
			enabled = false,
			ingredients = 
			{
			  {"wood", 10},    
			  {"small-electric-pole", 2},  
			},
		  result = "bi-big-wooden-pole"
		},
		expensive =
		{
			enabled = false,
			ingredients = 
			{
			  {"wood", 20},    
			  {"small-electric-pole", 4},  
			},
		  result = "bi-big-wooden-pole"
		},	
	},
	
	--- Huge Wooden Pole	
	{
		type = "recipe",
		name = "bi_recipe_huge_wooden_pole",
		normal =
		{
			enabled = false,
			ingredients = 
			{
			  {"wood", 10}, 
			  {"concrete", 100},   			  
			  {"bi-big-wooden-pole", 6},  
			},
		  result = "bi-huge-wooden-pole"
		},
		expensive =
		{
			enabled = false,
			ingredients = 
			{
			  {"wood", 20},  
			  {"concrete", 150},   				  
			  {"bi-big-wooden-pole", 10},  
			},
		  result = "bi-huge-wooden-pole"
		},	
	},
	
	--- Wooden Fence
	{
		type = "recipe",
		name = "bi_recipe_wooden_fence",
		normal =
		{
			enabled = true,
			ingredients = 
			{
			  {"wood", 2},
			},
			result = "bi-wooden-fence",
		},
		expensive =
		{
			enabled = true,
			ingredients = 
			{
			  {"wood", 4},
			},
			result = "bi-wooden-fence",
		},	
	},
  
	--- Wooden Rail
    {
		type = "recipe",
		name = "bi_recipe_rail_wood",	
		normal =
		{
			enabled = false,
			ingredients = 
			{		
				{"wood", 8},
				{"stone", 1},
				{"steel-plate", 2},
				{"iron-stick", 2},	  
			},
			result = "bi-rail-wood",
			result_count = 2,
			requester_paste_multiplier = 4
		},
		expensive =
		{
			enabled = false,
			ingredients = 
			{			
				{"wood", 8},
				{"stone", 1},
				{"steel-plate", 2},			 
				{"iron-stick", 2},
			},
			result = "bi-rail-wood",
			result_count = 1,
			requester_paste_multiplier = 4
		},	

  },

 	--- Wooden Rail to Concrete Rail
    {
		type = "recipe",
		icon = "__Bio_Industries__/graphics/icons/rail-wood-to-concrete.png",
		icon_size = 32,
		name = "bi_recipe_rail_wood_to_concrete",	
		normal =
		{
			enabled = false,
			ingredients = 
			{		
				{"bi-rail-wood", 3},
				{"stone-brick", 10},
			},
			result = "rail",
			result_count = 2,
			requester_paste_multiplier = 4
		},
		expensive =
		{
			enabled = false,
			ingredients = 
			{			
				{"bi-rail-wood", 2},
				{"stone-brick", 10},
			},
			result = "rail",
			result_count = 1,
			requester_paste_multiplier = 4
		},
		subgroup = "transport",
		order = "a[train-system]-aa1[rail-upgrade]",		

	}, 
--- Wooden Bridge Rail
    {
		type = "recipe",
		name = "bi_recipe_rail_wood_bridge",	
		normal =
		{
			enabled = false,
			ingredients = 
			
			{	  
			  {"bi-rail-wood", 1},
			  {"steel-plate", 1},
			  {"wood", 32}
			},
			result = "bi-rail-wood-bridge",
			result_count = 2,
			requester_paste_multiplier = 4
		},
		expensive =
		{
			enabled = false,
			ingredients = 
			
			{	  
			  {"bi-rail-wood", 1},
			  {"steel-plate", 1},
			  {"wood", 32}
			},
			result = "bi-rail-wood-bridge",
			result_count = 1,
			requester_paste_multiplier = 4
		},

  },

  	--- Power Rail
    {
		type = "recipe",
		name = "bi_rail_power",	
		normal =
		{
			enabled = false,
			ingredients = 
			{		
				{"rail", 2},
				{"copper-cable", 6},

			},
			result = "bi-rail-power",
			result_count = 2,
			requester_paste_multiplier = 4
		},
		expensive =
		{
			enabled = false,
			ingredients = 
			{			
				{"rail", 1},
				{"copper-cable", 6},

			},
			result = "bi-rail-power",
			result_count = 1,
			requester_paste_multiplier = 4
		},	

  },

	--- Wood Pipe
    {
		type = "recipe",
		name = "bi_recipe_wood_pipe",
		normal =
		{
			energy_required = 1,
			enabled = true,
			ingredients = 
			{	  
			  --{"copper-plate", 1},
			  {"wood", 12}
			},
		  result = "bi-wood-pipe",
		  result_count = 4,
		  requester_paste_multiplier = 15
		},
		expensive =
		{
			energy_required = 2,
			enabled = true,
			ingredients = 
			{	  
			  --{"copper-plate", 1},
			  {"wood", 16}
			},
		  result = "bi-wood-pipe",
		  result_count = 4,
		  requester_paste_multiplier = 15
		},
  },
 	
  -- Wood Pipe to Ground
  {
		type = "recipe",
		name = "bi_recipe_pipe_to_ground_wood",
		normal =
		{
			energy_required = 2,
			enabled = true,
			ingredients = 
			{	  
			  --{"copper-plate", 4},
			  {"bi-wood-pipe", 10}
			},
		  result = "bi-pipe-to-ground-wood",
		  result_count = 2,
		},
		expensive =
		{
			energy_required = 4,
			enabled = true,
			ingredients = 
			{	  
			  --{"copper-plate", 5},
			  {"bi-wood-pipe", 16}
			},
		  result = "bi-pipe-to-ground-wood",
		  result_count = 2,
		},
  },

  	--- Rail to Power Pole
	{
		type = "recipe",
		name = "bi_recipe_power_to_rail_pole",
		normal =
		{
			enabled = false,
			ingredients = 
			{
			  {"copper-cable", 10},    
			  {"medium-electric-pole", 1},  
			},
		  result = "bi-power-to-rail-pole"
		},
		expensive =
		{
			enabled = false,
			ingredients = 
			{
			  {"copper-cable", 25},
			  {"medium-electric-pole", 1},  
			},
		  result = "bi-power-to-rail-pole"
		},	
	},
	
	--- Large Wooden Chest
  {
    type = "recipe",
    name = "bi_recipe_large_wooden_chest",
	normal =
		{
			energy_required = 4,
			enabled = false,
			ingredients = 
			{	  
			  {"copper-plate", 16},
			  {"resin", 32},
			  {"wooden-chest", 8}
			},
		  result = "bi-large-wooden-chest",
		  result_count = 1,
		  requester_paste_multiplier = 4
		},
	expensive =
		{
			energy_required = 8,
			enabled = false,
			ingredients = 
			{	  
			  {"copper-plate", 24},
			  {"resin", 48},
			  {"wooden-chest", 8}
			},
		  result = "bi-large-wooden-chest",
		  result_count = 1,
		  requester_paste_multiplier = 4,
		},

  },
 
	--- Huge Wooden Chest
  {
    type = "recipe",
    name = "bi_recipe_huge_wooden_chest",
	normal =
		{
			energy_required = 8,
			enabled = false,
			ingredients = 
			{	  
			  {"iron-stick", 32},
			  {"stone-brick", 32},
			  {"bi-large-wooden-chest", 16}
			},
		  result = "bi-huge-wooden-chest",
		  result_count = 1,
		  requester_paste_multiplier = 4
		},
	expensive =
		{
			energy_required = 16,
			enabled = false,
			ingredients = 
			{	  
			  {"iron-stick", 48},
			  {"stone-brick", 48},
			  {"bi-large-wooden-chest", 16}
			},
		  result = "bi-huge-wooden-chest",
		  result_count = 1,
		  requester_paste_multiplier = 4,
		},

  }, 

  	--- Giga Wooden Chest
  {
    type = "recipe",
    name = "bi_recipe_giga_wooden_chest",
	normal =
		{
			energy_required = 16,
			enabled = false,
			ingredients = 
			{	  
			  {"steel-plate", 32},
			  {"concrete", 32},
			  {"bi-huge-wooden-chest", 16}
			},
		  result = "bi-giga-wooden-chest",
		  result_count = 1,
		  requester_paste_multiplier = 4
		},
	expensive =
		{
			energy_required = 32,
			enabled = false,
			ingredients = 
			{	  
			  {"steel-plate", 48},
			  {"concrete", 48},
			  {"bi-huge-wooden-chest", 16}
			},
		  result = "bi-giga-wooden-chest",
		  result_count = 1,
		  requester_paste_multiplier = 4,
		},

  }, 
 })


if BI.Settings.BI_Game_Tweaks_Disassemble then

	--- Bio Tweaks
	data:extend(
	{
	  {
		type = "item-subgroup",
		name = "bio-disassemble",
		group = "bio-industries",
		order = "zzzz",
	  },
	 

	 
		{
			type = "recipe",
			name = "bi_recipe_burner_mining_drill_disassemble",
			icon = "__Bio_Industries__/graphics/icons/burner-mining-drill_disassemble.png",
			icon_size = 32,
			subgroup = "bio-disassemble",
			category = "advanced-crafting",
			order = "a[Disassemble]-a[bi_recipe_burner_mining_drill_disassemble]",
			enabled = false,
			allow_as_intermediate = false,
			energy_required = 2,
			ingredients =
				{
				  {type="item", name="burner-mining-drill", amount=1},   	  
				},
			results =
				{
					{"stone", 4},
					{"iron-plate", 4}
				},

		},

	  
		{
			type = "recipe",
			name = "bi_recipe_stone_furnace_disassemble",
			icon = "__Bio_Industries__/graphics/icons/stone_furnace_disassemble.png",
			icon_size = 32,
			subgroup = "bio-disassemble",
			category = "advanced-crafting",
			order = "a[Disassemble]-b[bi_recipe_stone_furnace_disassemble]",
			enabled = false,
			allow_as_intermediate = false,
			energy_required = 2,
			ingredients =
				{
				  {type="item", name="stone-furnace", amount=1},   	  
				},
			results =		
				{
				  {"stone", 3},
				},
				
	  },
	  
	   
		
		{
			type = "recipe",
			name = "bi_recipe_burner_inserter_disassemble",
			icon = "__Bio_Industries__/graphics/icons/burner_inserter_disassemble.png",
			icon_size = 32,
			subgroup = "bio-disassemble",
			category = "advanced-crafting",
			order = "a[Disassemble]-c[bi_recipe_burner_inserter_disassemble]",
			enabled = false,
			allow_as_intermediate = false,
			energy_required = 2,
			ingredients =
				{
				  {type="item", name="burner-inserter", amount=1},   	  
				},
			results =		
				{
				  {"iron-plate", 2},
				},
				
	  },


	  
		{
			type = "recipe",
			name = "bi_recipe_long_handed_inserter_disassemble",
			icon = "__Bio_Industries__/graphics/icons/long_handed_inserter_disassemble.png",
			icon_size = 32,
			subgroup = "bio-disassemble",
			category = "advanced-crafting",
			order = "a[Disassemble]-e[bi_recipe_long_handed_inserter_disassemble]",
			enabled = false,
			allow_as_intermediate = false,
			energy_required = 2,
			ingredients =
				{
				  {type="item", name="long-handed-inserter", amount=1},   	  
				},
			results =		
				{
				  {"iron-gear-wheel", 1},
				  {"iron-plate", 1},
				  {"electronic-circuit", 1},
				},
				
	  },



		{
			type = "recipe",
			name = "bi_recipe_steel_furnace_disassemble",
			icon = "__Bio_Industries__/graphics/icons/steel-furnace_disassemble.png",
			icon_size = 32,
			subgroup = "bio-disassemble",
			category = "advanced-crafting",
			order = "a[Disassemble]-f[bi_recipe_steel_furnace_disassemble]",
			enabled = false,
			allow_as_intermediate = false,
			energy_required = 2,
			ingredients =
				{
				  {type="item", name="steel-furnace", amount=1},   	  
				},
			results =		
				{
				  {"steel-plate", 4},
				  {"stone-brick", 4}
				},
				
	  },

	  
	  
	})

	if data.raw.item["bi-burner-pump"] then

		data:extend({
		  
				{
					type = "recipe",
					name = "bi_recipe_basic_pumpjack_disassemble",
					icon = "__Bio_Industries__/graphics/icons/bi_basic_pumpjack_disassemble.png",
					icon_size = 32,
					subgroup = "bio-disassemble",
					category = "advanced-crafting",
					order = "a[Disassemble]-d[bi_basic_pumpjack_disassemble]",
					enabled = false,
					allow_as_intermediate = false,
					energy_required = 2,
					ingredients =
						{
						  {type="item", name="bi-burner-pump", amount=1},   	  
						},
					results =		
						{
						  {"pipe", 3},
						  {"iron-gear-wheel", 3}
						},
						
				}
				
			})
		
	end

end

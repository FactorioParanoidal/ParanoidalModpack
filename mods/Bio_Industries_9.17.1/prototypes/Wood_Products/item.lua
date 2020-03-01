data:extend({

	--- Big Wooden Electric Pole
	{
		type = "item",
		name = "bi-big-wooden-pole",
		icon = "__Bio_Industries__/graphics/icons/big-wooden-pole.png",
		icon_size = 32,
		--flags = {"goes-to-quickbar"},
		subgroup = "energy-pipe-distribution",
		order = "a[energy]-b[small-electric-pole]",
		place_result = "bi-big-wooden-pole",
		fuel_value = "20MJ",
		fuel_category = "chemical",
		stack_size = 50

	},

	--- Huge Wooden Pole
	{
		type = "item",
		name = "bi-huge-wooden-pole",
		icon = "__Bio_Industries__/graphics/icons/huge-wooden-pole.png",
		icon_size = 32,
		--flags = {"goes-to-quickbar"},
		subgroup = "energy-pipe-distribution",
		order = "a[energy]-d[big-electric-pole]",
		place_result = "bi-huge-wooden-pole",
		fuel_value = "80MJ",
		fuel_category = "chemical",
		stack_size = 50

	},
	
	-- Wooden Fence
	{
		type = "item",
		name = "bi-wooden-fence",
		icon = "__Bio_Industries__/graphics/icons/wooden-fence.png",
		icon_size = 32,
		--flags = {"goes-to-quickbar"},
		subgroup = "defensive-structure",
		order = "a-a[stone-wall]-a[wooden-fence]",
		place_result = "bi-wooden-fence",
		fuel_value = "12MJ",
		fuel_category = "chemical",
		stack_size = 50
	},

	--- Wood Rail Planner
	{
		type = "rail-planner",
		name = "bi-rail-wood",
		icon = "__Bio_Industries__/graphics/icons/rail-wood.png",
		icon_size = 32,
		--flags = {"goes-to-quickbar"},
		subgroup = "transport",
		order = "a[train-system]-a[rail]",
		place_result = "bi-straight-rail-wood",
		stack_size = 100,
		straight_rail = "bi-straight-rail-wood",
		curved_rail = "bi-curved-rail-wood"
	},

	  --- Wooden Bridge Rail  
  	{
		type = "rail-planner",
		name = "bi-rail-wood-bridge",
		icon = "__Bio_Industries__/graphics/icons/rail-wood-bridge.png",
		icon_size = 32,
		--flags = {"goes-to-quickbar"},
		subgroup = "transport",
		order = "a[train-system]-aa[rail]",
		place_result = "bi-straight-rail-wood-bridge",
		stack_size = 100,
		straight_rail = "bi-straight-rail-wood-bridge",
		curved_rail = "bi-curved-rail-wood-bridge"
	},

  	--- Electric Rail Planner
	{
		type = "rail-planner",
		name = "bi-rail-power",
		icon = "__Bio_Industries__/graphics/icons/rail-concrete-power.png",
		icon_size = 32,
		--flags = {"goes-to-quickbar"},
		subgroup = "transport",
		order = "a[train-system]-ab[rail]",
		place_result = "bi-straight-rail-power",
		stack_size = 100,
		straight_rail = "bi-straight-rail-power",
		curved_rail = "bi-curved-rail-power"
	},

  --- Wood Pipe
	{
		type = "item",
		name = "bi-wood-pipe",
		icon = "__Bio_Industries__/graphics/icons/wood_pipe.png",
		icon_size = 32,
		--flags = {"goes-to-quickbar"},
		subgroup = "energy-pipe-distribution",
		order = "a[pipe]-1a[pipe]",
		place_result = "bi-wood-pipe",
		fuel_value = "2MJ",
		fuel_category = "chemical",
		stack_size = 100
	},
	
  --- Wood Pipe to Ground
	{
		type = "item",
		name = "bi-pipe-to-ground-wood",
		icon = "__Bio_Industries__/graphics/icons/pipe-to-ground-wood.png",
		icon_size = 32,
		--flags = {"goes-to-quickbar"},
		subgroup = "energy-pipe-distribution",
		order = "a[pipe]-1b[pipe-to-ground]",
		place_result = "bi-pipe-to-ground-wood",
		fuel_value = "4MJ",  --DrD
		fuel_category = "chemical",
		stack_size = 50
	},
	
	--- Large wooden chest 2 x 2
	  {
		type = "item",
		name = "bi-large-wooden-chest",
		icon = "__Bio_Industries__/graphics/icons/large_wooden_chest_icon.png",
		icon_size = 32,
		--flags = {"goes-to-quickbar"},
		fuel_category = "chemical",
		fuel_value = "16MJ",
		subgroup = "storage",
		order = "a[items]-aa[wooden-chest]",
		place_result = "bi-large-wooden-chest",
		stack_size = 48
	  },

	  	--- Huge wooden chest 3 x 3
	  {
		type = "item",
		name = "bi-huge-wooden-chest",
		icon = "__Bio_Industries__/graphics/icons/huge_wooden_chest_icon.png",
		icon_size = 32,
		--flags = {"goes-to-quickbar"},
		fuel_category = "chemical",
		fuel_value = "40MJ",
		subgroup = "storage",
		order = "a[items]-ab[wooden-chest]",
		place_result = "bi-huge-wooden-chest",
		stack_size = 32
	  },

	  	--- Giga wooden chest 6 x 6
	  {
		type = "item",
		name = "bi-giga-wooden-chest",
		icon = "__Bio_Industries__/graphics/icons/giga_wooden_chest_icon.png",
		icon_size = 32,
		--flags = {"goes-to-quickbar"},
		fuel_category = "chemical",
		fuel_value = "160MJ",
		subgroup = "storage",
		order = "a[items]-ac[wooden-chest]",
		place_result = "bi-giga-wooden-chest",
		stack_size = 16
	  },	  
	  ---- Power pole to connect Rail to Power Grid
	    {
		type = "item",
		name = "bi-power-to-rail-pole",
		icon = "__Bio_Industries__/graphics/icons/electric-to-rail.png",
		icon_size = 32,
		--flags = {"goes-to-quickbar"},
		subgroup = "transport",
		order = "a[train-system]-ac[rail]",
		place_result = "bi-power-to-rail-pole",
		stack_size = 50
		},
	
	
})


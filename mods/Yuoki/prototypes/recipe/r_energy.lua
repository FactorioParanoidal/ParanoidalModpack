data:extend({
	-- Little Stirling Engine
	--[[
	{
		type = "recipe",
		name = "y-small-stirling-engine-recipe",
		ingredients = {{"y-basic-t1-mf",1},{"y-heat-pipe",2},},
		result = "y-small-stirling-engine",
		enabled = true,
		result_count = 1,
		order="p-b",
		subgroup = "yuoki-energy-gen",
	},
	{
		type = "item",
		name = "y-small-stirling-engine",
		icon_size = 64, icon =  "__Yuoki__/graphics/icons/fce-icon.png",
		order = "1",
		--place_result = "y-small-stirling-engine",
		stack_size = 25,
		group="yuoki",
		subgroup = "y-parts",
	},
	]]

	{
		type = "recipe",
		name = "y-stirling-solar-dish",
		ingredients = {
			{ type = "item", name = "y-chip-1", amount = 2 },
			{ type = "item", name = "y-heat-pipe", amount = 2 },
			{ type = "item", name = "y_structure_element", amount = 3 },
		},
		results = {
			{ type = "item", name = "y-stirling-solar-dish", amount = 1 },
		},
		main_product = "y-stirling-solar-dish",
		enabled = true,
		order = "e-za",
		group = "yuoki-energy",
		subgroup = "y-energy-2",
	},
	{
		type = "item",
		name = "y-stirling-solar-dish",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/stir-solar-dish-icon.png",
		order = "e-za",
		group = "yuoki-energy",
		subgroup = "y-energy-2",
		place_result = "y-stirling-solar-dish",
		stack_size = 50,
	},

	{
		type = "recipe",
		name = "y_alien_solar",
		ingredients = {
			{ type = "item", name = "y_structure_element", amount = 122 },
			{ type = "item", name = "y-orange-stuff", amount = 100 },
			{ type = "item", name = "y-raw-fuelnium", amount = 10 },
			{ type = "item", name = "y-chip-1", amount = 30 },
			{ type = "item", name = "y_rwtechsign", amount = 20 },
		},
		results = {
			{ type = "item", name = "y_alien_solar", amount = 1 },
		},
		main_product = "y_alien_solar",
		enabled = true,
		order = "e-zb",
		group = "yuoki-energy",
		subgroup = "y-energy-2",
	},
	{
		type = "item",
		name = "y_alien_solar",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/yi_alien_solar_icon.png",
		order = "zb",
		group = "yuoki-energy",
		subgroup = "y-energy-2",
		place_result = "y_alien_solar",
		stack_size = 24,
		weight = 250 * kg,
	},

	{
		type = "recipe",
		name = "y_alien_solar2",
		ingredients = {
			{ type = "item", name = "y_structure_element", amount = 92 },
			{ type = "item", name = "y-orange-stuff", amount = 100 },
			{ type = "item", name = "y-infused-uca2", amount = 12 },
			{ type = "item", name = "y-quantrinum", amount = 4 },
			{ type = "item", name = "y_rwtechsign", amount = 30 },
		},
		results = {
			{ type = "item", name = "y_alien_solar2", amount = 1 },
		},
		main_product = "y_alien_solar2",
		enabled = true,
		order = "e-zc",
		group = "yuoki-energy",
		subgroup = "y-energy-2",
	},
	{
		type = "item",
		name = "y_alien_solar2",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/yi_alien_solar2_icon.png",
		order = "zc",
		group = "yuoki-energy",
		subgroup = "y-energy-2",
		place_result = "y_alien_solar2",
		stack_size = 14,
	},

	-- small electric generator
	{
		type = "recipe",
		name = "y-seg",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/energy-t2/seg_icon.png",
		ingredients = {
			{ type = "item", name = "y-basic-t2-mf", amount = 1 },
			{ type = "item", name = "y_structure_element", amount = 8 },
			{ type = "item", name = "y-chip-1", amount = 2 },
		},
		results = {
			{ type = "item", name = "y-seg", amount = 1 },
			{ type = "item", name = "y_rwtechsign", amount = 1 },
		},
		main_product = "y-seg",
		enabled = true,
		group = "yuoki-energy",
		subgroup = "y-boiler",
		order = "g-1",
	},

	-- medium-s electric generator
	{
		type = "recipe",
		name = "y-meg-s",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/energy-t2/meg-s-icon.png",
		ingredients = {
			{ type = "item", name = "y-basic-t2-mf", amount = 2 },
			{ type = "item", name = "y_structure_element", amount = 16 },
			{ type = "item", name = "y-chip-1", amount = 3 },
			{ type = "item", name = "y_blocked_capa", amount = 4 },
		},
		results = {
			{ type = "item", name = "y-meg-s", amount = 1 },
			{ type = "item", name = "y_rwtechsign", amount = 3 },
		},
		main_product = "y-meg-s",
		enabled = true,
		group = "yuoki-energy",
		subgroup = "y-boiler",
		order = "g-2",
	},

	-- big electric generator
	{
		type = "recipe",
		name = "y-beg",
		ingredients = {
			{ type = "item", name = "y-basic-t2-mf", amount = 4 },
			{ type = "item", name = "y_structure_element", amount = 24 },
			{ type = "item", name = "y-chip-2", amount = 7 },
			{ type = "item", name = "y_blocked_capa", amount = 8 },
			{ type = "item", name = "y_rwtechsign", amount = 3 },
		},
		results = {
			{ type = "item", name = "y-beg", amount = 1 },
		},
		main_product = "y-beg",
		enabled = true,
		group = "yuoki-energy",
		subgroup = "y-boiler",
		order = "g-3",
	},

	-- huge electric generator
	{
		type = "recipe",
		name = "y-heg",
		ingredients = {
			{ type = "item", name = "y-basic-t2-mf", amount = 6 },
			{ type = "item", name = "y_structure_element", amount = 32 },
			{ type = "item", name = "y-chip-2", amount = 12 },
			{ type = "item", name = "y_blocked_capa", amount = 14 },
			{ type = "item", name = "y-bluegear", amount = 8 },
			{ type = "item", name = "y_rwtechsign", amount = 12 },
		},
		results = {
			{ type = "item", name = "y-heg", amount = 1 },
		},
		main_product = "y-heg",
		enabled = true,
		group = "yuoki-energy",
		subgroup = "y-boiler",
		order = "g-4",
	},

	{
		type = "recipe",
		name = "y-boiler-iv",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/boiler3mw_icon2.png",
		ingredients = {
			{ type = "item", name = "steel-plate", amount = 3 },
			{ type = "item", name = "y_structure_element", amount = 8 },
			{ type = "item", name = "y_gauge", amount = 1 },
			{ type = "item", name = "y-pipe-hc", amount = 8 },
		},
		results = {
			{ type = "item", name = "y-boiler-iv", amount = 1 },
			{ type = "item", name = "y_rwtechsign", amount = 2 },
		},
		main_product = "y-boiler-iv",
		group = "yuoki-energy",
		subgroup = "y-boiler",
		order = "b-1",
	},

	--y-obninsk-reactor
	{
		type = "recipe",
		name = "y-obninsk-reactor",
		ingredients = {
			{ type = "item", name = "y-rare-wall-adv", amount = 36 },
			{ type = "item", name = "y_structure_element", amount = 82 },
			{ type = "item", name = "y-pipe-ec", amount = 68 },
			{ type = "item", name = "y-basic-t2-mf", amount = 13 },
			{ type = "item", name = "y_structure_vessel", amount = 34 },
			{ type = "item", name = "y_rwtechsign", amount = 200 },
		},
		results = {
			{ type = "item", name = "y-obninsk-reactor", amount = 1 },
		},
		main_product = "y-obninsk-reactor",
		group = "yuoki-energy",
		subgroup = "y-boiler",
		order = "b-2",
	},

	-- Generators
	--y-obninsk-turbine (rensuir)
	{
		type = "recipe",
		name = "y-obninsk-turbine",
		ingredients = {
			{ type = "item", name = "y_structure_vessel", amount = 34 },
			{ type = "item", name = "y-basic-t2-mf", amount = 12 },
			{ type = "item", name = "yi_magnetron", amount = 12 },
			{ type = "item", name = "y-quantrinum", amount = 3 },
			{ type = "item", name = "y_rwtechsign", amount = 75 },
		},
		results = {
			{ type = "item", name = "y-obninsk-turbine", amount = 1 },
			{ type = "item", name = "ye_science_blue", amount = 2 },
		},
		main_product = "y-obninsk-turbine",
		group = "yuoki-energy",
		subgroup = "y-boiler",
		order = "s3",
	},

	{
		type = "recipe",
		name = "y-notfall-generator-s2",
		ingredients = {
			{ type = "item", name = "iron-plate", amount = 7 },
			{ type = "item", name = "iron-gear-wheel", amount = 4 },
			{ type = "item", name = "copper-plate", amount = 4 },
		},
		results = {
			{ type = "item", name = "y-notfall-generator-s2", amount = 1 },
		},
		main_product = "y-notfall-generator-s2",
		enabled = true,
		group = "yuoki-energy",
		subgroup = "y-boiler",
		order = "s1",
	},

	-- big (ab Jan/2015 standard-steam-turbine)
	{
		type = "recipe",
		name = "y-steam-turbine",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/steam_turbine_n3_icon.png",
		ingredients = {
			{ type = "item", name = "y_structure_element", amount = 16 },
			{ type = "item", name = "y-heat-pipe", amount = 12 },
			{ type = "item", name = "y-chip-1", amount = 3 },
		},
		results = {
			{ type = "item", name = "y-steam-turbine", amount = 1 },
			{ type = "item", name = "y_rwtechsign", amount = 2 },
		},
		main_product = "y-steam-turbine",
		enabled = true,
		group = "yuoki-energy",
		subgroup = "y-boiler",
		order = "s2",
	},
})

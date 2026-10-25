data:extend({

	{
		type = "recipe",
		name = "y-bluegear",
		enabled = true,
		energy_required = 0.5,
		group = "yuoki",
		subgroup = "y-parts",
		order = "p-g1",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/bluegear_icon.png",
		ingredients = {
			{ type = "item", name = "steel-plate", amount = 1 },
			{ type = "item", name = "y-refined-yres1", amount = 1 },
		},
		results = {
			{ type = "item", name = "y-bluegear", amount = 3 },
		},
		main_product = "y-bluegear",
	},

	{
		type = "recipe",
		name = "y_structure_element",
		enabled = true,
		energy_required = 0.5,
		group = "yuoki",
		subgroup = "y-parts",
		order = "p-g2",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/structur_element.png",
		ingredients = {
			{ type = "item", name = "iron-plate", amount = 4 },
			{ type = "item", name = "y-unicomp-raw", amount = 2 },
		},
		results = {
			{ type = "item", name = "y_structure_element", amount = 3 },
		},
		main_product = "y_structure_element",
	},

	{
		type = "recipe",
		name = "y_structure_vessel",
		enabled = true,
		energy_required = 0.5,
		group = "yuoki",
		subgroup = "y-parts",
		order = "p-g3",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/vessel_structure64_icon.png",
		ingredients = {
			{ type = "item", name = "steel-plate", amount = 2 },
			{ type = "item", name = "y-unicomp-raw", amount = 1 },
		},
		results = {
			{ type = "item", name = "y_structure_vessel", amount = 2 },
		},
		main_product = "y_structure_vessel",
	},

	-- basic stage-1 maschine frame
	{
		type = "recipe",
		name = "y-basic-t1-mf",
		ingredients = {
			{ type = "item", name = "y-conductive-wire-1", amount = 3 },
			{ type = "item", name = "y-bluegear", amount = 3 },
			{ type = "item", name = "y_structure_element", amount = 2 },
		},
		results = {
			{ type = "item", name = "y-basic-t1-mf", amount = 1 },
		},
		main_product = "y-basic-t1-mf",
		enabled = true,
		group = "yuoki",
		subgroup = "y-parts",
		order = "p-g4",
	},

	-- basic stage-2 maschine frame
	{
		type = "recipe",
		name = "y-basic-t2-mf",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/maschine-frame-2_icon.png",
		ingredients = {
			{ type = "item", name = "y-conductive-coil-1", amount = 2 },
			{ type = "item", name = "y_structure_electric", amount = 3 },
			{ type = "item", name = "y-bluegear", amount = 4 },
		},
		results = {
			{ type = "item", name = "y-basic-t2-mf", amount = 1 },
			{ type = "item", name = "y_rwtechsign", amount = 1 },
		},
		main_product = "y-basic-t2-mf",
		enabled = true,
		group = "yuoki",
		subgroup = "y-parts",
		order = "p-g5",
	},

	-- Heat-Cool-Rib-Block
	{
		type = "recipe",
		name = "y-heat-pipe",
		ingredients = {
			{ type = "item", name = "copper-plate", amount = 5 },
			{ type = "item", name = "iron-plate", amount = 2 },
		},
		results = {
			{ type = "item", name = "y-heat-pipe", amount = 2 },
		},
		main_product = "y-heat-pipe",
		enabled = true,
		order = "p-g6",
		subgroup = "y_parts_e",
	},
	{
		type = "item",
		name = "y-heat-pipe",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/heat_pipe_icon.png",
		order = "p-g6",
		subgroup = "y_parts_e",
		stack_size = 100,
	},
})

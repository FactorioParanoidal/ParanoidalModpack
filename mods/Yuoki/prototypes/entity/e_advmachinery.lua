data:extend({

	--
	{
		type = "recipe",
		name = "y_crusher2",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/crusher33_icon.png",
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-crusher", amount = 1 },
			{ type = "item", name = "y_structure_element", amount = 3 },
			{ type = "item", name = "y-basic-t1-mf", amount = 2 },
			{ type = "item", name = "y-chip-1", amount = 2 },
		},
		results = {
			{ type = "item", name = "y_crusher2", amount = 1 },
			{ type = "item", name = "y_rwtechsign", amount = 1 },
		},
		main_product = "y_crusher2",
		subgroup = "y_line1",
	},

	{
		type = "item",
		name = "y_crusher2",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/crusher33_icon.png",
		group = "yuoki",
		subgroup = "y_line1",
		order = "c1",
		place_result = "y_crusher2",
		stack_size = 25,
	},

	{
		type = "assembling-machine",
		name = "y_crusher2",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/crusher33_icon.png",
		flags = { "placeable-neutral", "player-creation" },
		minable = { hardness = 0.5, mining_time = 1, result = "y_crusher2" },
		max_health = 200,
		resistances = { { type = "physical", percent = 50 } },
		collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
		selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
		graphics_set = {
			animation = {
				layers = {
					{
						filename = "__Yuoki__/graphics/entity/crusher33_sheet.png",
						priority = "medium",
						width = 128,
						height = 128,
						frame_count = 12,
						shift = { 0.5, 0 },
						animation_speed = 0.5,
					},
				},
			},
		},
		crafting_categories = { "y-crushing" },
		crafting_speed = 3.5,
		energy_source = {
			type = "electric",
			input_priority = "secondary",
			usage_priority = "secondary-input",
			emissions_per_minute = { pollution = 3.75 },
		},
		energy_usage = "250kW", --250wK
		ingredient_count = 4,
		fluid_boxes = {
			{
				volume = 200,
				production_type = "input",
				pipe_picture = assembler2pipepictures(),
				pipe_covers = pipecoverspictures(),
				base_area = 10,
				base_level = -1,
				pipe_connections = {
					{ flow_direction = "input", direction = defines.direction.north, position = { 0, -1 } },
				},
				secondary_draw_orders = { north = -1 },
			},
			{
				volume = 200,
				production_type = "output",
				pipe_picture = assembler2pipepictures(),
				pipe_covers = pipecoverspictures(),
				base_area = 10,
				base_level = 1,
				pipe_connections = {
					{ flow_direction = "output", direction = defines.direction.south, position = { 0, 1 } },
				},
				secondary_draw_orders = { north = -1 },
			},
		},
		fluid_boxes_off_when_no_fluid_recipe = true,

		module_slots = 2,
		allowed_effects = { "consumption", "speed", "productivity", "pollution" },
		quality_affects_module_slots = true,
		quality_affects_energy_usage = true,
		energy_usage_quality_multiplier = yi_energy_usage_quality_multiplier,
	},

	{
		type = "recipe",
		name = "y_formpress2",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/fpress2_icon.png",
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-heat-form-press", amount = 1 },
			{ type = "item", name = "y_structure_element", amount = 3 },
			{ type = "item", name = "y-basic-t1-mf", amount = 2 },
			{ type = "item", name = "y-chip-1", amount = 2 },
		},
		results = {
			{ type = "item", name = "y_formpress2", amount = 1 },
			{ type = "item", name = "y_rwtechsign", amount = 1 },
		},
		main_product = "y_formpress2",
		subgroup = "y_line1",
	},

	{
		type = "item",
		name = "y_formpress2",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/fpress2_icon.png",
		group = "yuoki",
		subgroup = "y_line1",
		order = "c1",
		place_result = "y_formpress2",
		stack_size = 25,
	},

	{
		type = "assembling-machine",
		name = "y_formpress2",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/fpress2_icon.png",
		flags = { "placeable-neutral", "player-creation" },
		minable = { hardness = 0.5, mining_time = 1, result = "y_formpress2" },
		max_health = 200,
		resistances = { { type = "physical", percent = 50 } },
		collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
		selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
		graphics_set = {
			animation = {
				layers = {
					{
						filename = "__Yuoki__/graphics/entity/npress_sheet.png",
						priority = "medium",
						width = 256,
						height = 256,
						frame_count = 36,
						line_length = 6,
						shift = { 0.5, -0.125 },
						animation_speed = 0.25,
						scale = 0.5,
					},
				},
			},
		},
		crafting_categories = { "yuoki-formpress" },
		crafting_speed = 3,
		energy_source = {
			type = "electric",
			input_priority = "secondary",
			usage_priority = "secondary-input",
			emissions_per_minute = { pollution = 4.8 },
		},
		energy_usage = "600kW",
		ingredient_count = 4,
		fluid_boxes = {
			{
				volume = 200,
				production_type = "input",
				pipe_picture = assembler2pipepictures(),
				pipe_covers = pipecoverspictures(),
				base_area = 10,
				base_level = -1,
				pipe_connections = {
					{ flow_direction = "input", direction = defines.direction.north, position = { 0, -1 } },
				},
				secondary_draw_orders = { north = -1 },
			},
			{
				volume = 200,
				production_type = "output",
				pipe_picture = assembler2pipepictures(),
				pipe_covers = pipecoverspictures(),
				base_area = 10,
				base_level = 1,
				pipe_connections = {
					{ flow_direction = "output", direction = defines.direction.south, position = { 0, 1 } },
				},
				secondary_draw_orders = { north = -1 },
			},
		},
		fluid_boxes_off_when_no_fluid_recipe = true,

		module_slots = 2,
		allowed_effects = { "consumption", "speed", "productivity", "pollution" },
		quality_affects_module_slots = true,
		quality_affects_energy_usage = true,
		energy_usage_quality_multiplier = yi_energy_usage_quality_multiplier,
	},

	--
	{
		type = "recipe",
		name = "y_maintance_workshop",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/maintance_workshop_icon.png",
		enabled = true,
		ingredients = {
			{ type = "item", name = "y_formpress2", amount = 1 },
			{ type = "item", name = "y-basic-t2-mf", amount = 2 },
			{ type = "item", name = "y-repair-krakon", amount = 4 },
			{ type = "item", name = "y-inserter-fast", amount = 2 },
		},
		results = {
			{ type = "item", name = "y_maintance_workshop", amount = 1 },
			{ type = "item", name = "y_rwtechsign", amount = 1 },
		},
		main_product = "y_maintance_workshop",
		subgroup = "y_line1",
	},

	{
		type = "item",
		name = "y_maintance_workshop",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/maintance_workshop_icon.png",
		group = "yuoki",
		subgroup = "y_line1",
		order = "c1",
		place_result = "y_maintance_workshop",
		stack_size = 25,
	},

	{
		type = "assembling-machine",
		name = "y_maintance_workshop",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/maintance_workshop_icon.png",
		flags = { "placeable-neutral", "player-creation" },
		minable = { hardness = 0.5, mining_time = 1, result = "y_maintance_workshop" },
		max_health = 200,
		resistances = { { type = "physical", percent = 50 } },
		collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
		selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
		graphics_set = {
			animation = {
				layers = {
					{
						filename = "__Yuoki__/graphics/entity/maintance_sheet.png",
						priority = "medium",
						width = 128,
						height = 128,
						frame_count = 16,
						line_length = 4,
						shift = { 0.5, 0 },
						animation_speed = 0.5,
					},
				},
			},
		},
		crafting_categories = { "yuoki-repair" },
		crafting_speed = 3,
		energy_source = {
			type = "electric",
			input_priority = "secondary",
			usage_priority = "secondary-input",
			emissions_per_minute = { pollution = 5 },
		},
		energy_usage = "500kW",
		ingredient_count = 4,
		fluid_boxes = {
			{
				volume = 200,
				production_type = "input",
				pipe_picture = assembler2pipepictures(),
				pipe_covers = pipecoverspictures(),
				base_area = 10,
				base_level = -1,
				pipe_connections = {
					{ flow_direction = "input", direction = defines.direction.north, position = { 0, -1 } },
				},
				secondary_draw_orders = { north = -1 },
			},
			{
				volume = 200,
				production_type = "output",
				pipe_picture = assembler2pipepictures(),
				pipe_covers = pipecoverspictures(),
				base_area = 10,
				base_level = 1,
				pipe_connections = {
					{ flow_direction = "output", direction = defines.direction.south, position = { 0, 1 } },
				},
				secondary_draw_orders = { north = -1 },
			},
		},
		fluid_boxes_off_when_no_fluid_recipe = true,

		module_slots = 2,
		allowed_effects = { "consumption", "speed", "pollution" },
	},
})

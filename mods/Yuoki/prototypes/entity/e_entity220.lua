data:extend({

	{
		type = "recipe",
		name = "y_chunks1",
		category = "yrcat_crystalize",
		enabled = true,
		energy_required = 8.00,
		ingredients = {
			{ type = "item", name = "y_crystal_dust", amount = 1.0 },
			{ type = "fluid", name = "steam", amount = 100.0 },
		},
		results = {
			{ type = "item", name = "y-res1", amount = 2.0 },
		},
		main_product = "y-res1",
		icon = "__Yuoki__/graphics/icons/uni-com-pur.png",
		icon_size = 64,
		order = "r",
		group = "yuoki",
		subgroup = "y_line2",
	},

	{
		type = "recipe",
		name = "y_chunks2",
		category = "yrcat_crystalize",
		enabled = true,
		energy_required = 8.00,
		ingredients = {
			{ type = "item", name = "y_crystal_dust", amount = 1.0 },
			{ type = "fluid", name = "steam", amount = 100.0 },
		},
		results = {
			{ type = "item", name = "y-res2", amount = 2.0 },
		},
		main_product = "y-res2",
		icon = "__Yuoki__/graphics/icons/yi-res-2-pur.png",
		icon_size = 64,
		order = "s",
		group = "yuoki",
		subgroup = "y_line2",
	},

	{
		type = "assembling-machine",
		name = "y_trockner",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/base_factory_icon.png",
		flags = { "placeable-neutral", "player-creation" },
		minable = { mining_time = 0.5, result = "y_trockner" },
		max_health = 400,
		resistances = { { type = "physical", percent = 50 } },
		collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
		selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
		graphics_set = {
			animation = {
				layers = {
					{
						filename = "__Yuoki__/graphics/entity/base_factory_sheet.png",
						priority = "medium",
						width = 256,
						height = 256,
						frame_count = 6,
						shift = { 0, 0 },
						scale = 0.5,
						animation_speed = 0.5,
					},
				},
			},
		},
		crafting_categories = { "yrcat_trockner" },
		crafting_speed = 1.0,
		energy_source = {
			type = "electric",
			input_priority = "secondary",
			usage_priority = "secondary-input",
			emissions_per_minute = { pollution = 3.75 },
		},
		energy_usage = "2000kW",
		ingredient_count = 5,
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
		},
		fluid_boxes_off_when_no_fluid_recipe = true,
		module_slots = 1,
		allowed_effects = { "consumption", "speed", "productivity", "pollution" },
	},

	{
		type = "assembling-machine",
		name = "y_mixer_emu",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/base_factory_icon.png",
		flags = { "placeable-neutral", "player-creation" },
		minable = { mining_time = 0.5, result = "y_mixer_emu" },
		max_health = 400,
		resistances = { { type = "physical", percent = 50 } },
		collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
		selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
		graphics_set = {
			animation = {
				layers = {
					{
						filename = "__Yuoki__/graphics/entity/water_mixer_sheet.png",
						priority = "medium",
						width = 256,
						height = 256,
						frame_count = 16,
						line_length = 4,
						shift = { 0.5, -0.5 },
						scale = 0.5,
						animation_speed = 0.5,
					},
				},
			},
		},
		crafting_categories = { "yrcat_emulsion" },
		crafting_speed = 1.0,
		energy_source = {
			type = "electric",
			input_priority = "secondary",
			usage_priority = "secondary-input",
			emissions_per_minute = { pollution = 3.75 },
		},
		energy_usage = "750kW",
		ingredient_count = 5,
		fluid_boxes = {
			{
				volume = 200,
				production_type = "input",
				--pipe_picture = assembler2pipepictures(),
				--pipe_covers = pipecoverspictures(),
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
				--pipe_picture = assembler2pipepictures(),
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
		module_slots = 1,
		allowed_effects = { "consumption", "speed", "productivity", "pollution" },
	},

	{
		type = "assembling-machine",
		name = "y_crystalizer",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/crys_icon.png",
		flags = { "placeable-neutral", "player-creation" },
		minable = { mining_time = 0.5, result = "y_crystalizer" },
		max_health = 400,
		resistances = { { type = "physical", percent = 50 } },
		collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
		selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
		graphics_set = {
			animation = {
				layers = {
					{
						filename = "__Yuoki__/graphics/entity/crys.png",
						priority = "medium",
						width = 256,
						height = 256,
						frame_count = 1,
						shift = { 0.5, -0.25 },
						scale = 0.5,
						animation_speed = 0.5,
					},
				},
			},
		},

		crafting_categories = { "yrcat_crystalize" },
		crafting_speed = 1.0,
		energy_source = {
			type = "electric",
			input_priority = "secondary",
			usage_priority = "secondary-input",
			emissions_per_minute = { pollution = 10 },
		},
		energy_usage = "2000kW",
		ingredient_count = 5,
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
		},
		fluid_boxes_off_when_no_fluid_recipe = true,
		module_slots = 1,
		allowed_effects = { "consumption", "speed", "productivity", "pollution" },
	},

	{
		type = "assembling-machine",
		name = "y_hppump",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/hppump_icon.png",
		flags = { "placeable-neutral", "player-creation" },
		minable = { mining_time = 0.5, result = "y_hppump" },
		max_health = 400,
		resistances = { { type = "physical", percent = 50 } },
		collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
		selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
		graphics_set = {
			animation = {
				north = {
					layers = {
						{
							filename = "__Yuoki__/graphics/entity/hppump_n.png",
							priority = "medium",
							width = 320,
							height = 320,
							frame_count = 1,
							shift = { 0, 0 },
							scale = 0.5,
							animation_speed = 0.5,
						},
					},
				},
				east = {
					layers = {
						{
							filename = "__Yuoki__/graphics/entity/hppump_e.png",
							priority = "medium",
							width = 320,
							height = 320,
							frame_count = 1,
							shift = { 0, 0 },
							scale = 0.5,
							animation_speed = 0.5,
						},
					},
				},
				south = {
					layers = {
						{
							filename = "__Yuoki__/graphics/entity/hppump_s.png",
							priority = "medium",
							width = 320,
							height = 320,
							frame_count = 1,
							shift = { 0, 0 },
							scale = 0.5,
							animation_speed = 0.5,
						},
					},
				},
				west = {
					layers = {
						{
							filename = "__Yuoki__/graphics/entity/hppump_w.png",
							priority = "medium",
							width = 320,
							height = 320,
							frame_count = 1,
							shift = { 0, 0 },
							scale = 0.5,
							animation_speed = 0.5,
						},
					},
				},
			},
		},
		crafting_categories = { "yrcat_hppump" },
		crafting_speed = 1.0,
		energy_source = {
			type = "electric",
			input_priority = "secondary",
			usage_priority = "secondary-input",
			emissions_per_minute = { pollution = 2.5 },
		},
		energy_usage = "500kW",
		ingredient_count = 5,

		fluid_boxes = {
			{
				volume = 200,
				production_type = "input",
				--pipe_picture = assembler2pipepictures(),
				pipe_covers = pipecoverspictures(),
				base_area = 10,
				base_level = -1,
				pipe_connections = {
					{ flow_direction = "input", direction = defines.direction.south, position = { 0, 1 } },
				},
				secondary_draw_orders = { north = -1 },
			},
			{
				volume = 200,
				production_type = "output",
				--pipe_picture = assembler3pipepictures(),
				pipe_covers = pipecoverspictures(),
				base_area = 10,
				base_level = 1,
				pipe_connections = {
					{ flow_direction = "output", direction = defines.direction.west, position = { -1, 0 } },
					{ flow_direction = "output", direction = defines.direction.east, position = { 1, 0 } },
				},

				secondary_draw_orders = { north = -1 },
			},
		},
		fluid_boxes_off_when_no_fluid_recipe = true,
		mmodule_slots = 1,
		allowed_effects = { "consumption", "speed", "productivity", "pollution" },
	},

	--[[ disabled because it depends on y-valve-direction-buffer,
	     whose recipe/item/prototype family is commented out
	-- MF-Tank
	{
		type = "recipe",
		name = "y_mftank",
		energy_required = 3.0,
		enabled = true,
		ingredients = {
			{ type = "item", name = "y-valve-direction-buffer", amount = 4 },
			{ type = "item", name = "iron-plate", amount = 12 },
		},
		results = {
			{ type = "item", name = "y_mftank", amount = 1 },
		},
		main_product = "y_mftank",
		order = "tank-c5",
		subgroup = "y-fluid-storage",
	},
	]]
	{
		type = "item",
		name = "y_mftank",
		place_result = "y_mftank",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/store/mftank_ico.png",
		group = "yuoki",
		subgroup = "y-fluid-storage",
		stack_size = 15,
		default_request = 5,
		order = "tank-c5",
	},
	{
		type = "storage-tank",
		name = "y_mftank",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/store/mftank_ico.png",
		flags = { "placeable-player", "player-creation" },
		minable = { mining_time = 0.5, result = "y_mftank" },
		max_health = 500,
		corpse = "small-remnants",
		collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
		selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },

		fluid_box = {
			volume = 2000,
			--pipe_covers = pipecoverspictures(),
			pipe_connections = {
				{ flow_direction = "input-output", direction = defines.direction.north, position = { 0, -1 } },
				{ flow_direction = "input-output", direction = defines.direction.east, position = { 1, 0 } },
				{ flow_direction = "input-output", direction = defines.direction.south, position = { 0, 1 } },
				{ flow_direction = "input-output", direction = defines.direction.west, position = { -1, 0 } },
			},
			---hide_connection_info = true,
		},

		two_direction_only = false,
		window_bounding_box = { { -0.05, -0.5 }, { 0.05, 0.0 } },
		pictures = {
			picture = {
				sheet = {
					filename = "__Yuoki__/graphics/entity/store/mftank.png",
					priority = "high",
					frames = 1,
					width = 320,
					height = 320,
					scale = 0.5,
					shift = { 0, 0 },
				},
			},
			fluid_background = {
				filename = "__base__/graphics/entity/storage-tank/fluid-background.png",
				priority = "extra-high",
				width = 16,
				height = 15,
			},
			window_background = {
				filename = "__base__/graphics/entity/storage-tank/window-background.png",
				priority = "extra-high",
				width = 17,
				height = 24,
			},
			flow_sprite = {
				filename = "__base__/graphics/entity/pipe/fluid-flow-low-temperature.png",
				priority = "extra-high",
				width = 160,
				height = 20,
			},
			gas_flow = {
				filename = "__base__/graphics/entity/pipe/steam.png",
				priority = "extra-high",
				line_length = 10,
				width = 24,
				height = 15,
				frame_count = 60,
				axially_symmetrical = false,
				direction_count = 1,
				animation_speed = 0.25,
				hr_version = {
					filename = "__base__/graphics/entity/pipe/hr-steam.png",
					priority = "extra-high",
					line_length = 10,
					width = 48,
					height = 30,
					frame_count = 60,
					axially_symmetrical = false,
					animation_speed = 0.25,
					direction_count = 1,
				},
			},
		},
		flow_length_in_ticks = 360,
		circuit_wire_connection_points = {
			{
				shadow = {
					red = { -0.55, -0.15 },
					green = { -0.75, -0.15 },
				},
				wire = {
					red = { -0.55, -0.15 },
					green = { -0.75, -0.15 },
				},
			},
			{
				shadow = {
					red = { -0.55, -0.15 },
					green = { -0.75, -0.15 },
				},
				wire = {
					red = { -0.55, -0.15 },
					green = { -0.75, -0.15 },
				},
			},
			{
				shadow = {
					red = { -0.55, -0.15 },
					green = { -0.75, -0.15 },
				},
				wire = {
					red = { -0.55, -0.15 },
					green = { -0.75, -0.15 },
				},
			},
			{
				shadow = {
					red = { -0.55, -0.15 },
					green = { -0.75, -0.15 },
				},
				wire = {
					red = { -0.55, -0.15 },
					green = { -0.75, -0.15 },
				},
			},
		},
		circuit_wire_max_distance = 15,
		circuit_wire_connection_points = circuit_connector_definitions["storage-tank"].points,
		circuit_connector_sprites = circuit_connector_definitions["storage-tank"].sprites,
	},
})

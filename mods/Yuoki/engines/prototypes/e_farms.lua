data:extend({

	-- farming
	{
		type = "assembling-machine",
		name = "ye_farm",
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/entity/farm-icon.png",
		flags = { "placeable-neutral", "placeable-player", "player-creation" },
		minable = { hardness = 0.2, mining_time = 0.5, result = "ye_farm" },
		max_health = 250,
		corpse = "medium-remnants",
		fluid_boxes = {

			{
				volume = 200,
				production_type = "input",
				base_area = 5,
				base_level = -1,
				pipe_connections = {
					{ flow_direction = "input", direction = defines.direction.north, position = { 2, -1.9 } },
				},
			},
			{
				volume = 200,
				production_type = "input",
				base_area = 5,
				base_level = -1,
				pipe_connections = {
					{ flow_direction = "input", direction = defines.direction.south, position = { -2, 2 } },
				},
			},
		},
		fluid_boxes_off_when_no_fluid_recipe = true,
		collision_box = { { -2.2, -2.2 }, { 2.2, 2.2 } },
		selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
		fast_replaceable_group = "assembling-machine",
		graphics_set = {
			animation = {
				north = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/farm-sheet-ns.png",
							width = 192,
							height = 192,
							shift = { 0.44, -0.22 },
							frame_count = 16,
							line_length = 4,
							animation_speed = 0.01,
						},
					},
				},
				east = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/farm-sheet-ew.png",
							width = 192,
							height = 192,
							shift = { 0.19, -0.34 },
							frame_count = 16,
							line_length = 4,
							animation_speed = 0.01,
						},
					},
				},
				south = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/farm-sheet-ns.png",
							width = 192,
							height = 192,
							shift = { 0.44, -0.22 },
							frame_count = 16,
							line_length = 4,
							animation_speed = 0.01,
						},
					},
				},
				west = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/farm-sheet-ew.png",
							width = 192,
							height = 192,
							shift = { 0.19, -0.34 },
							frame_count = 16,
							line_length = 4,
							animation_speed = 0.01,
						},
					},
				},
			},
		},
		crafting_categories = { "yrcat-farm" },
		crafting_speed = 1.0,

		energy_source = {
			type = "electric",
			usage_priority = "secondary-input",
			emissions_per_minute = { pollution = 5 },
		},
		energy_usage = "50kW",
		ingredient_count = 3,
		order = "a",
		subgroup = "yie-engines",
		module_slots = 2,
		allowed_effects = { "consumption", "speed", "productivity", "pollution" },
	},

	-- alien breed
	{
		type = "assembling-machine",
		name = "ye_meatfarm",
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/entity/cage_empty_icon.png",
		flags = { "placeable-neutral", "placeable-player", "player-creation" },
		minable = { hardness = 0.2, mining_time = 0.5, result = "ye_meatfarm" },
		max_health = 250,
		corpse = "medium-remnants",
		fluid_boxes = {

			{
				volume = 200,
				production_type = "output",
				base_area = 5,
				base_level = 1,
				pipe_connections = {
					{ flow_direction = "output", direction = defines.direction.south, position = { 1, 2 } },
				},
			},
			{
				volume = 200,
				production_type = "output",
				base_area = 5,
				base_level = 1,
				pipe_connections = {
					{ flow_direction = "output", direction = defines.direction.south, position = { -1, 2 } },
				},
			},
			{
				volume = 200,
				production_type = "input",
				base_area = 5,
				base_level = -1,
				pipe_connections = {
					{ flow_direction = "input", direction = defines.direction.north, position = { 1, -2 } },
				},
			},
			{
				volume = 200,
				production_type = "input",
				base_area = 5,
				base_level = -1,
				pipe_connections = {
					{ flow_direction = "input", direction = defines.direction.north, position = { -1, -2 } },
				},
			},
		},
		fluid_boxes_off_when_no_fluid_recipe = true,
		collision_box = { { -2.2, -2.2 }, { 2.2, 2.2 } },
		selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
		fast_replaceable_group = "assembling-machine",
		graphics_set = {
			animation = {
				north = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/cage/cage_v14.png",
							width = 192,
							height = 192,
							shift = { 0.375, -0.125 },
							frame_count = 36,
							line_length = 9,
							animation_speed = 0.25,
						},
					},
				},
				east = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/cage/cage_h14.png",
							width = 192,
							height = 192,
							shift = { 0.125, -0.5 },
							frame_count = 36,
							line_length = 9,
							animation_speed = 0.25,
						},
					},
				},
				south = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/cage/cage_v14.png",
							width = 192,
							height = 192,
							shift = { 0.375, -0.125 },
							frame_count = 36,
							line_length = 9,
							animation_speed = 0.25,
						},
					},
				},
				west = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/cage/cage_h14.png",
							width = 192,
							height = 192,
							shift = { 0.125, -0.5 },
							frame_count = 36,
							line_length = 9,
							animation_speed = 0.25,
						},
					},
				},
			},
		},
		crafting_categories = { "yrcat_meat" },
		crafting_speed = 1.0,

		energy_source = {
			type = "electric",
			usage_priority = "secondary-input",
			emissions_per_minute = { pollution = 25 },
		},
		energy_usage = "250kW",
		ingredient_count = 4,
		order = "a",
		subgroup = "yie-engines",

		module_slots = 2,
		allowed_effects = { "consumption", "speed", "productivity", "pollution" },
	},

	-- fishing
	{
		type = "assembling-machine",
		name = "ye_pool",
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/entity/pool_icon.png",
		flags = { "placeable-neutral", "placeable-player", "player-creation" },
		minable = { hardness = 0.2, mining_time = 0.5, result = "ye_pool" },
		max_health = 250,
		corpse = "medium-remnants",
		fluid_boxes = {

			{
				volume = 200,
				production_type = "input",
				base_area = 5,
				base_level = -1,
				pipe_connections = {
					{ flow_direction = "input", direction = defines.direction.north, position = { -1, -2 } },
				},
			},
			{
				volume = 200,
				production_type = "output",
				base_area = 5,
				base_level = 1,
				pipe_connections = {
					{ flow_direction = "output", direction = defines.direction.north, position = { 1, -2 } },
				},
			},
			{
				volume = 200,
				production_type = "input",
				base_area = 5,
				base_level = -1,
				pipe_connections = {
					{ flow_direction = "input", direction = defines.direction.south, position = { 0, 2 } },
				},
			},
		},
		fluid_boxes_off_when_no_fluid_recipe = true,
		collision_box = { { -2.2, -2.2 }, { 2.2, 2.2 } },
		selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
		fast_replaceable_group = "assembling-machine",

		graphics_set = {
			animation = {
				north = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/pool_sn_sheet.png",
							width = 384,
							height = 384,
							shift = { 0.44, -0.22 },
							frame_count = 9,
							line_length = 3,
							animation_speed = 0.05,
							scale = 0.5,
						},
					},
				},
				east = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/pool_we_sheet.png",
							width = 384,
							height = 384,
							shift = { 0.19, -0.34 },
							frame_count = 9,
							line_length = 3,
							animation_speed = 0.05,
							scale = 0.5,
						},
					},
				},
				south = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/pool_ns_sheet.png",
							width = 384,
							height = 384,
							shift = { 0.44, -0.22 },
							frame_count = 9,
							line_length = 3,
							animation_speed = 0.05,
							scale = 0.5,
						},
					},
				},
				west = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/pool_ew_sheet.png",
							width = 384,
							height = 384,
							shift = { 0.19, -0.34 },
							frame_count = 9,
							line_length = 3,
							animation_speed = 0.05,
							scale = 0.5,
						},
					},
				},
			},
		},
		crafting_categories = { "yrcat-fish" },
		crafting_speed = 1.0,

		energy_source = {
			type = "electric",
			usage_priority = "secondary-input",
			emissions_per_minute = { pollution = 5 },
		},
		energy_usage = "50kW",
		ingredient_count = 3,
		order = "a",
		subgroup = "yie-engines",
		module_slots = 2,
		allowed_effects = { "consumption", "speed", "productivity", "pollution" },
	},

	-- ice-machine
	{
		type = "assembling-machine",
		name = "ye_icemaker",
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/entity/icemaker_icon.png",
		flags = { "placeable-neutral", "placeable-player", "player-creation" },
		minable = { hardness = 0.2, mining_time = 0.5, result = "ye_icemaker" },
		max_health = 450,
		corpse = "medium-remnants",
		fluid_boxes = {

			{
				volume = 200,
				production_type = "input",
				base_area = 5,
				base_level = -1,
				pipe_connections = {
					{ flow_direction = "input", direction = defines.direction.north, position = { -1, -1 } },
				},
			},
			{
				volume = 200,
				production_type = "input",
				base_area = 5,
				base_level = -1,
				pipe_connections = {
					{ flow_direction = "input", direction = defines.direction.north, position = { 1, -1 } },
				},
			},
			{
				volume = 200,
				production_type = "input",
				base_area = 5,
				base_level = -1,
				pipe_connections = {
					{ flow_direction = "input", direction = defines.direction.south, position = { -1, 1 } },
				},
			},
		},
		fluid_boxes_off_when_no_fluid_recipe = true,
		collision_box = { { -1.3, -1.3 }, { 1.3, 1.3 } },
		selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
		fast_replaceable_group = "assembling-machine",
		graphics_set = {
			animation = {
				layers = {
					{
						filename = "__Yuoki__/engines/graphics/entity/refrig_v2_sheet.png",
						width = 256,
						height = 256,
						shift = { 0.3, -0.12 },
						frame_count = 25,
						line_length = 5,
						animation_speed = 0.5,
						scale = 0.5,
					},
				},
			},
		},
		crafting_categories = { "yrcat_icemaker" },
		crafting_speed = 1.5,

		energy_source = {
			type = "electric",
			usage_priority = "secondary-input",
			emissions_per_minute = { pollution = 30 },
		},
		energy_usage = "1500kW",
		ingredient_count = 4,
		order = "a",
		subgroup = "yie_machinery2",
	},

	-- Smoker
	{
		type = "assembling-machine",
		name = "ye_smoker",
		icon_size = 32,
		icon = "__Yuoki__/engines/graphics/entity/yie_smoker_icon.png",
		flags = { "placeable-neutral", "placeable-player", "player-creation" },
		minable = { hardness = 0.2, mining_time = 0.5, result = "ye_smoker" },
		max_health = 250,
		corpse = "big-remnants",
		resistances = { { type = "physical", percent = 60 } },
		collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
		selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
		fast_replaceable_group = "assembling-machine",
		graphics_set = {
			animation = {
				layers = {
					{
						filename = "__Yuoki__/engines/graphics/entity/yie_smoker.png",
						width = 320,
						height = 320,
						shift = { 0.875, 0 },
						frame_count = 1,
						animation_speed = 1,
						scale = 0.5,
					},
				},
			},
		},
		crafting_categories = { "yrcat_smoker" },
		crafting_speed = 1,
		energy_source = {
			--type = "electric",
			--usage_priority = "secondary-input",
			--emissions = 0.04 / 2.5
			type = "burner",
			effectivity = 0.8,
			fuel_inventory_size = 2,
			emissions_per_minute = { pollution = 17.6 },
			smoke = {
				{ name = "smoke", position = { -0.75, -1.25 }, height = 1, deviation = { 0.1, 0.1 }, frequency = 75 },
			},
		},
		energy_usage = "1100kW",
		ingredient_count = 6,
		module_specification = {
			module_slots = 2,
		},
		allowed_effects = { "consumption", "speed", "productivity", "pollution" },
		order = "a[atomics]",
		subgroup = "yie_agromachinery",
	},

	{
		type = "assembling-machine",
		name = "ye_dnasplicer",
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/entity/dna_splicer_icon.png",
		flags = { "placeable-neutral", "placeable-player", "player-creation" },
		minable = { hardness = 0.2, mining_time = 0.5, result = "ye_dnasplicer" },
		max_health = 250,
		corpse = "big-remnants",
		resistances = { { type = "physical", percent = 60 } },
		collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
		selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
		fast_replaceable_group = "assembling-machine",

		fluid_boxes = {
			{
				volume = 200,
				production_type = "input",
				base_area = 5,
				base_level = -1,
				pipe_connections = {
					{ flow_direction = "input", direction = defines.direction.north, position = { 0, -1 } },
				},
			},
			{
				volume = 200,
				production_type = "input",
				base_area = 5,
				base_level = -1,
				pipe_connections = {
					{ flow_direction = "input", direction = defines.direction.east, position = { 1, 0 } },
				},
			},
			{
				volume = 200,
				production_type = "output",
				base_area = 5,
				base_level = -1,
				pipe_connections = {
					{ flow_direction = "output", direction = defines.direction.south, position = { 0, 1 } },
				},
			},
		},
		fluid_boxes_off_when_no_fluid_recipe = true,
		graphics_set = {
			animation = {
				layers = {
					{
						filename = "__Yuoki__/engines/graphics/entity/dna_splicer_sheet.png",
						width = 256,
						height = 256,
						shift = { 0.5, -0.5 },
						frame_count = 16,
						line_length = 4,
						animation_speed = 0.25,
						scale = 0.5,
					},
				},
			},
		},
		crafting_categories = { "yrcat_dna" },
		crafting_speed = 5.0,
		energy_source = {
			type = "electric",
			usage_priority = "secondary-input",
			emissions_per_minute = { pollution = 8 },
		},
		energy_usage = "800kW",
		ingredient_count = 6,
		module_specification = { module_slots = 2 },
		allowed_effects = { "consumption", "speed", "productivity", "pollution" },
		order = "a[atomics]",
		subgroup = "yie_agromachinery",
	},
})

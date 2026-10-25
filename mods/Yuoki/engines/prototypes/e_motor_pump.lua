data:extend({

	-- E-Motor Small
	{
		type = "assembling-machine",
		name = "y-emotor-s",
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/entity/e-motor-icon.png",
		flags = { "placeable-neutral", "placeable-player", "player-creation" },
		minable = { mining_time = 0.5, result = "y-emotor-s" },
		max_health = 150,
		corpse = "medium-remnants",
		--resistances = {{type = "physical",percent = 60},},
		fluid_boxes = {
			{
				volume = 200,
				production_type = "output",
				base_area = 1,
				base_level = 1,
				pipe_connections = {
					{ flow_direction = "output", direction = defines.direction.north, position = { 0.5, -0.5 } },
				},
			},
		},
		collision_box = { { -0.5, -0.7 }, { 0.7, 0.7 } },
		selection_box = { { -1.0, -1.0 }, { 1.0, 1.0 } },

		graphics_set = {
			animation = {
				north = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/e-motor-n.png",
							width = 96,
							height = 96,
							shift = { 0.5, -0.03 },
							frame_count = 1,
							line_length = 1,
						},
					},
				},
				east = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/e-motor-e.png",
							width = 96,
							height = 96,
							shift = { -0.09, 0.53 },
							frame_count = 1,
							line_length = 1,
						},
					},
				},
				south = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/e-motor-s.png",
							width = 96,
							height = 96,
							shift = { -0.5, 0.13 },
							frame_count = 1,
							line_length = 1,
						},
					},
				},
				west = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/e-motor-w.png",
							width = 96,
							height = 96,
							shift = { 0.13, -0.47 },
							frame_count = 1,
							line_length = 1,
						},
					},
				},
			},
		},
		crafting_categories = { "yrcat-mf1c" },
		crafting_speed = 1,

		module_specification = { module_slots = 0 },
		allowed_effects = { "speed", "pollution" },

		energy_source = {
			type = "electric",
			usage_priority = "secondary-input",
			emissions_per_minute = { pollution = 3.5 },
		},
		energy_usage = "350kW",
		ingredient_count = 1,
		order = "a",
		subgroup = "yie-engines",
	},

	-- E-Motor Medium
	{
		type = "assembling-machine",
		name = "ye_emotor_m",
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/entity/e-motor-m_icon.png",
		flags = { "placeable-neutral", "placeable-player", "player-creation" },
		minable = { mining_time = 0.5, result = "ye_emotor_m" },
		max_health = 150,
		corpse = "medium-remnants",
		--resistances = {{type = "physical",percent = 60},},
		fluid_boxes = {
			{
				volume = 200,
				production_type = "output",
				base_area = 1,
				base_level = 1,
				pipe_connections = {
					{ flow_direction = "output", direction = defines.direction.north, position = { 0, -1 } },
					{ flow_direction = "output", direction = defines.direction.south, position = { 0, 1 } },
				},
			},
		},
		collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
		selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },

		graphics_set = {
			animation = {
				north = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/emotor-m_ns.png",
							width = 256,
							height = 256,
							shift = { 0.5, -0.375 },
							frame_count = 4,
							line_length = 2,
							scale = 0.5,
							animation_speed = 0.25,
						},
					},
				},
				east = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/emotor-m_we.png",
							width = 256,
							height = 256,
							shift = { 0.5, 0 },
							frame_count = 4,
							line_length = 2,
							scale = 0.5,
							animation_speed = 0.25,
						},
					},
				},
				south = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/emotor-m_ns.png",
							width = 256,
							height = 256,
							shift = { 0.5, -0.375 },
							frame_count = 4,
							line_length = 2,
							scale = 0.5,
							animation_speed = 0.25,
						},
					},
				},
				west = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/emotor-m_we.png",
							width = 256,
							height = 256,
							shift = { 0.5, 0 },
							frame_count = 4,
							line_length = 2,
							scale = 0.5,
							animation_speed = 0.25,
						},
					},
				},
			},
		},
		crafting_categories = { "yrcat_motor" },
		crafting_speed = 1,

		module_specification = { module_slots = 0 },
		allowed_effects = { "speed", "pollution" },

		energy_source = {
			type = "electric",
			usage_priority = "secondary-input",
			emissions_per_minute = { pollution = 3.5 },
		},
		energy_usage = "350kW",
		ingredient_count = 1,
		order = "a",
		subgroup = "yie-engines",
	},

	-- mechanical water pump - small
	{
		type = "assembling-machine",
		name = "y-mwater-pump",
		icon_size = 32,
		icon = "__Yuoki__/engines/graphics/entity/pump-icon.png",
		flags = { "placeable-neutral", "placeable-player", "player-creation" },
		minable = { hardness = 0.2, mining_time = 0.5, result = "y-mwater-pump" },
		max_health = 250,
		corpse = "medium-remnants",
		--resistances = {{type = "physical",percent = 60},},
		fluid_boxes = {
			{
				volume = 200,
				production_type = "output",
				base_area = 1,
				base_level = 1,
				pipe_connections = {
					{ flow_direction = "output", direction = defines.direction.east, position = { 0.5, 0.5 } },
				},
			},
			{
				volume = 200,
				production_type = "input",
				base_area = 5,
				base_level = -1,
				pipe_connections = {
					{ flow_direction = "input", direction = defines.direction.north, position = { -0.5, -0.5 } },
				},
			},
		},
		collision_box = { { -0.8, -0.8 }, { 0.8, 0.8 } },
		selection_box = { { -1.0, -1.0 }, { 1.0, 1.0 } },
		fast_replaceable_group = "assembling-machine",
		graphics_set = {
			animation = {
				north = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/pump_nna_s.png",
							width = 128,
							height = 128,
							shift = { 0.34, 0.53 },
							frame_count = 16,
							line_length = 16,
						},
					},
				},
				east = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/pump_ena_s.png",
							width = 128,
							height = 128,
							shift = { 0.28, 0.31 },
							frame_count = 16,
							line_length = 16,
						},
					},
				},
				south = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/pump_sna_s.png",
							width = 128,
							height = 128,
							shift = { 0.47, 0.22 },
							frame_count = 16,
							line_length = 16,
						},
					},
				},
				west = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/pump_wna_s.png",
							width = 128,
							height = 128,
							shift = { 0.47, 0.47 },
							frame_count = 16,
							line_length = 16,
						},
					},
				},
			},
		},
		crafting_categories = { "yrcat-pump" },
		crafting_speed = 1.0,

		energy_source = {
			type = "electric",
			usage_priority = "secondary-input",
			emissions_per_minute = { pollution = 0.01 },
		},
		energy_usage = "100W",
		ingredient_count = 1,
		order = "a",
		subgroup = "yie-engines",
	},

	-- mechanical water pump - medium
	{
		type = "assembling-machine",
		name = "ye_wpump_m",
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/entity/e-motor-m_icon.png",
		flags = { "placeable-neutral", "placeable-player", "player-creation" },
		minable = { hardness = 0.2, mining_time = 0.5, result = "ye_wpump_m" },
		max_health = 250,
		corpse = "medium-remnants",
		--resistances = {{type = "physical",percent = 60},},
		fluid_boxes = {
			{
				volume = 200,
				production_type = "output",
				base_area = 2,
				base_level = 1,
				pipe_connections = {
					{ flow_direction = "output", direction = defines.direction.east, position = { 1, 0 } },
					{ flow_direction = "output", direction = defines.direction.west, position = { -1, 0 } },
					{ flow_direction = "output", direction = defines.direction.south, position = { 0, 1 } },
				},
			},
			{
				volume = 200,
				production_type = "input",
				base_area = 2,
				base_level = -1,
				pipe_connections = {
					{ flow_direction = "input", direction = defines.direction.north, position = { 0, -1 } },
				},
			},
		},
		collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
		selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
		graphics_set = {
			animation = {
				north = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/pump3x3_s.png",
							width = 256,
							height = 256,
							shift = { 0.5, 0 },
							frame_count = 16,
							line_length = 4,
							scale = 0.5,
							animation_speed = 0.5,
						},
					},
				},
				east = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/pump3x3_w.png",
							width = 256,
							height = 256,
							shift = { 0.5, 0 },
							frame_count = 16,
							line_length = 4,
							scale = 0.5,
							animation_speed = 0.5,
						},
					},
				},
				south = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/pump3x3_s.png",
							width = 256,
							height = 256,
							shift = { 0.5, 0 },
							frame_count = 16,
							line_length = 4,
							scale = 0.5,
							animation_speed = 0.5,
						},
					},
				},
				west = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/pump3x3_w.png",
							width = 256,
							height = 256,
							shift = { 0.5, 0 },
							frame_count = 16,
							line_length = 4,
							scale = 0.5,
							animation_speed = 0.5,
						},
					},
				},
			},
		},
		crafting_categories = { "yrcat_pump_2" },
		crafting_speed = 4,

		energy_source = {
			type = "electric",
			usage_priority = "secondary-input",
			emissions_per_minute = { pollution = 0.5 },
		},
		energy_usage = "50kW",
		ingredient_count = 1,
		order = "a",
		subgroup = "yie-engines",
	},
})

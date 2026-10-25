data:extend({

	-- overheater
	{
		type = "assembling-machine",
		name = "ye_overheater",
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/entity/heater55_icon.png",
		flags = { "placeable-neutral", "placeable-player", "player-creation" },
		minable = { hardness = 0.2, mining_time = 0.5, result = "ye_overheater" },
		max_health = 150,
		corpse = "medium-remnants",
		fluid_boxes = {
			{
				volume = 200,
				production_type = "input",
				base_area = 3,
				base_level = -1,
				pipe_connections = {
					{ flow_direction = "input", direction = defines.direction.north, position = { 0, -2 } },
				},
			},
			{
				volume = 200,
				production_type = "output",
				base_area = 48,
				base_level = 1,
				pipe_connections = {
					{ flow_direction = "output", direction = defines.direction.west, position = { -2, 0 } },
					--{type="output", position = { -3, 1}},
					{ flow_direction = "output", direction = defines.direction.west, position = { -2, 2 } },
					--{type="output", position = { -3, 3}},
					{ flow_direction = "output", direction = defines.direction.east, position = { 2, 0 } },
					--{type="output", position = {  3, 1}},
					{ flow_direction = "output", direction = defines.direction.east, position = { 2, 2 } },
					--{type="output", position = {  3, 3}},
				},
			},
		},
		collision_box = { { -2.3, -2.3 }, { 2.3, 2.3 } },
		selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
		--fast_replaceable_group = "assembling-machine",

		graphics_set = {
			animation = {
				north = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/heater55_s.png",
							width = 384,
							height = 384,
							shift = { 0.5, 0.5 },
							frame_count = 1,
							line_length = 1,
							animation_speed = 0.8,
							scale = 0.5,
						},
					},
				},
				east = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/heater55_e.png",
							width = 384,
							height = 384,
							shift = { 0.5, -0.5 },
							frame_count = 1,
							line_length = 1,
							animation_speed = 0.8,
							scale = 0.5,
						},
					},
				},
				south = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/heater55_n.png",
							width = 384,
							height = 384,
							shift = { 0.5, -0.5 },
							frame_count = 1,
							line_length = 1,
							animation_speed = 0.8,
							scale = 0.5,
						},
					},
				},
				west = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/heater55_w.png",
							width = 384,
							height = 384,
							shift = { 0.5, -0.5 },
							frame_count = 1,
							line_length = 1,
							animation_speed = 0.8,
							scale = 0.5,
						},
					},
				},
			},
		},
		crafting_categories = { "yrcat-heater" },
		crafting_speed = 1.0,
		energy_source = {
			type = "burner",
			fuel_categories = { "chemical" },
			effectivity = 0.8,
			fuel_inventory_size = 2,
			emissions_per_minute = { pollution = 448 },
		},
		energy_usage = "28MW",
		--[[
		energy_source = {
			type = "electric",
			usage_priority = "primary-input",
			emissions = 0.00025,
		},
		energy_usage = "5MW",
		]]
		ingredient_count = 1,
		order = "a",
		subgroup = "yie-engines",
	},

	-- s-turbine
	{
		type = "assembling-machine",
		name = "ye_sturbine",
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/entity/energy2/turbine_icon.png",
		flags = { "placeable-neutral", "placeable-player", "player-creation" },
		minable = { mining_time = 0.2, result = "ye_sturbine" },
		max_health = 150,
		corpse = "medium-remnants",
		fluid_boxes = {
			{
				volume = 200,
				production_type = "input",
				base_area = 3,
				base_level = -1,
				pipe_connections = {
					{ flow_direction = "input", direction = defines.direction.north, position = { -1, -3 } },
					--{type="input", position = { -2, -4}},
					{ flow_direction = "input", direction = defines.direction.north, position = { -3, -3 } },
					{ flow_direction = "input", direction = defines.direction.north, position = { 1, -3 } },
					--{type="input", position = { 2, -4}},
					{ flow_direction = "input", direction = defines.direction.north, position = { 3, -3 } },
					--{type="input", position = {-2, 0}},
				},
			},
			-- mf
			{
				volume = 200,
				production_type = "output",
				base_area = 3,
				base_level = 1,
				pipe_connections = {
					{ flow_direction = "output", direction = defines.direction.south, position = { 0, 3 } },
				},
			},
			-- water
			{
				volume = 200,
				production_type = "output",
				base_area = 3,
				base_level = 1,
				pipe_connections = {
					{ flow_direction = "output", direction = defines.direction.east, position = { 3, 2 } },
					{ flow_direction = "output", direction = defines.direction.west, position = { -3, 2 } },
				},
			},
		},
		collision_box = { { -3.3, -3.3 }, { 3.3, 3.3 } },
		selection_box = { { -3.5, -3.5 }, { 3.5, 3.5 } },
		--fast_replaceable_group = "assembling-machine",
		graphics_set = {
			animation = {
				north = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/energy2/turbine_n.png",
							width = 256,
							height = 256,
							shift = { 0.5, -0.5 },
							frame_count = 16,
							line_length = 4,
							animation_speed = 1,
						},
					},
				},
				east = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/energy2/turbine_n.png",
							width = 256,
							height = 256,
							shift = { 0.5, -0.5 },
							frame_count = 16,
							line_length = 4,
							animation_speed = 1,
						},
					},
				},
				south = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/energy2/turbine_n.png",
							width = 256,
							height = 256,
							shift = { 0.5, -0.5 },
							frame_count = 16,
							line_length = 4,
							animation_speed = 1,
						},
					},
				},
				west = {
					layers = {
						{
							filename = "__Yuoki__/engines/graphics/entity/energy2/turbine_n.png",
							width = 256,
							height = 256,
							shift = { 0.5, -0.5 },
							frame_count = 16,
							line_length = 4,
							animation_speed = 1,
						},
					},
				},
			},
		},

		crafting_categories = { "yrcat_turbine" },
		crafting_speed = 1.0,

		energy_source = {
			type = "electric",
			usage_priority = "primary-input",
			emissions_per_minute = { pollution = 0.13 },
		},
		energy_usage = "1500kW",
		ingredient_count = 1,
		order = "a",
		subgroup = "yie-engines",
	},

	-- 50MW-Gen
	{
		type = "generator",
		name = "ye_tfmw_generator-s",
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/entity/energy2/hngen-o-icon.png",
		flags = { "placeable-neutral", "player-creation" },
		minable = { mining_time = 0.2, result = "ye_tfmw_generator-s" },
		max_health = 800,
		corpse = "small-remnants",
		effectivity = 0.89,
		fluid_usage_per_tick = 0.4,
		collision_box = { { -3.1, -3.3 }, { 3.1, 3.3 } },
		selection_box = { { -3.5, -3.5 }, { 3.5, 3.5 } },
		maximum_temperature = 400,
		fluid_box = {
			volume = 200,
			base_area = 3,
			height = 2,
			base_level = -1,
			pipe_connections = {
				{ flow_direction = "input-output", direction = defines.direction.south, position = { 0, 3.0 } },
				{ flow_direction = "input-output", direction = defines.direction.south, position = { 1, 3.0 } },
				{ flow_direction = "input-output", direction = defines.direction.south, position = { -1, 3.0 } },

				{ flow_direction = "input-output", direction = defines.direction.north, position = { 0, -3.0 } },
				{ flow_direction = "input-output", direction = defines.direction.north, position = { 1, -3.0 } },
				{ flow_direction = "input-output", direction = defines.direction.north, position = { -1, -3.0 } },
			},
			production_type = "input-output",
			filter = "y-mechanical-force",
		},
		fluid_input = { name = "y-mechanical-force", amount = 0.0, minimum_temperature = 100.0 },
		energy_source = {
			type = "electric",
			usage_priority = "secondary-output",
		},
		horizontal_animation = {
			filename = "__Yuoki__/engines/graphics/entity/energy2/hngen_v.png",
			width = 288,
			height = 288,
			frame_count = 1,
			line_length = 1,
			shift = { 1.00, -0.75 },
		},
		vertical_animation = {
			filename = "__Yuoki__/engines/graphics/entity/energy2/hgen_o_sheet.png",
			width = 288,
			height = 288,
			frame_count = 36,
			line_length = 6,
			animation_speed = 1.0,
			shift = { 1.00, -0.75 },
		},
	},

	-- 70 MW-Turbine
	{
		type = "generator",
		name = "ye_tfmw_turbine-s",
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/entity/turbine_70_icon.png",
		flags = { "placeable-neutral", "player-creation" },
		minable = { mining_time = 0.2, result = "ye_tfmw_turbine-s" },
		max_health = 800,
		corpse = "small-remnants",
		effectivity = 0.97,
		fluid_usage_per_tick = 6.3234,
		collision_box = { { -3.1, -3.3 }, { 3.1, 3.3 } },
		selection_box = { { -3.5, -3.5 }, { 3.5, 3.5 } },
		maximum_temperature = 1000,
		fluid_box = {
			volume = 200,
			base_area = 3,
			height = 2,
			base_level = -1,
			pipe_connections = {
				{ flow_direction = "input-output", direction = defines.direction.south, position = { 0, 3.1 } },
				{ flow_direction = "input-output", direction = defines.direction.east, position = { 3, 0 } },
				{ flow_direction = "input-output", direction = defines.direction.north, position = { 0, -3.1 } },
				{ flow_direction = "input-output", direction = defines.direction.west, position = { -3, 0 } },
			},
			production_type = "input-output",
			filter = "steam",
		},
		fluid_input = { name = "steam", amount = 0.0, minimum_temperature = 500.0 },
		energy_source = {
			type = "electric",
			usage_priority = "secondary-output",
		},
		horizontal_animation = {
			filename = "__Yuoki__/engines/graphics/entity/turbine_70_sheet.png",
			width = 288,
			height = 288,
			frame_count = 6,
			line_length = 6,
			animation_speed = 0.5,
			shift = { 1.00, 0 },
		},
		vertical_animation = {
			filename = "__Yuoki__/engines/graphics/entity/turbine_70_sheet.png",
			width = 288,
			height = 288,
			frame_count = 6,
			line_length = 6,
			animation_speed = 0.5,
			shift = { 1.00, 0 },
		},
	},
})

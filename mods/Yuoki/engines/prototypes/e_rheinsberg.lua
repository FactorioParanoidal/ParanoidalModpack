data:extend({

	{
		type = "assembling-machine",
		name = "ye_rheinsberg",
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/entity/rheinsberg-icon.png",
		flags = { "placeable-neutral", "player-creation" },
		minable = { mining_time = 0.5, result = "ye_rheinsberg" },
		max_health = 700,
		corpse = "big-remnants",
		resistances = { { type = "fire", percent = 80 } },
		collision_box = { { -2.2, -2.2 }, { 2.2, 2.2 } },
		selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },

		fluid_boxes = {
			{
				volume = 200,
				production_type = "input",
				base_area = 10,
				height = 2,
				base_level = -1,
				pipe_connections = {
					{ flow_direction = "input", direction = defines.direction.south, position = { -1, 2 } },
					{ flow_direction = "input", direction = defines.direction.south, position = { 0, 2 } },
					{ flow_direction = "input", direction = defines.direction.south, position = { 1, 2 } },
				},
				filter = "water",
			},
			{
				volume = 200,
				production_type = "output",
				base_area = 5,
				height = 2,
				pipe_connections = {
					{ flow_direction = "output", direction = defines.direction.north, position = { -1, -2 } },
					{ flow_direction = "output", direction = defines.direction.north, position = { 0, -2 } },
					{ flow_direction = "output", direction = defines.direction.north, position = { 1, -2 } },
				},
			},
		},

		crafting_categories = { "yrcat_rheinsberg" },
		crafting_speed = 1,
		energy_source = {
			type = "burner",
			fuel_categories = { "yfusion" },
			effectivity = 1,
			fuel_inventory_size = 1,
			emissions_per_minute = { pollution = 250 },
			smoke = { { name = "smoke", deviation = { 0.1, 0.1 }, frequency = 0.1 } },
		},
		allowed_effects = { "pollution" },
		energy_usage = "75MW",
		ingredient_count = 2,
		order = "a[atomics]",
		subgroup = "yie-fluids",
		graphics_set = {
			animation = {
				layers = {
					{
						filename = "__Yuoki__/engines/graphics/entity/rheinsberg.png",
						priority = "extra-high",
						width = 192,
						height = 192,
						shift = { 0.34, -0.125 },
						frame_count = 1,
						line_length = 1,
					},
				},
			},
		},
		working_visualisations = {
			animation = {
				filename = "__Yuoki__/engines/graphics/entity/rheinsberg.png",
				priority = "extra-high",
				width = 192,
				height = 192,
				shift = { 0.34, -0.125 },
				frame_count = 1,
				line_length = 1,
			},
			light = { intensity = 0.7, size = 9.9, shift = { 0.0, 0.0 }, color = { r = 0.9, g = 0.5, b = 0.2 } },
		},
		module_specification = { module_slots = 0 },
		allowed_effects = { "pollution" },
	},

	-- Rezepte
	{
		type = "recipe",
		name = "ye_rheins_HT",
		category = "yrcat_rheinsberg", -- rheinsberg
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "fluid", name = "water", amount = 160 },
		},
		results = {
			{ type = "fluid", name = "steam", amount = 400, temperature = 1000 },
		},
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/icons/gear-5.png",
		order = "rb-3",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	{
		type = "recipe",
		name = "ye_rheins_MT",
		category = "yrcat_rheinsberg", -- rheinsberg
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "fluid", name = "water", amount = 320 },
		},
		results = {
			{ type = "fluid", name = "steam", amount = 800, temperature = 500 },
		},
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/icons/gear-3.png",
		order = "rb-2",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},

	{
		type = "recipe",
		name = "ye_rheins_LT",
		category = "yrcat_rheinsberg", -- rheinsberg
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "fluid", name = "water", amount = 640 },
		},
		results = {
			{ type = "fluid", name = "steam", amount = 1600, temperature = 250 },
		},
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/icons/gear-2.png",
		order = "rb-1",
		group = "yi_engines",
		subgroup = "yie-fluids",
	},
})

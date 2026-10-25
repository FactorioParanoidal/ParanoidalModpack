data:extend({

	-- Standard-Mode
	{
		type = "recipe",
		name = "y_reactor_mf1",
		category = "yuoki_mf", -- mechanical force -obninsk
		enabled = true,
		energy_required = 1.00,
		ingredients = {
			{ type = "fluid", name = "water", amount = 500 },
		},
		results = {
			{ type = "fluid", name = "y-mechanical-force", amount = 50, temperature = 150 },
		},
		main_product = "y-mechanical-force",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/mf_mode_icon.png",
		order = "1",
		group = "yuoki_liquids",
		subgroup = "y-fluid",
	},
	-- Mox-1-Mode
	{
		type = "recipe",
		name = "y_reactor_mox1",
		category = "yuoki_mf", -- mechanical force -obninsk
		enabled = true,
		energy_required = 15.00,
		ingredients = {
			{ type = "item", name = "y_mox1mixed", amount = 3 },
			{ type = "fluid", name = "water", amount = 500 },
		},
		results = {
			{ type = "item", name = "y_mox1heated", amount = 3 },
			{ type = "fluid", name = "y-mechanical-force", amount = 100, temperature = 150 },
		},
		main_product = "y_mox1heated",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/mox1mode.png",
		order = "2",
		group = "yuoki_liquids",
		subgroup = "y-fluid",
	},
	-- Mox-2-Mode
	{
		type = "recipe",
		name = "y_reactor_mox2",
		category = "yuoki_mf", -- mechanical force -obninsk
		enabled = true,
		energy_required = 20.00,
		ingredients = {
			{ type = "item", name = "y_mox2mixed", amount = 2 },
			{ type = "fluid", name = "water", amount = 500 },
		},
		results = {
			{ type = "item", name = "y_mox2heated", amount = 2 },
			{ type = "fluid", name = "y-mechanical-force", amount = 200, temperature = 150 },
		},
		main_product = "y_mox2heated",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/mox2mode.png",
		order = "3",
		group = "yuoki_liquids",
		subgroup = "y-fluid",
	},

	{
		type = "assembling-machine",
		name = "y-obninsk-reactor",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/obninsk-reactor-icon.png",
		flags = { "placeable-neutral", "player-creation" },
		minable = { hardness = 0.3, mining_time = 0.5, result = "y-obninsk-reactor" },
		max_health = 500,
		corpse = "big-remnants",
		resistances = { { type = "fire", percent = 80 } },
		fluid_boxes = {
			{
				volume = 200,
				production_type = "input",
				pipe_picture = assembler2pipepictures(),
				pipe_covers = pipecoverspictures(),
				base_area = 10,
				base_level = -1,
				pipe_connections = {
					{ flow_direction = "input", direction = defines.direction.south, position = { 0, 2.0 } },
				},
				secondary_draw_orders = { north = -1 },
				filter = "water",
			},
			{
				volume = 200,
				production_type = "output",
				pipe_picture = assembler2pipepictures(),
				pipe_covers = pipecoverspictures(),
				base_area = 10,
				base_level = 1,
				pipe_connections = {
					{ flow_direction = "output", direction = defines.direction.north, position = { 0, -2.0 } },
				},
				secondary_draw_orders = { north = -1 },
			},
		},
		collision_box = { { -2.25, -2.25 }, { 2.25, 2.25 } },
		selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },

		graphics_set = {
			animation = {
				layers = {
					{
						filename = "__Yuoki__/graphics/entity/obninsk-reactor_ns.png",
						priority = "extra-high",
						width = 210,
						height = 180,
						shift = { 0.6, 0.2 },
						frame_count = 1,
						line_length = 1,
					},
				},
			},
			working_visualisations = {
				{
					animation = {
						layers = {
							{
								filename = "__Yuoki__/graphics/entity/obninsk-reactor_wns.png",
								priority = "extra-high",
								width = 210,
								height = 180,
								shift = { 0.6, 0.2 },
								frame_count = 1,
								line_length = 1,
								light = {
									intensity = 0.7,
									size = 9.9,
									shift = { 0.0, 0.0 },
									color = { r = 0.7, g = 0.0, b = 0.7 },
								},
							},
						},
					},
				},
			},
		},
		crafting_categories = { "yuoki_mf" },
		crafting_speed = 1,
		energy_source = {
			type = "burner",
			fuel_categories = { "yfusion" },
			effectivity = 0.5,
			fuel_inventory_size = 1,
			emissions_per_minute = { pollution = 600 },
			smoke = { { name = "smoke", deviation = { 0.1, 0.1 }, frequency = 0.1 } },
		},
		allowed_effects = { "pollution" },
		energy_usage = "30MW",
		ingredient_count = 3,
		order = "o",
		subgroup = "y-boiler",
	},

	{
		type = "assembling-machine",
		name = "y_moxmixer",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/fuel_mixer_icon.png",
		flags = { "placeable-neutral", "player-creation" },
		minable = { hardness = 0.5, mining_time = 1, result = "y_moxmixer" },
		max_health = 500,
		resistances = { { type = "physical", percent = 50 } },
		collision_box = { { -1.25, -1.25 }, { 1.25, 1.25 } },
		selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
		graphics_set = {
			animation = {
				layers = {
					{
						filename = "__Yuoki__/graphics/entity/fuel_mixer_sheet.png",
						priority = "medium",
						width = 256,
						height = 256,
						frame_count = 16,
						line_length = 4,
						shift = { 0.5, -0.325 },
						animation_speed = 0.5,
						scale = 0.5,
					},
				},
			},
		},

		crafting_categories = { "yuoki_mox" },
		crafting_speed = 1,
		energy_source = {
			type = "electric",
			input_priority = "secondary",
			usage_priority = "secondary-input",
			emissions_per_minute = { pollution = 18.75 },
		},
		energy_usage = "1250kW",
		ingredient_count = 4,
		module_slots = 2,
		allowed_effects = { "consumption", "speed", "productivity", "pollution" },
	},
})

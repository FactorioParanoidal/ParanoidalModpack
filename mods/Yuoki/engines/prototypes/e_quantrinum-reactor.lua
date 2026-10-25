data:extend({

	-- Quantrinum Reactor
	{
		type = "assembling-machine",
		name = "y-quantrinum-reactor",
		icon_size = 64,
		icon = "__Yuoki__/engines/graphics/entity/energy2/qr-icon.png",
		flags = { "placeable-neutral", "placeable-player", "player-creation" },
		minable = { hardness = 0.2, mining_time = 0.5, result = "y-quantrinum-reactor" },
		max_health = 250,
		corpse = "big-remnants",
		resistances = { { type = "physical", percent = 60 } },
		fluid_boxes = {
			{
				volume = 200,
				production_type = "output",
				base_area = 100,
				base_level = 1,
				pipe_connections = {
					{ flow_direction = "output", direction = defines.direction.south, position = { 0, 2 } },
					{ flow_direction = "output", direction = defines.direction.north, position = { 0, -2 } },
					{ flow_direction = "output", direction = defines.direction.east, position = { 2, 0 } },
					{ flow_direction = "output", direction = defines.direction.west, position = { -2, 0 } },
				},
			},
		},
		collision_box = { { -2.2, -2.2 }, { 2.2, 2.2 } },
		selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
		fast_replaceable_group = "assembling-machine",
		graphics_set = {
			animation = {
				layers = {
					{
						filename = "__Yuoki__/engines/graphics/entity/energy2/qr-anim.png",
						width = 200,
						height = 180,
						shift = { 0.35, 0.0 },
						frame_count = 18,
						line_length = 9,
						animation_speed = 0.75,
					},
				},
			},
		},
		crafting_categories = { "yrcat-mf1q" },
		crafting_speed = 1,
		energy_source = {
			type = "electric",
			usage_priority = "primary-input",
			emissions_per_minute = { pollution = 0.5 },
		},
		energy_usage = "2MW",
		ingredient_count = 1,
		order = "a[atomics]",
		subgroup = "yie-engines",
	},
})

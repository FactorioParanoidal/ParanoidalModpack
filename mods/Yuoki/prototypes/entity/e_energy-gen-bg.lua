data:extend({
	{
		type = "recipe",
		name = "y_bg-1",
		ingredients = {
			{ type = "item", name = "y_structure_vessel", amount = 4 },
			{ type = "item", name = "y-basic-t1-mf", amount = 2 },
			{ type = "item", name = "y-heat-pipe", amount = 2 },
		},
		results = {
			{ type = "item", name = "y_bg-1", amount = 1 },
		},
		main_product = "y_bg-1",
		enabled = true,
		group = "yuoki-energy",
		subgroup = "y-boiler",
		order = "bg1",
	},

	{
		type = "item",
		name = "y_bg-1",
		icon_size = 96,
		icon = "__Yuoki__/graphics/icons/bg1-icon.png",
		group = "yuoki-energy",
		subgroup = "y-boiler",
		order = "bg1",
		place_result = "y_bg-1",
		stack_size = 25,
	},
	{
		type = "burner-generator",
		name = "y_bg-1",
		icon_size = 96,
		icon = "__Yuoki__/graphics/icons/bg1-icon.png",
		flags = { "placeable-neutral", "player-creation" },
		minable = { mining_time = 1, result = "y_bg-1" },
		max_health = 300,
		corpse = "small-remnants",
		effectivity = 1.2,
		resistances = {
			{
				type = "fire",
				percent = 70,
			},
		},
		collision_box = { { -1.3, -1.7 }, { 1.3, 1.7 } },
		selection_box = { { -1.5, -2.0 }, { 1.5, 2.0 } },

		energy_source = {
			type = "electric",
			usage_priority = "secondary-output",
		},
		max_power_output = "1.8MW",

		energy_consumption = "2.5MW",
		burner = {
			type = "burner",
			fuel_categories = { "chemical" },
			effectivity = 0.72,
			fuel_inventory_size = 2,
			emissions_per_minute = { pollution = 5 },
			smoke = {
				{
					name = "smoke",
					deviation = { 0.1, 0.1 },
					frequency = 1.5,
				},
			},
		},
		animation = {
			north = {
				filename = "__Yuoki__/graphics/entity/energy-t2/bg1ns.png",
				width = 320,
				height = 320,
				frame_count = 4,
				line_length = 2,
				scale = 0.5,
				shift = { 1.0, -0.4 },
				animation_speed = 0.25,
			},
			east = {
				filename = "__Yuoki__/graphics/entity/energy-t2/bg1we.png",
				width = 320,
				height = 320,
				frame_count = 4,
				line_length = 2,
				scale = 0.5,
				shift = { 0.5, -1.0 },
				animation_speed = 0.25,
			},
			west = {
				filename = "__Yuoki__/graphics/entity/energy-t2/bg1we.png",
				width = 320,
				height = 320,
				frame_count = 4,
				line_length = 2,
				scale = 0.5,
				shift = { 0.5, -1.0 },
				animation_speed = 0.25,
			},
		}
	},
})

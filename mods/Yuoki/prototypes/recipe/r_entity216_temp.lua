data:extend({

	{
		type = "recipe",
		name = "yi_roboport",
		category = "yuoki-wonder",
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "y_structure_element", amount = 14 },
			{ type = "item", name = "yi_magnetron", amount = 2 },
			{ type = "item", name = "y-accumulator-b", amount = 2 },
			{ type = "item", name = "y-basic-t1-mf", amount = 2 },
			{ type = "item", name = "y_rwtechsign", amount = 10 },
		},
		results = {
			{ type = "item", name = "yi_roboport", amount = 1 },
			{ type = "item", name = "ypfw_trader_sign", amount = 3 },
		},
		main_product = "yi_roboport",
		icon_size = 64,
		icon = "__Yuoki__/graphics/entity/yi_roboport_icon.png",
		order = "1",
		group = "yuoki",
		subgroup = "j-y-logi-9",
	},

	{
		type = "recipe",
		name = "j_yi_roboport1",
		category = "yuoki-wonder",
		enabled = true,
		energy_required = 5.00,
		ingredients = {
			{ type = "item", name = "y_structure_element", amount = 5 },
			{ type = "item", name = "yi_magnetron", amount = 1 },
			{ type = "item", name = "y-ups-flywheel-b", amount = 2 },
			{ type = "item", name = "y-basic-t1-mf", amount = 2 },
			{ type = "item", name = "y_rwtechsign", amount = 2 },
		},
		results = {
			{ type = "item", name = "j_yi_roboport1", amount = 1 },
			{ type = "item", name = "ypfw_trader_sign", amount = 1 },
		},
		main_product = "j_yi_roboport1",
		icon_size = 64,
		icons = {
			{ icon = "__Yuoki__/graphics/icons/8080_icon.png", tint = { r = 179 / 255, g = 198 / 255, b = 255 / 255 }, scale = 0.5 },
		},
		order = "2",
		group = "yuoki",
		subgroup = "j-y-logi-9",
	},

	--
	{
		type = "recipe",
		name = "yi_radar",
		category = "yuoki-wonder",
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "y_structure_element", amount = 8 },
			{ type = "item", name = "yi_magnetron", amount = 1 },
			{ type = "item", name = "y-basic-t2-mf", amount = 2 },
			{ type = "item", name = "y-raw-fuelnium", amount = 3 },
			{ type = "item", name = "y_rwtechsign", amount = 4 },
		},
		results = {
			{ type = "item", name = "yi_radar", amount = 1 },
			{ type = "item", name = "ye_science_blue", amount = 1 },
		},
		main_product = "yi_radar",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/radar_icon.png",
		order = "a",
		group = "yuoki",
		subgroup = "y_line1b",
	},

	--
	{
		type = "recipe",
		name = "yi_beacon",
		category = "yuoki-wonder",
		enabled = true,
		energy_required = 3.00,
		ingredients = {
			{ type = "item", name = "y_structure_element", amount = 12 },
			{ type = "item", name = "yi_magnetron", amount = 4 },
			{ type = "item", name = "y-chip-2", amount = 6 },
			{ type = "item", name = "y_quantrinum_infused", amount = 1 },
			{ type = "item", name = "y_rwtechsign", amount = 6 },
		},
		results = {
			{ type = "item", name = "yi_beacon", amount = 1 },
			{ type = "item", name = "ypfw_trader_sign", amount = 3 },
		},
		main_product = "yi_beacon",
		icon_size = 64,
		icon = "__Yuoki__/graphics/icons/beacon_64.png",
		order = "a",
		group = "yuoki",
		subgroup = "y_line1b",
	},
})

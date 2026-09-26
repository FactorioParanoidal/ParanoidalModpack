-- ПР-044/047: отдельные RCU/RCC, модуль IV только как вход и предок. Сам модуль не меняется.
-- Поздняя регистрация не реактивирует ранние сторонние патчи отсутствовавших ID.
if not data.raw.item["rocket-control-unit"] and not data.raw.item["rocket-control-circuit"] then
	data:extend({
		{
			type = "item",
			name = "rocket-control-unit",
			subgroup = "space-exploration-a",
			order = "n[rocket-control-unit]",
			stack_size = 10,
			drop_sound = { filename = "__base__/sound/item/electric-small-inventory-move.ogg", volume = 1 },
			inventory_move_sound = { filename = "__base__/sound/item/electric-small-inventory-move.ogg", volume = 1 },
			pick_sound = { filename = "__base__/sound/item/electric-small-inventory-pickup.ogg", volume = 0.7 },
			weight = 2500,
			icons = {
				{ icon = "__bobelectronics__/graphics/icons/electronic-processing-board.png", icon_size = 64 },
				{
					icon = "__base__/graphics/icons/rocket-part.png",
					icon_size = 64,
					scale = 0.25,
					shift = { 8, 8 },
				},
			},
			localised_name = { "item-name.rocket-control-unit" },
		},
		{
			type = "item",
			name = "rocket-control-circuit",
			subgroup = "angels-circuit-board",
			order = "z[rocket-control-circuit]",
			stack_size = 200,
			drop_sound = { filename = "__base__/sound/item/wood-inventory-move.ogg", volume = 0.85, speed = 1.6 },
			inventory_move_sound = { filename = "__base__/sound/item/wood-inventory-move.ogg", volume = 0.85, speed = 1.6 },
			pick_sound = { filename = "__base__/sound/item/wood-inventory-pickup.ogg", volume = 0.85, speed = 1.6 },
			weight = 1000,
			icons = {
				{ icon = "__bobelectronics__/graphics/icons/superior-circuit-board.png", icon_size = 64 },
				{
					icon = "__base__/graphics/icons/rocket-part.png",
					icon_size = 64,
					scale = 0.25,
					shift = { 8, 8 },
				},
			},
			localised_name = { "item-name.rocket-control-circuit" },
		},
		{
			type = "recipe",
			name = "rocket-control-unit",
			category = "electronics",
			enabled = false,
			energy_required = 30,
			ingredients = {
				{ type = "item", name = "bob-basic-electronic-components", amount = 4 },
				{ type = "item", name = "bob-electronic-components", amount = 6 },
				{ type = "item", name = "bob-integrated-electronics", amount = 4 },
				{ type = "item", name = "bob-processing-electronics", amount = 8 },
				{ type = "item", name = "bob-solder", amount = 5 },
				{ type = "item", name = "bob-multi-layer-circuit-board", amount = 2 },
				{ type = "item", name = "rocket-control-circuit", amount = 1 },
			},
			results = {
				{ type = "item", name = "rocket-control-unit", amount = 1 },
			},
			allow_productivity = false,
			allow_decomposition = false,
			always_show_products = true,
			show_amount_in_title = false,
		},
		{
			type = "recipe",
			name = "rocket-control-circuit",
			category = "electronics",
			enabled = false,
			energy_required = 150,
			ingredients = {
				{ type = "item", name = "bob-speed-module-4", amount = 1 },
				{ type = "item", name = "bob-superior-circuit-board", amount = 20 },
			},
			results = {
				{ type = "item", name = "rocket-control-circuit", amount = 20 },
			},
			allow_productivity = false,
			allow_decomposition = false,
			always_show_products = true,
			show_amount_in_title = false,
		},
		{
			type = "technology",
			name = "rocket-control-unit",
			icons = {
				{ icon = "__bobelectronics__/graphics/icons/electronic-processing-board.png", icon_size = 64 },
				{
					icon = "__base__/graphics/icons/rocket-part.png",
					icon_size = 64,
					scale = 0.25,
					shift = { 8, 8 },
				},
			},
			localised_name = { "item-name.rocket-control-unit" },
			prerequisites = { "utility-science-pack", "bob-speed-module-4" },
			unit = {
				count = 300,
				ingredients = {
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack", 1 },
					{ "chemical-science-pack", 1 },
					{ "utility-science-pack", 1 },
					{ "production-science-pack", 1 },
				},
				time = 45,
			},
			effects = {
				{ type = "unlock-recipe", recipe = "rocket-control-unit" },
				{ type = "unlock-recipe", recipe = "rocket-control-circuit" },
			},
		},
	})
end

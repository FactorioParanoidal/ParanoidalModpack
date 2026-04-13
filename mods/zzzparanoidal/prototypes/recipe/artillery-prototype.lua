data:extend({
	{
		type = "recipe",
		name = "artillery-turret-prototype",
		icon = "__zzzparanoidal__/graphics/entity/artillery-turret.png",
		icon_size = 64,
		icon_mipmaps = 4,
		enabled = false,
		energy_required = 20,
		ingredients = {
			{ type = "item", name = "electronic-circuit", amount = 10 },
			{ type = "item", name = "engine-unit", amount = 15 },
			{ type = "item", name = "steel-plate", amount = 120 },
			{ type = "item", name = "concrete", amount = 100 },
		},
		results = { { type = "item", name = "artillery-turret-prototype", amount = 1 } },
	},
	{
		type = "recipe",
		name = "artillery-shell-prototype",
		enabled = false,
		energy_required = 20,
		ingredients = {
			{ type = "item", name = "steel-plate", amount = 5 },
			{ type = "item", name = "bob-bronze-alloy", amount = 2 },
			{ type = "item", name = "explosives", amount = 3 },
		},
		results = { { type = "item", name = "artillery-shell-prototype", amount = 1 } },
	},
})

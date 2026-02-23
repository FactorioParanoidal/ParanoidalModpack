--создаем машинку с огнеметом
local flame_car = table.deepcopy(data.raw.car.car)
flame_car.name = "flame_car"
flame_car.minable = { mining_time = 0.4, result = "flame_car" }
flame_car.resistances = {
	{ type = "fire", percent = 100 },
	{ type = "impact", percent = 30, decrease = 50 },
	{ type = "acid", percent = 20 },
}
flame_car.guns = { "tank-flamethrower" }
flame_car.equipment_grid = "small-equipment-grid"

data:extend({ flame_car })
-------------------------------------------------------------------------------------------------
data:extend({
	{
		type = "recipe",
		name = "flame_car",
		enabled = false,
		energy_required = 20,
		ingredients = {
			{ type = "item", name = "iron-gear-wheel", amount = 30 },
			{ type = "item", name = "steel-plate", amount = 40 },
			{ type = "item", name = "engine-unit", amount = 16 },
			{ type = "item", name = "flamethrower", amount = 3 },
		},
		results = { { type = "item", name = "flame_car", amount = 1 } },
	},
	-------------------------------------------------------------------------------------------------
	{
		type = "item",
		name = "flame_car",
		icons = {
			{
				icon = "__base__/graphics/icons/car.png",
				icon_size = 64,
				icon_mipmaps = 4,
			},
			{
				icon = "__base__/graphics/icons/flamethrower.png",
				icon_size = 64,
				icon_mipmaps = 4,
				scale = 0.3,
				shift = { -10, -10 },
			},
		},
		icon_size = 64,
		subgroup = "transport",
		order = "b[personal-transport]-b[car]",
		stack_size = 1,
		place_result = "flame_car",
	},
	-------------------------------------------------------------------------------------------------
	{
		type = "technology",
		name = "flame_car",
		icons = {
			{
				icon = "__base__/graphics/technology/automobilism.png",
				icon_size = 256,
				icon_mipmaps = 4,
			},
			{
				icon = "__base__/graphics/technology/refined-flammables.png",
				icon_size = 256,
				icon_mipmaps = 4,
				scale = 0.5,
				shift = { -60, 50 },
			},
		},
		effects = { { type = "unlock-recipe", recipe = "flame_car" } },
		prerequisites = { "flamethrower", "automobilism" },
		unit = {
			count = 50,
			ingredients = {
				{ "automation-science-pack", 1},
				{ "logistic-science-pack", 1},
				{ "military-science-pack", 1},
			},
			time = 30,
		},
		order = "1",
	},
})


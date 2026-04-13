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


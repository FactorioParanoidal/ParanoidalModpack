--создаем hazard-tile-left для hazard-concrete-brick
local hazard_tile_left = table.deepcopy(data.raw["tile"]["refined-hazard-concrete-left"])
hazard_tile_left.name = "hazard-concrete-brick-left"
hazard_tile_left.minable = { mining_time = 0.1, result = "hazard-concrete-brick" }
hazard_tile_left.layer = 225
hazard_tile_left.next_direction = "hazard-concrete-brick-right"
hazard_tile_left.variants.material_background = {
	picture = "__zzzparanoidal__/graphics/grid/hazard-concrete-left.png",
	count = 8,
}
data:extend({ hazard_tile_left })

--создаем hazard-tile-right для hazard-concrete-brick
local hazard_tile_right = table.deepcopy(data.raw["tile"]["refined-hazard-concrete-right"])
hazard_tile_right.name = "hazard-concrete-brick-right"
hazard_tile_right.minable = { mining_time = 0.1, result = "hazard-concrete-brick" }
hazard_tile_right.layer = 225
hazard_tile_right.next_direction = "hazard-concrete-brick-left"
hazard_tile_right.variants.material_background = {
	picture = "__zzzparanoidal__/graphics/grid/hazard-concrete-right.png",
	count = 8,
}
data:extend({ hazard_tile_right })

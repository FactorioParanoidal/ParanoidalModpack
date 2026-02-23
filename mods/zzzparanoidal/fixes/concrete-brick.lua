--создаем предмет для hazard-concrete-brick
data:extend({
	{
		type = "item",
		name = "hazard-concrete-brick",
		icons = {
			{
				icon = "__angelssmeltinggraphics__/graphics/icons/brick-concrete.png",
				icon_size = 32,
			},
			{
				icon = "__base__/graphics/icons/refined-hazard-concrete.png",
				icon_size = 64,
				icon_mipmaps = 4,
				scale = 0.3,
				shift = { -10, -10 },
			},
		},
		icon_size = 32,
		subgroup = "angels-stone-casting",
		order = "ia",
		stack_size = angelsmods.trigger.pavement_stack_size,
		place_as_tile = {
			result = "hazard-concrete-brick-left",
			condition_size = 1,
			condition = { layers = { water_tile = true } },
		},
	},
})
-------------------------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------------------------
--добавляем рецепт для бетонного кирпича с полосами
data:extend({
	{
		type = "recipe",
		name = "hazard-concrete-brick",
		category = "crafting",
		group = "angels-casting",
		subgroup = "angels-stone-casting",
		order = "ia",
		energy_required = 1,
		enabled = false,
		allow_decomposition = false,
		always_show_products = true,
		ingredients = { { type = "item", name = "angels-concrete-brick", amount = 10 } },
		results = { { type = "item", name = "hazard-concrete-brick", amount = 10 } },
	},
})

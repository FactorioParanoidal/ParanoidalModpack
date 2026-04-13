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


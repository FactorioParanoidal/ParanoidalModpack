data:extend({
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
})

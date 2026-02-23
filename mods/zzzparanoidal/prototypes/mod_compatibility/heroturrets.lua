data:extend({
	{
		type = "selection-tool",
		name = "hero_downgrade",
		flags = { "only-in-cursor" },
		stack_size = 1,
		alt_select = {
			border_color = { r = 0, g = 0, b = 0.5, a = 0.2 },
			mode = { "buildable-type" },
			cursor_box_type = "copy",
		},
		icon = "__base__/graphics/icons/tank-cannon.png",
		icon_size = 64,
		icon_mipmaps = 4,
		select = {
			border_color = { r = 0, g = 0, b = 1, a = 0.2 },
			mode = { "buildable-type" },
			cursor_box_type = "entity",
		},
	},
})

data:extend({
	{
		type = "space-location",
		name = "star",
		icon = "__core__/graphics/icons/starmap-star.png",
		icon_size = 512,
		starmap_icon = "__core__/graphics/icons/starmap-star.png",
		starmap_icon_size = 512,
		origin = { x = 0, y = 0 },
		distance = 0,
		orientation = 0,
		magnitude = 8,
		sprite_only = true,
		-- promoting star to a permanent real, but hidden, space-location
		hidden = true,
		draw_orbit = false,
		redrawn_connections_exclude = true,
		cosmic_social_distancing_ignore = true,
	},
})

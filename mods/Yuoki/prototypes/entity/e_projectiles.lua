data:extend({
	{
		type = "projectile",
		name = "white-laser",
		flags = { "not-on-map" },
		acceleration = 0.005,
		action = {
			type = "direct",
			action_delivery = {
				type = "instant",
				target_effects = {
					{
						type = "create-entity",
						entity_name = "laser-bubble",
					},
					{
						type = "damage",
						damage = { amount = 6, type = "laser" },
					},
				},
			},
		},
		light = { intensity = 0.5, size = 10 },
		animation = {
			filename = "__base__/graphics/entity/laser/laser-to-tint-medium.png",
			tint = { r = 1.0, g = 1.0, b = 0.9 },
			frame_count = 1,
			width = 12,
			height = 33,
			priority = "high",
			blend_mode = "additive",
		},
		speed = 0.15,
	},
	{
		type = "projectile",
		name = "cyan-laser",
		flags = { "not-on-map" },
		acceleration = 0.005,
		action = {
			type = "direct",
			action_delivery = {
				type = "instant",
				target_effects = {
					{
						type = "create-entity",
						entity_name = "laser-bubble",
					},
					{
						type = "damage",
						damage = { amount = 10, type = "laser" },
					},
				},
			},
		},
		light = { intensity = 0.5, size = 10 },
		animation = {
			filename = "__base__/graphics/entity/blue-laser/blue-laser.png",
			tint = { r = 0.3, g = 0.98, b = 1.0 },
			frame_count = 1,
			width = 7,
			height = 14,
			priority = "high",
		},
		speed = 0.15,
	},
	{
		type = "projectile",
		name = "green-plasma",
		flags = { "not-on-map" },
		acceleration = 0.005,
		action = {
			type = "direct",
			action_delivery = {
				type = "instant",
				target_effects = {
					{
						type = "create-entity",
						entity_name = "laser-bubble",
					},
					--	{	type = "damage", damage = { amount = 10 , type = "plasma" },},
					--	{ 	type = "damage", damage = { amount = 2 , type = "acid"},},
				},
			},
		},
		light = { intensity = 0.6, size = 12 },
		animation = {
			filename = "__Yuoki__/graphics/entity/green_plasma.png",
			--tint = {r=0.1, g=1.00, b=0.5, a=1.0},
			frame_count = 1,
			width = 15,
			height = 28,
			priority = "high",
		},
		speed = 0.15,
	},
})

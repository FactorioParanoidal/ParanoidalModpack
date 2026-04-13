data:extend({

	{
		type = "projectile",
		name = "rpg_fireaball",
		flags = { "not-on-map" },
		acceleration = 0, --0.005,
		action = {
			type = "direct",
			action_delivery = {
				type = "instant",
				target_effects = {
					{
						type = "play-sound",
						sound = {
							{
								filename = "__base__/sound/fight/throw-projectile-1.ogg",
								volume = 0.8,
							},
							{
								filename = "__base__/sound/fight/throw-projectile-2.ogg",
								volume = 0.8,
							},
							{
								filename = "__base__/sound/fight/throw-projectile-3.ogg",
								volume = 0.8,
							},
							{
								filename = "__base__/sound/fight/throw-projectile-4.ogg",
								volume = 0.8,
							},
						},
					},

					{
						type = "damage",
						damage = { amount = 120, type = "fire" },
					},
					{
						type = "create-entity",
						entity_name = "big-explosion",
					},
					{
						type = "create-trivial-smoke",
						smoke_name = "artillery-smoke",
						initial_height = 0,
						speed_from_center = 0.05,
						speed_from_center_deviation = 0.005,
						offset_deviation = { { -3, -3 }, { 3, 3 } },
						max_radius = 2.5,
						repeat_count = 2 * 4 * 15,
					},
					{
						type = "create-fire",
						entity_name = "fire-flame",
					},
					{
						type = "nested-result",
						action = {
							type = "area",
							radius = 5,
							action_delivery = {
								type = "instant",
								target_effects = {
									{
										type = "damage",
										damage = { amount = 120, type = "fire" },
									},

									{
										type = "create-entity",
										entity_name = "explosion",
									},
									{
										type = "create-fire",
										entity_name = "fire-flame",
									},
								},
							},
						},
					},
				},
			},
		},
		animation = {
			filename = "__RPGsystem__/graphics/fireball.png",
			line_length = 1,
			scale = 0.25,
			width = 128,
			height = 128,
			frame_count = 1,
			priority = "high",
		},
		rotatable = true,
	},

	{
		type = "projectile",
		name = "rpg_hadouken",
		flags = { "not-on-map" },
		acceleration = 0, --0.005,
		action = {
			type = "direct",
			action_delivery = {
				type = "instant",
				target_effects = {
					{
						type = "play-sound",
						sound = {
							{
								filename = "__base__/sound/fight/throw-projectile-1.ogg",
								volume = 0.8,
							},
							{
								filename = "__base__/sound/fight/throw-projectile-2.ogg",
								volume = 0.8,
							},
							{
								filename = "__base__/sound/fight/throw-projectile-3.ogg",
								volume = 0.8,
							},
							{
								filename = "__base__/sound/fight/throw-projectile-4.ogg",
								volume = 0.8,
							},
						},
					},

					{
						type = "damage",
						damage = { amount = 80, type = "electric" },
					},
					{
						type = "create-particle",
						particle_name = "tintable-water-particle",
						repeat_count = 50,
						initial_height = 1,
						initial_vertical_speed = 0.1,
						initial_vertical_speed_deviation = 0.05,
						offset_deviation = { { -0.1, -0.1 }, { 0.1, 0.1 } },
						speed_from_center = 0.05,
						speed_from_center_deviation = 0.01,
					},
					{
						type = "nested-result",
						action = {
							type = "area",
							radius = 7,
							action_delivery = {
								type = "instant",
								target_effects = {
									{
										type = "damage",
										damage = { amount = 80, type = "electric" },
									},
									{
										type = "create-particle",
										particle_name = "tintable-water-particle",
										repeat_count = 30,
										initial_height = 1,
										initial_vertical_speed = 0.1,
										initial_vertical_speed_deviation = 0.05,
										offset_deviation = { { -0.1, -0.1 }, { 0.1, 0.1 } },
										speed_from_center = 0.05,
										speed_from_center_deviation = 0.01,
									},
								},
							},
						},
					},
				},
			},
		},
		animation = {
			filename = "__RPGsystem__/graphics/LV_Magic_icon.png",
			line_length = 1,
			scale = 0.25,
			width = 128,
			height = 128,
			frame_count = 1,
			priority = "high",
		},
		rotatable = true,
	},
})

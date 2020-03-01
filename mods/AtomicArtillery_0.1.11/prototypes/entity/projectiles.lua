data:extend(
{
	{
		type = "artillery-projectile",
		name = "atomic-artillery-projectile",
		flags = {"not-on-map"},
		acceleration = 0,
		direction_only = true,
		reveal_map = true,
		map_color = {r=1, g=1, b=0},
		picture =
		{
			filename = "__AtomicArtillery__/graphics/entity/artillery-projectile/hr-atomic-shell.png",
			width = 64,
			height = 64,
			scale = 0.5,
		},
		shadow =
		{
			filename = "__base__/graphics/entity/artillery-projectile/hr-shell-shadow.png",
			width = 64,
			height = 64,
			scale = 0.5,
		},
		chart_picture =
		{
			filename = "__AtomicArtillery__/graphics/entity/artillery-projectile/atomic-artillery-shoot-map-visualization.png",
			flags = { "icon" },
			frame_count = 1,
			width = 64,
			height = 64,
			priority = "high",
			scale = 0.25,
		},
		action =
		{
			type = "direct",
			action_delivery =
			{
				type = "instant",
				target_effects =
				{
					{
						repeat_count = 100,
						type = "create-trivial-smoke",
						smoke_name = "nuclear-smoke",
						offset_deviation = {{-1, -1}, {1, 1}},
						slow_down_factor = 1,
						starting_frame = 3,
						starting_frame_deviation = 5,
						starting_frame_speed = 0,
						starting_frame_speed_deviation = 5,
						speed_from_center = 0.5,
						speed_deviation = 0.2
					},
					{
						type = "create-entity",
						entity_name = "explosion"
					},
					{
						type = "damage",
						damage = {amount = 1500, type = "explosion"}
					},
					{
						type = "create-entity",
						entity_name = "small-scorchmark",
						check_buildability = true
					},
					{
						type = "nested-result",
						action =
						{
							type = "area",
							target_entities = false,
							trigger_from_target = true,
							repeat_count = 4000,
							radius = 50,
							action_delivery =
							{
								type = "projectile",
								projectile = "atomic-artillery-wave",
								starting_speed = 0.5
							},
						}
					}
				}
			}
		},
		final_action =
		{
			type = "direct",
			action_delivery =
			{
				type = "instant",
				target_effects =
				{
					{
						type = "create-entity",
						entity_name = "small-scorchmark",
						check_buildability = true
					}
				}
			}
		},
		animation =
		{
			filename = "__base__/graphics/entity/bullet/bullet.png",
			frame_count = 1,
			width = 3,
			height = 50,
			priority = "high"
		}
	},
	{
		type = "projectile",
		name = "atomic-artillery-wave",
		flags = {"not-on-map"},
		acceleration = 0,
		action =
		{
			{
				type = "direct",
				action_delivery =
				{
					type = "instant",
					target_effects =
					{
						{
							type = "create-entity",
							entity_name = "explosion"
						}
					}
				}
			},
			{
				type = "area",
				radius = 3,
				action_delivery =
				{
					type = "instant",
					target_effects =
					{
						type = "damage",
						damage = {amount = 1500, type = "explosion"}
					}
				}
			}
		},
		animation =
		{
			filename = "__core__/graphics/empty.png",
			frame_count = 1,
			width = 1,
			height = 1,
			priority = "high"
		},
		shadow =
		{
			filename = "__core__/graphics/empty.png",
			frame_count = 1,
			width = 1,
			height = 1,
			priority = "high"
		}
	},
}
)
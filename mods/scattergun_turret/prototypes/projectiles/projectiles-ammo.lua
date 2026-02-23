data:extend(
{

{
	type = "projectile",
	name = "w93-uranium-shotgun-pellet",

	flags = {"not-on-map"},

	hidden = true,
	collision_box = {{-0.05, -0.25}, {0.05, 0.25}},
	acceleration = 0,
	piercing_damage = 100,
	direction_only = true,
	hit_collision_mask = {layers={object=true, player=true, train=true, trigger_target=true}},
	action =

	{

		type = "direct",

		action_delivery =
		{
			type = "instant",

			target_effects =

			{

				type = "damage",

				damage = {amount = 20, type = "physical"}

			}

		}

	},

	animation =

	{

		filename = "__base__/graphics/entity/piercing-bullet/piercing-bullet.png",
		frame_count = 1,

		width = 3,
		height = 50,
		priority = "high",
		tint = {r=0.0, g=1.0, b=0.0},
	}

},
{
	type = "projectile",
	name = "slowdown-rocket",

	flags = {"not-on-map"},
	hidden = true,
	acceleration = 0.01,

	turn_speed = 0.003,
	turning_speed_increases_exponentially_with_projectile_speed = true,
	action =
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
				},
				{

					type = "create-entity",
					entity_name = "slowdown-capsule-explosion"
				},
				{

					type = "damage",

					damage = {amount = 200, type = "explosion"}
				},
				{
					type = "create-entity",
					entity_name = "small-scorchmark-tintable",
					check_buildability = true
				},
				{
					type = "invoke-tile-trigger",
					repeat_count = 1
				},
				{
					type = "destroy-decoratives",
					from_render_layer = "decorative",
					to_render_layer = "object",
					include_soft_decoratives = true,
					include_decals = false,
					invoke_decorative_trigger = true,
					decoratives_with_trigger_only = false,
					radius = 1.5
				},
				{

					type = "nested-result",

					action =
					{

						type = "area",
						radius = 6.5,
						action_delivery =
						{

							type = "instant",
							target_effects =

							{

								{

									type = "create-sticker",
									sticker = "slowdown-sticker-medium"
,
									show_in_tooltip = true
								}
							}

						}

					}

				}
			}
		}
	},
	animation = require("__base__.prototypes.entity.rocket-projectile-pictures").animation({0.5, 1.0, 0.05}),
	shadow = require("__base__.prototypes.entity.rocket-projectile-pictures").shadow,
	smoke = require("__base__.prototypes.entity.rocket-projectile-pictures").smoke,
},
{

	type = "projectile",
	name = "w93-fragmentation-cannon-projectile",
	flags = {"not-on-map"},

	hidden = true,
	collision_box = {{-0.3, -1.1}, {0.3, 1.1}},
	acceleration = 0,
	force_condition = "not-same",
	hit_collision_mask = {layers={object=true, player=true, train=true, trigger_target=true}},
	action =

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
,
				{

					type = "nested-result",

					action =
					{

						type = "area",
						radius = 1.0,
						action_delivery =
						{

							type = "instant",
							target_effects =

							{

								{

									type = "damage",

									damage = {amount = 100, type = "explosion"}
								}
							}

						}

					}

				}
			}
		}
	},
	final_action =

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
						entity_name = "small-scorchmark-tintable",

						check_buildability = true
					}

				}
			}
		},
		{
			type = "cluster",
			cluster_count = 36,
			distance = 5,
			distance_deviation = 4,
			action_delivery =
			{
				type = "projectile",
				projectile = "shotgun-pellet",
				max_range = 5,
				range_deviation = 0.8,
				direction_deviation = 1.0,
				starting_speed = 1.0,
				starting_speed_deviation = 1.0
			}
		}
	},
	animation =

	{
		filename = "__base__/graphics/entity/bullet/bullet.png",
		draw_as_glow = true,

		width = 3,
		height = 50,
		priority = "high"
	}

}})
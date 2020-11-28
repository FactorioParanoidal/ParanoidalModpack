data:extend(
{

{
	type = "projectile",
	name = "w93-uranium-shotgun-pellet",

	flags = {"not-on-map"},

	collision_box = {{-0.05, -0.25}, {0.05, 0.25}},
	acceleration = 0,
	piercing_damage = 100,
	direction_only = true,
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
	acceleration = 0.005,

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
					entity_name = "explosion-hit"
				},
				{

					type = "damage",

					damage = {amount = 120, type = "physical"}
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
									sticker = "slowdown-sticker"

								}
							}

						}

					}

				}
			}
		}
	},
	light =
	{	intensity = 0.5,
		size = 4
	},
	animation =
	{

		filename = "__base__/graphics/entity/rocket/rocket.png",

		frame_count = 8,
		line_length = 8,
		width = 9,
		height = 35,
		shift = {0, 0},

		priority = "high"
	},

	shadow =
	{

		filename = "__base__/graphics/entity/rocket/rocket-shadow.png",
		frame_count = 1,
		width = 7,

		height = 24,
		priority = "high",
		shift = {0, 0}
	},

	smoke =
	{

		{

			name = "smoke-fast",
			deviation = {0.15, 0.15},

			frequency = 1,

			position = {0, -1},
			slow_down_factor = 1,
			starting_frame = 3,
			starting_frame_deviation = 5,

			starting_frame_speed = 0,

			starting_frame_speed_deviation = 5
		}

	}

}})
data:extend({
{	type = "ammo",
	name = "w93-slowdown-magazine",
	icon = "__scattergun_turret__/graphics/icons/slowdown-magazine.png",
	icon_size = 64,
	icon_mipmaps = 4,
	flags = {},
	ammo_type =

	{

		category = "bullet",

		action =

		{
			type = "direct",

			action_delivery =
			{
				type = "instant",
				source_effects =
				{
					type = "create-explosion",
					entity_name = "explosion-gunshot"
				},

				target_effects =
				{

					{
						type = "create-entity",
						entity_name = "explosion-hit"
					},
					{

						type = "damage",
						damage = { amount = 12, type = "physical" }
					},
					{
						type = "create-sticker",
						sticker = "slowdown-sticker-small"
,
						show_in_tooltip = true
					},
				}

			}
		}

	},
	magazine_size = 10,

	subgroup = "modular-turrets3-combat",
	order = "l[modular-turrets3-combat]-a[w93-slowdown-magazine]",
	stack_size = 200
},
{

	type = "ammo",

	name = "w93-uranium-shotgun-shell",
	icon = "__scattergun_turret__/graphics/icons/uranium-shotgun-shell.png",
	icon_size = 64,
	icon_mipmaps = 4,
	flags = {},
	ammo_type =

	{
		category = "shotgun-shell",

		target_type = "direction",
		clamp_position = true,

		action =
		{
			{

				type = "direct",

				action_delivery =
				{
					type = "instant",
					source_effects =
					{
						{

							type = "create-explosion",

							entity_name = "explosion-gunshot"
						}

					}

				}

			},
			{
				type = "direct",

				repeat_count = 16,
				action_delivery =

				{

					type = "projectile",
					projectile = "w93-uranium-shotgun-pellet",
					starting_speed = 1,
					direction_deviation = 0.3,

					range_deviation = 0.3,

					max_range = 15

				}

			}

		}
	},

	magazine_size = 10,

	subgroup = "ammo",
	order = "b[shotgun]-c[uranium]",
	stack_size = 200
},
{

	type = "ammo",
	name = "w93-turret-slowdown-shells",
	icon = "__scattergun_turret__/graphics/icons/slowdown-cannon-shells.png",
	icon_size = 64,
	icon_mipmaps = 4,
	flags = {},
	ammo_type =

	{
		category = "cannon-shell",
		action =

		{

			type = "direct",

			action_delivery =

			{

				type = "instant",
				source_effects =

				{

					type = "create-explosion",
					entity_name = "explosion-gunshot"

				},
				target_effects =
				{
					{

						type = "create-entity",

						entity_name = "big-explosion"
					},

					{
						type = "nested-result",
						action =
						{
							type = "area",
							radius = 4,
							action_delivery =
							{
								type = "instant",
								target_effects =
								{
									{
										type = "damage",
										damage = { amount = 80, type = "explosion" },
									},
									{
										type = "create-sticker",
										sticker = "slowdown-sticker-medium"
,
										show_in_tooltip = true
									},
								},
							},
						},
					},
				}
,
			}
,
		},
	},
	magazine_size = 6,
	subgroup = "modular-turrets3-combat",
	order = "l[modular-turrets3-combat]-d[w93-turret-slowdown-shells]",
	stack_size = 200
},
{

	type = "ammo",
	name = "w93-turret-cannon-shells",
	icon = "__scattergun_turret__/graphics/icons/turret-cannon-shells.png",
	icon_size = 64,
	icon_mipmaps = 4,
	flags = {},
	ammo_type =

	{
		category = "cannon-shell",
		cooldown_modifier = 1.25,
		action =

		{

			type = "direct",

			action_delivery =

			{

				type = "instant",
				source_effects =

				{

					type = "create-explosion",
					entity_name = "explosion-gunshot"

				},
				target_effects =
				{
					{

						type = "create-entity",

						entity_name = "big-explosion"
					},

					{
						type = "nested-result",
						action =
						{
							type = "area",
							radius = 4,
							action_delivery =
							{
								type = "instant",
								target_effects =
								{
									type = "damage",
									damage = { amount = 120, type = "explosion" },
								},
							},
						},
					},
				}
,
			}
,
		},
	},
	magazine_size = 6,
	subgroup = "modular-turrets3-combat",
	order = "l[modular-turrets3-combat]-e[w93-turret-cannon-shells]",
	stack_size = 200
},
{

	type = "ammo",
	name = "w93-turret-light-uranium-cannon-shells",
	icon = "__scattergun_turret__/graphics/icons/turret-light-uranium-cannon-shells.png",
	icon_size = 64,
	icon_mipmaps = 4,
	flags = {},
	ammo_type =

	{
		category = "cannon-shell",
		action =

		{

			type = "direct",

			action_delivery =

			{

				type = "instant",
				source_effects =

				{

					type = "create-explosion",
					entity_name = "explosion-gunshot"

				},
				target_effects =
				{
					{

						type = "create-entity",

						entity_name = "explosion"
					},

					{
						type = "damage",
						damage = { amount = 200, type = "physical" },
					},
				}
,
			}
,
		},
	},
	magazine_size = 6,
	subgroup = "modular-turrets3-combat",
	order = "l[modular-turrets3-combat]-c[w93-turret-light-uranium-cannon-shells]",
	stack_size = 200
},
{

	type = "ammo",
	name = "w93-turret-uranium-cannon-shells",
	icon = "__scattergun_turret__/graphics/icons/turret-uranium-cannon-shells.png",
	icon_size = 64,
	icon_mipmaps = 4,
	flags = {},
	ammo_type =

	{
		category = "cannon-shell",
		cooldown_modifier = 1.25,
		action =

		{

			type = "direct",

			action_delivery =

			{

				type = "instant",
				source_effects =

				{

					type = "create-explosion",
					entity_name = "explosion-gunshot"

				},
				target_effects =
				{
					{

						type = "create-entity",

						entity_name = "big-explosion"
					},

					{
						type = "nested-result",
						action =
						{
							type = "area",
							radius = 4.25,
							action_delivery =
							{
								type = "instant",
								target_effects =
								{
									type = "damage",
									damage = { amount = 240, type = "explosion" },
								},
							},
						},
					},
				}
,
			}
,
		},
	},
	magazine_size = 6,
	subgroup = "modular-turrets3-combat",
	order = "l[modular-turrets3-combat]-f[w93-turret-uranium-cannon-shells]",
	stack_size = 200
},
{

	type = "ammo",
	name = "w93-turret-rocket",
	icon = "__scattergun_turret__/graphics/icons/turret-rocket.png",
	icon_size = 64,
	icon_mipmaps = 4,
	flags = {},
	ammo_type =

	{
		category = "rocket",
		action =

		{
			type = "direct",

			action_delivery =

			{
				type = "projectile",
				projectile = "rocket",

				starting_speed = 0.9,
				source_effects =

				{
					type = "create-entity",

					entity_name = "explosion-hit"
				}

			}
		}

	},
	magazine_size = 4,
	subgroup = "modular-turrets3-combat",

	order = "l[modular-turrets3-combat]-g[w93-turret-rocket]",

	stack_size = 200
},

{
	type = "ammo",
	name = "w93-turret-explosive-rocket",

	icon = "__scattergun_turret__/graphics/icons/turret-explosive-rocket.png",
	icon_size = 64,
	icon_mipmaps = 4,
	flags = {},

	ammo_type =
	{
		category = "rocket",
		cooldown_modifier = 1.25,
		action =
		{
			type = "direct",

			action_delivery =

			{
				type = "projectile",
				projectile = "explosive-rocket",

				starting_speed = 0.9,
				source_effects =

				{

					type = "create-entity",
					entity_name = "explosion-hit"
				}

			}
		}
	},

	magazine_size = 4,
	subgroup = "modular-turrets3-combat",
	order = "l[modular-turrets3-combat]-h[w93-turret-explosive-rocket]",
	stack_size = 200
},
{
	type = "ammo",
	name = "w93-turret-slowdown-rocket",

	icon = "__scattergun_turret__/graphics/icons/slowdown-turret-rocket.png",
	icon_size = 64,
	icon_mipmaps = 4,
	flags = {},

	ammo_type =
	{
		category = "rocket",
		action =
		{
			type = "direct",

			action_delivery =

			{
				type = "projectile",
				projectile = "slowdown-rocket",

				starting_speed = 0.9,
				source_effects =

				{

					type = "create-entity",
					entity_name = "explosion-hit"
				}

			}
		}
	},

	magazine_size = 4,
	subgroup = "modular-turrets3-combat",
	order = "l[modular-turrets3-combat]-i[w93-turret-slowdown-rocket]",
	stack_size = 200
},
{

	type = "sticker",
	name = "slowdown-sticker-small",
	--icon = "__base__/graphics/icons/slowdown-sticker.png",
	flags = {},

	animation =

	{
		filename = "__base__/graphics/entity/slowdown-sticker/slowdown-sticker.png",

		priority = "extra-high",

		line_length = 5,
		width = 22,
		height = 24,
		frame_count = 50,
		animation_speed = 0.5,
		tint = {r = 1.000, g = 0.663, b = 0.000, a = 0.694}, -- #ffa900b1
		shift = util.by_pixel (2,-1),
		hr_version =
		{

			filename = "__base__/graphics/entity/slowdown-sticker/hr-slowdown-sticker.png",
			line_length = 5,
			width = 42,
			height = 48,
			frame_count = 50,
			animation_speed = 0.5,
			tint = {r = 1.000, g = 0.663, b = 0.000, a = 0.694}, -- #ffa900b1
			shift = util.by_pixel(2, -0.5),

			scale = 0.5
		}
	},

	duration_in_ticks = 5 * 60,

	target_movement_modifier = 0.75

},
{

	type = "sticker",
	name = "slowdown-sticker-medium",
	--icon = "__base__/graphics/icons/slowdown-sticker.png",
	flags = {},

	animation =

	{
		filename = "__base__/graphics/entity/slowdown-sticker/slowdown-sticker.png",

		priority = "extra-high",

		line_length = 5,
		width = 22,
		height = 24,
		frame_count = 50,
		animation_speed = 0.5,
		tint = {r = 1.000, g = 0.663, b = 0.000, a = 0.694}, -- #ffa900b1
		shift = util.by_pixel (2,-1),
		hr_version =
		{

			filename = "__base__/graphics/entity/slowdown-sticker/hr-slowdown-sticker.png",
			line_length = 5,
			width = 42,
			height = 48,
			frame_count = 50,
			animation_speed = 0.5,
			tint = {r = 1.000, g = 0.663, b = 0.000, a = 0.694}, -- #ffa900b1
			shift = util.by_pixel(2, -0.5),

			scale = 0.5
		}
	},

	duration_in_ticks = 10 * 60,

	target_movement_modifier = 0.5

}})
local item_sounds = require("__base__.prototypes.item_sounds")

data:extend({
{	type = "ammo",
	name = "w93-slowdown-magazine",
	icon = "__scattergun_turret__/graphics/icons/slowdown-magazine.png",
	icon_size = 64,
	icon_mipmaps = 4,
	ammo_category = "bullet",

	ammo_type =

	{

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

	subgroup = "ammo",
	order = "a[basic-clips]-ba[slowdown-magazine]",
	inventory_move_sound = item_sounds.ammo_small_inventory_move,
	pick_sound = item_sounds.ammo_small_inventory_pickup,
	drop_sound = item_sounds.ammo_small_inventory_move,
	stack_size = 100,
	weight = 20*kg
},
{

	type = "ammo",

	name = "w93-uranium-shotgun-shell",
	icon = "__scattergun_turret__/graphics/icons/uranium-shotgun-shell.png",
	icon_size = 64,
	icon_mipmaps = 4,
	ammo_category = "shotgun-shell",

	ammo_type =

	{
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
	inventory_move_sound = item_sounds.ammo_small_inventory_move,

	pick_sound = item_sounds.ammo_small_inventory_pickup,
	drop_sound = item_sounds.ammo_small_inventory_move,
	stack_size = 100,
	weight = 40*kg
},
{

	type = "ammo",
	name = "w93-fragmentation-cannon-shell",
	icon = "__scattergun_turret__/graphics/icons/fragmentation-cannon-shell.png",
	icon_size = 64,
	icon_mipmaps = 4,
	ammo_category = "cannon-shell",
	ammo_type =

	{
		target_type = "position",
		action =

		{

			type = "direct",

			action_delivery =

			{

				type = "projectile",
				projectile = "w93-fragmentation-cannon-projectile",
				starting_speed = 1,
				min_range = 5,
				source_effects =

				{

					type = "create-explosion",
					entity_name = "explosion-gunshot"

				},
			}
,
		},
	},
	magazine_size = 1,
	subgroup = "ammo",
	order = "d[cannon-shell]-b[w93-fragmentation-cannon-shell]",
	inventory_move_sound = item_sounds.ammo_large_inventory_move,
	pick_sound = item_sounds.ammo_large_inventory_pickup,
	drop_sound = item_sounds.ammo_large_inventory_move,
	stack_size = 100,
	weight = 20*kg
},
{
	type = "ammo",
	name = "w93-turret-slowdown-rocket",

	icon = "__scattergun_turret__/graphics/icons/slowdown-turret-rocket.png",
	icon_size = 64,
	icon_mipmaps = 4,
	ammo_category = "rocket",
	ammo_type =
	{
		action =
		{
			type = "direct",

			action_delivery =

			{
				type = "projectile",
				projectile = "slowdown-rocket",

				starting_speed = 0.1,
				source_effects =

				{

					type = "create-entity",
					entity_name = "explosion-hit"
				}

			}
		}
	},

	magazine_size = 1,
	subgroup = "ammo",
	order = "d[rocket-launcher]-c[slowdown]",
	inventory_move_sound = item_sounds.ammo_large_inventory_move,
	pick_sound = item_sounds.ammo_large_inventory_pickup,
	drop_sound = item_sounds.ammo_large_inventory_move,
	stack_size = 100,
	weight = 40*kg
},
{

	type = "sticker",
	name = "slowdown-sticker-small",
	hidden = true,
	animation =

	{
		filename = "__base__/graphics/entity/slowdown-sticker/slowdown-sticker.png",
		line_length = 5,
		width = 42,
		height = 48,
		frame_count = 50,
		animation_speed = 0.5,
		tint = {r = 1.000, g = 0.663, b = 0.000, a = 0.694}, -- #ffa900b1
		shift = util.by_pixel(2, -0.5),

		scale = 0.5
	},

	duration_in_ticks = 5 * 60,

	target_movement_modifier = 0.75

},
{

	type = "sticker",
	name = "slowdown-sticker-medium",
	hidden = true,
	animation =

	{
		filename = "__base__/graphics/entity/slowdown-sticker/slowdown-sticker.png",
		line_length = 5,
		width = 42,
		height = 48,
		frame_count = 50,
		animation_speed = 0.5,
		tint = {r = 1.000, g = 0.663, b = 0.000, a = 0.694},
		shift = util.by_pixel(2, -0.5),

		scale = 0.5
	},

	duration_in_ticks = 10 * 60,

	target_movement_modifier = 0.5

}})
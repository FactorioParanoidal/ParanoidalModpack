require ("__base__.prototypes.entity.beams")

data:extend(
{

{
	type = "explosion",
	name = "w93-tlaser",
	flags = {"not-on-map"},
	animation_speed = 3,
	rotate = true,
	beam = true,
	animations =
	{
		{
			filename = "__scattergun_turret__/graphics/entity/projectiles/w93-tlaser.png",
			priority = "extra-high",
			width = 10,
			height = 1,
			frame_count = 6,
		}
	},
	light = {intensity = 1, size = 10},
	smoke = "smoke-fast",
	smoke_count = 2,
	smoke_slow_down_factor = 1
},
{
	type = "explosion",
	name = "w93-beam",
	flags = {"not-on-map"},
	animation_speed = 3,
	rotate = true,
	beam = true,
	animations =
	{
		{
			filename = "__scattergun_turret__/graphics/entity/projectiles/w93-beam.png",
			priority = "extra-high",
			width = 187,
			height = 1,
			frame_count = 6,
		}
	},
	light = {intensity = 1, size = 10},
	smoke = "smoke-fast",
	smoke_count = 2,
	smoke_slow_down_factor = 1
}})

local tc = append_base_electric_beam_graphics(
{
	type = "beam",
	name = "w93-electric-beam",
	flags = {"not-on-map"},
	width = 0.5,
	damage_interval = 20,
	action_triggered_automatically = false,
	action =

	{

		type = "direct",
		action_delivery =
 
		{
			type = "instant",
			target_effects =

			{
				{
					type = "damage",
					damage = { amount = 10, type = "electric"}

				},
				{
					type = "nested-result",
					action =
					{
						type = "area",
						radius = 2.5,
						action_delivery =
						{
							type = "instant",
							target_effects =
							{
								{
									type = "damage",
									damage = { amount = 2, type = "electric"}

								},
								{

									type = "create-particle",

									particle_name = "pole-spark-particle",
									repeat_count = 25,
									tail_length = 30,
									tail_length_deviation = 8,

									tail_width = 5,
									probability = 1,

									initial_height = 0.5,

									initial_vertical_speed = 0.12,
									initial_vertical_speed_deviation = 0.02,
									speed_from_center = 0.12,
									speed_from_center_deviation = 0.12,

									offset_deviation = {{-0.08, -0.08},{0.08, 0.08}}

								},
								{

									type = "create-sticker",
									sticker = "slowdown-sticker"
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
	working_sound =
	{
		sound =

		{
			filename = "__base__/sound/fight/electric-beam.ogg",
			volume = 0.7

		},
		max_sounds_per_type = 4
	}
}, "additive-soft", { "trilinear-filtering" }, nil, nil)

data:extend({tc})
data:extend({
{
	type = "beam",
	name = "w93-plaser-beam",
	flags = {"not-on-map"},
	width = 0.5,
	damage_interval = 5,
	random_target_offset = true,
	action_triggered_automatically = false,
	action =

	{

		type = "direct",
		action_delivery =
 
		{
			type = "instant",
			target_effects =

			{
				{
					type = "damage",
					damage = { amount = 10, type = "laser"}

				},
			}

		}

	},
	head =

	{

		filename = "__base__/graphics/entity/laser-turret/hr-laser-body.png",
		flags = beam_non_light_flags,

		line_length = 8,

		width = 64,

		height = 12,

		frame_count = 8,
		scale = 0.5,
		animation_speed = 0.5,
		blend_mode = "additive",
		tint = {0.66, 0.0, 1.0}

	},
	tail =
	{
		filename = "__base__/graphics/entity/laser-turret/hr-laser-end.png",

		flags = beam_non_light_flags,

		width = 110,
		height = 62,
		frame_count = 8,
		shift = util.by_pixel(11.5, 1),
		scale = 0.5,

		animation_speed = 0.5,
		blend_mode = "additive",
		tint = {0.66, 0.0, 1.0}

	},
	body =
	{
		{

			filename = "__base__/graphics/entity/laser-turret/hr-laser-body.png",

			flags = beam_non_light_flags,
			line_length = 8,

			width = 64,

			height = 12,
			frame_count = 8,

			scale = 0.5,
			animation_speed = 0.5,
			blend_mode = "additive",
			tint = {0.66, 0.0, 1.0}

		}

	},
	light_animations =
	{
		head =
		{
			filename = "__base__/graphics/entity/laser-turret/hr-laser-body-light.png",
			line_length = 8,
			width = 64,
			height = 12,
			frame_count = 8,
			scale = 0.5,

			animation_speed = 0.5,

			tint = {0.66, 0.0, 1.0}

		},
		tail =
		{

			filename = "__base__/graphics/entity/laser-turret/hr-laser-end-light.png",
			width = 110,

			height = 62,
			frame_count = 8,
			shift = util.by_pixel(11.5, 1),
			scale = 0.5,
			animation_speed = 0.5,
			tint = {0.66, 0.0, 1.0}

		},

		body =

		{
			{
				filename = "__base__/graphics/entity/laser-turret/hr-laser-body-light.png",
				line_length = 8,

				width = 64,
				height = 12,
				frame_count = 8,
				scale = 0.5,
				animation_speed = 0.5,
				tint = {0.66, 0.0, 1.0}

			}

		}

	},
	ground_light_animations =

	{
		head =

		{
			filename = "__base__/graphics/entity/laser-turret/laser-ground-light-head.png",
			line_length = 1,
			width = 256,
			height = 256,
			repeat_count = 8,
			scale = 0.5,

			shift = util.by_pixel(-32, 0),

			animation_speed = 0.5,

			tint = {0.66, 0.0, 1.0}

		},

		tail =

		{

			filename = "__base__/graphics/entity/laser-turret/laser-ground-light-tail.png",
			line_length = 1,
			width = 256,
			height = 256,
			repeat_count = 8,
			scale = 0.5,
			shift = util.by_pixel(32, 0),
			animation_speed = 0.5,

			tint = {0.66, 0.0, 1.0}

		},
		body =

		{

			filename = "__base__/graphics/entity/laser-turret/laser-ground-light-body.png",

			line_length = 1,
			width = 64,
			height = 256,

			repeat_count = 8,

			scale = 0.5,
			animation_speed = 0.5,

			tint = {0.66, 0.0, 1.0}

		}

	},
}})
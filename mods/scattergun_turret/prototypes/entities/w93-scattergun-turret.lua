local util = require('util')
local hit_effects = require("__base__.prototypes.entity.hit-effects")

local function scattergun_turret_extension(inputs)
	return
	{
		filename = "__base__/graphics/entity/tank/tank-turret.png",
		priority = "medium",
		line_length = 1,
		width = 179,
		height = 132,
		direction_count = 8,
		frame_count = 1,
		run_mode = inputs.run_mode and inputs.run_mode or "forward",
		shift = util.by_pixel(0, -16),
		scale = 0.5
	}
end

local function scattergun_turret_extension_mask(inputs)
	return
	{
		filename = "__base__/graphics/entity/tank/tank-turret-mask.png",
		flags = { "mask" },
		scale = 0.5,
		line_length = 1,
		width = 72,
		height = 66,
		direction_count = 8,
		frame_count = 1,

		run_mode = inputs.run_mode or "forward",
		shift = util.by_pixel(0, -16),

		apply_runtime_tint = true
	}
end

local function scattergun_turret_extension_shadow(inputs)
	return
	{
		filename = "__base__/graphics/entity/tank/tank-turret-shadow.png",
		priority = "low",
		scale = 0.5,
		line_length = 1,
		width = 193,
		height = 134,
		frame_count = 1,
		draw_as_shadow = true,
		direction_count = 8,
		run_mode = inputs.run_mode and inputs.run_mode or "forward",
		shift = util.by_pixel(18, 2),
	}
end

local function scattergun_turret_attack(inputs)
	return
	{
		layers =
		{
			{
				filename = "__base__/graphics/entity/tank/tank-turret.png",
				priority = "medium",
				line_length = 8,
				width = 179,
				height = 132,
				direction_count = 64,
				frame_count = 1,
				shift = util.by_pixel(0, -16),
				animation_speed = 8,
				scale = 0.5
			},
			{
				filename = "__base__/graphics/entity/tank/tank-turret-mask.png",
				flags = { "mask" },
				scale = 0.5,
				line_length = 8,
				width = 72,
				height = 66,
				direction_count = 64,
				frame_count = 1,

				shift = util.by_pixel(0, -16),

				apply_runtime_tint = true
			},
			{
				filename = "__base__/graphics/entity/tank/tank-turret-shadow.png",
				priority = "low",
				scale = 0.5,
				line_length = 8,
				width = 193,
				height = 134,
				frame_count = 1,
				draw_as_shadow = true,
				direction_count = 64,
				shift = util.by_pixel(18, 2),
			}
		}
	}
end

circuit_connector_definitions["w93-scattergun-turret"] = circuit_connector_definitions.create_vector
(
  universal_connector_template,
  {
    { variation = 26, main_offset = util.by_pixel( 0, 8), shadow_offset = util.by_pixel( 4, 12), show_shadow = true },
    { variation = 26, main_offset = util.by_pixel( 0, 8), shadow_offset = util.by_pixel( 4, 12), show_shadow = true },
    { variation = 26, main_offset = util.by_pixel( 0, 8), shadow_offset = util.by_pixel( 4, 12), show_shadow = true },
    { variation = 26, main_offset = util.by_pixel( 0, 8), shadow_offset = util.by_pixel( 4, 12), show_shadow = true },
    { variation = 26, main_offset = util.by_pixel( 0, 8), shadow_offset = util.by_pixel( 4, 12), show_shadow = true },
    { variation = 26, main_offset = util.by_pixel( 0, 8), shadow_offset = util.by_pixel( 4, 12), show_shadow = true },
    { variation = 26, main_offset = util.by_pixel( 0, 8), shadow_offset = util.by_pixel( 4, 12), show_shadow = true },
    { variation = 26, main_offset = util.by_pixel( 0, 8), shadow_offset = util.by_pixel( 4, 12), show_shadow = true }
  }
)

data:extend({
{
	type = "ammo-turret",
	name = "w93-scattergun-turret",
	icon = "__scattergun_turret__/graphics/icons/scattergun-turret.png",
    	icon_size = 32,
	flags = {"placeable-player", "player-creation", "building-direction-8-way"},
	minable = {mining_time = 0.5, result = "w93-scattergun-turret"},
	max_health = 2000,
	resistances =
	{
		{
			type = "physical",
			decrease = 10,
			percent = 20
		},
		{
			type = "explosion",
			decrease = 0,
			percent = 80,
		},
		{
			type = "acid",
			decrease = 10,
			percent = 20,
		},
		{
			type = "fire",
			decrease = 0,
			percent = 100,
		}
	},
	corpse = "medium-remnants",
	collision_box = {{-0.95, -0.95 }, {0.95, 0.95}},
	selection_box = {{-1, -1 }, {1, 1}},
	damaged_trigger_effect = hit_effects.entity(),
	rotation_speed = 0.015,
	preparing_speed = 0.08,
	folding_speed = 0.08,
	dying_explosion = "medium-explosion",
	inventory_size = 1,
	automated_ammo_count = 3,
	alert_when_attacking = true,
	icon_draw_specification = {scale = 0.7},
	turret_base_has_direction = true,
	folded_animation = 
	{
		layers =
		{
			scattergun_turret_extension{},
			scattergun_turret_extension_mask{},
			scattergun_turret_extension_shadow{}
		}
	},
	preparing_animation = 
	{
		layers =
		{
			scattergun_turret_extension{},
			scattergun_turret_extension_mask{},
			scattergun_turret_extension_shadow{}
		}
	},
	prepared_animation = scattergun_turret_attack{},
	attacking_animation = scattergun_turret_attack{},
	folding_animation = 
	{ 
		layers = 
		{ 
			scattergun_turret_extension{run_mode = "backward"},
			scattergun_turret_extension_mask{run_mode = "backward"},
			scattergun_turret_extension_shadow{run_mode = "backward"}
		}
	},
	graphics_set =
	{
		base_visualisation =
		{
			animation =
			{
				layers =
				{
					{
						filename = "__base__/graphics/entity/gun-turret/gun-turret-base.png",
						priority = "high",
						width = 150,

						height = 118,
						axially_symmetrical = false,
						direction_count = 1,
						frame_count = 1,
						shift = util.by_pixel(0.5, -1),
						scale = 0.5
					},
					{
						filename = "__base__/graphics/entity/gun-turret/gun-turret-base-mask.png",
						flags = { "mask", "low-object" },
						line_length = 1,

						width = 122,
						height = 102,
						axially_symmetrical = false,

						direction_count = 1,
						frame_count = 1,
						shift = util.by_pixel(0, -4.5),
						apply_runtime_tint = true,
						scale = 0.5
					}
				}
			},
		},
	},
	circuit_connector = circuit_connector_definitions["w93-scattergun-turret"],
	circuit_wire_max_distance = default_circuit_wire_max_distance,
	vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
	prepare_range = 20,
	shoot_in_prepare_state = true,
	attack_parameters =
	{
		type = "projectile",
		ammo_category = "shotgun-shell",
		cooldown = 40,
		projectile_creation_distance = 2.0,
		projectile_center = {0.0, 0.5},
		min_range = 0.8,
		range = 15,
		turn_range = 1/3,
		shell_particle =
		{
			name = "shell-particle",
			direction_deviation = 0.1,
			speed = 0.1,
			speed_deviation = 0.03,
			center = {0, 0},
			creation_distance = -1.925,
			starting_frame_speed = 0.2,
			starting_frame_speed_deviation = 0.1
		},
		sound = 
		{
			{
				filename = "__scattergun_turret__/sound/scattergun-turret-fire.ogg",
				volume = 0.55
			}
		}
	},
	call_for_help_radius = 40
}})
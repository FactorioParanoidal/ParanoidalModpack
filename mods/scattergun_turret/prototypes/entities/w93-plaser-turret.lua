local hit_effects = require("__base__.prototypes.entity.hit-effects")

local function plaser_turret_attack(inputs)
	return
	{
		layers =
		{
			{
				filename = "__scattergun_turret__/graphics/entity/hr-modular-turret.png",
				width = 136,
				height = 152,
				run_mode = inputs.run_mode or "forward",
				frame_count = inputs.frame_count or 1,
				direction_count = 36,
				line_length = 6,
				axially_symmetrical = false,
				shift = {0.1, 0.0},
				scale = 0.5
			},
			{
				width = 68,
				height = 76,
				run_mode = inputs.run_mode or "forward",
				frame_count = inputs.frame_count or 1,
				draw_as_shadow = true,
				direction_count = 36,
				shift = {0.3, 0.2},
				stripes =
				{
					{
						filename = "__scattergun_turret__/graphics/entity/modular-turret-shadow-1.png",
          					width_in_frames = inputs.frame_count or 1,
						height_in_frames = 18
					},
					{
						filename = "__scattergun_turret__/graphics/entity/modular-turret-shadow-2.png",
          					width_in_frames = inputs.frame_count or 1,
						height_in_frames = 18
					},
				},
			},
			{
				filename = "__scattergun_turret__/graphics/entity/plaser-turret/hr-plaser-turret-gun.png",
				priority = "very-low",
				width = 172,
				height = 160,
				run_mode = inputs.run_mode or "forward",
				frame_count = inputs.frame_count or 1,
				direction_count = 36,
				line_length = 6,
				axially_symmetrical = false,
				shift = {0.1, -0.2},
				scale = 0.5
			},
		}
	}
end

local function plaser_turret2_attack(inputs)
	return
	{
		layers =
		{
			{
				filename = "__scattergun_turret__/graphics/entity/hr-modular-turret2.png",
				width = 140,
				height = 152,
				run_mode = inputs.run_mode or "forward",
				frame_count = inputs.frame_count or 1,
				direction_count = 36,
				line_length = 6,
				axially_symmetrical = false,
				shift = {0.0, 0.1},
				scale = 0.5
			},
			{
				filename = "__scattergun_turret__/graphics/entity/hr-modular-turret2-mask.png",
				width = 140,
				height = 152,
				run_mode = inputs.run_mode or "forward",
				frame_count = inputs.frame_count or 1,
				direction_count = 36,
				line_length = 6,
				shift = {0.0, 0.1},
				flags = { "mask" },
				apply_runtime_tint = true,
				scale = 0.5
			},
			{
				width = 80,
				height = 60,
				run_mode = inputs.run_mode or "forward",
				frame_count = inputs.frame_count or 1,
				direction_count = 36,
				shift = {0.2, 0.1},
				flags = { "shadow" },
				draw_as_shadow = true,
				stripes =
				{
					{
						filename = "__scattergun_turret__/graphics/entity/modular-turret2-shadow.png",
          					width_in_frames = inputs.frame_count or 1,
						height_in_frames = 18
					},
					{
						filename = "__scattergun_turret__/graphics/entity/modular-turret2-shadow.png",
          					width_in_frames = inputs.frame_count or 1,
						height_in_frames = 18
					},
				},
			},
			{
				filename = "__scattergun_turret__/graphics/entity/plaser-turret/hr-plaser-turret-gun.png",
				priority = "very-low",
				width = 172,
				height = 160,
				run_mode = inputs.run_mode or "forward",
				frame_count = inputs.frame_count or 1,
				direction_count = 36,
				line_length = 6,
				axially_symmetrical = false,
				shift = {0.0, -0.2},
				scale = 0.5
			},
		}
	}
end

data:extend({
{
	type = "electric-turret",
	name = "w93-plaser-turret",
	icon = "__scattergun_turret__/graphics/icons/plaser-turret.png",
    	icon_size = 64,
	flags = {"placeable-player", "player-creation", "building-direction-8-way"},
	minable = {mining_time = 0.5, result = "w93-plaser-turret"},
	max_health = 1500,
	corpse = "medium-remnants",
	collision_box = {{-1.2, -1.2 }, {1.2, 1.2}},
	selection_box = {{-1.3, -1.3 }, {1.3, 1.3}},
	damaged_trigger_effect = hit_effects.entity(),
	rotation_speed = 0.008,
	preparing_speed = 0.8,
	folding_speed = 0.8,
	dying_explosion = "medium-explosion",
	turret_base_has_direction = true,
	energy_source =

	{

		type = "electric",
		buffer_capacity = "10MJ",

		input_flow_limit = "100MW",
		drain = "60kW",

		usage_priority = "secondary-input"
	},
	resistances =
	{
		{
			type = "physical",
			decrease = 5,
			percent = 15
		},
		{
			type = "explosion",
			decrease = 80,
			percent = 50,
		},
		{
			type = "acid",
			decrease = 0,
			percent = 35,
		},
		{
			type = "fire",
			decrease = 0,
			percent = 80,
		}
	},
	folded_animation = plaser_turret_attack{},
	preparing_animation = plaser_turret_attack{},
	prepared_animation = plaser_turret_attack{},
	attacking_animation = plaser_turret_attack{},
	folding_animation = plaser_turret_attack{run_mode = "backward"},

	graphics_set =
	{
		base_visualisation =
		{
			animation =
			{
				layers =
				{
					{
						filename = "__scattergun_turret__/graphics/entity/hr-modular-turret-base.png",
						priority = "high",
						width = 176,
						height = 136,
						axially_symmetrical = false,
						direction_count = 1,
						frame_count = 1,
						shift = {0.0, 0.0},
						scale = 0.5
					},
					{
						filename = "__scattergun_turret__/graphics/entity/hr-modular-turret-base-mask.png",
						flags = { "mask" },
						line_length = 1,
						width = 176,
						height = 136,
						frame_count = 1,
						axially_symmetrical = false,
						direction_count = 1,
						shift = {0.0, 0.0},
						apply_runtime_tint = true,
						scale = 0.5
					}
				}
			}
		}
	},
	fast_replaceable_group = "modular-turret-electric",
	next_upgrade = "w93-plaser-turret",
	circuit_connector = circuit_connector_definitions["w93-turret-base"],
	circuit_wire_max_distance = default_circuit_wire_max_distance,
	starting_attack_sound =
	{
		filename = "__scattergun_turret__/sound/plaser-turret-fire.ogg",
		volume = 0.35
	},
	vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
	prepare_range = 40,
	shoot_in_prepare_state = false,
	attack_parameters =
	{
		type = "beam",
		cooldown = 20,
		min_range = 5,
		range = 40,
		turn_range = 1/6,
		health_penalty = 1.0,
		source_direction_count = 36,

		source_offset = {0, -1},
		damage_modifier = 1.5,
		ammo_category = "laser",
		ammo_type =
		{
			category = "laser",

			energy_consumption = "600kJ",
			action =
			{
				type = "direct",
				action_delivery =
				{
					type = "beam",
					beam = "w93-plaser-beam",
					max_length = 40,
					duration = 2,
					source_offset = {0, -0.38},
				},
			},
		},
	},
	call_for_help_radius = 40
},
{
	type = "electric-turret",
	name = "w93-plaser-turret2",
	icon = "__scattergun_turret__/graphics/icons/plaser-turret2.png",
    	icon_size = 64,
	flags = {"placeable-player", "player-creation", "building-direction-8-way"},
	minable = {mining_time = 0.5, result = "w93-plaser-turret2"},
	max_health = 600,
	corpse = "medium-remnants",
	collision_box = {{-1.2, -1.2 }, {1.2, 1.2}},
	selection_box = {{-1.3, -1.3 }, {1.3, 1.3}},
	damaged_trigger_effect = hit_effects.entity(),
	rotation_speed = 0.016,
	preparing_speed = 0.8,
	folding_speed = 0.8,
	dying_explosion = "medium-explosion",
	turret_base_has_direction = true,
	energy_source =

	{

		type = "electric",
		buffer_capacity = "10MJ",

		input_flow_limit = "100MW",
		drain = "60kW",

		usage_priority = "secondary-input"
	},
	resistances =
	{
		{
			type = "acid",
			decrease = 0,
			percent = 60,
		},
		{
			type = "fire",
			decrease = 0,
			percent = 60,
		}
	},
	folded_animation = plaser_turret2_attack{},
	preparing_animation = plaser_turret2_attack{},
	prepared_animation = plaser_turret2_attack{},
	attacking_animation = plaser_turret2_attack{},
	folding_animation = plaser_turret2_attack{run_mode = "backward"},

	graphics_set =
	{
		base_visualisation =
		{
			animation =
			{
				layers =
				{
					{
						filename = "__scattergun_turret__/graphics/entity/hr-modular-turret2-base.png",
						priority = "high",
						width = 160,
						height = 128,
						axially_symmetrical = false,
						direction_count = 1,
						frame_count = 1,
						shift = {0.0, 0.0},
						scale = 0.5
					},
					{
						filename = "__scattergun_turret__/graphics/entity/hr-modular-turret2-base-mask.png",
						flags = { "mask" },
						line_length = 1,
						width = 160,
						height = 128,
						frame_count = 1,
						axially_symmetrical = false,
						direction_count = 1,
						shift = {0.0, 0.0},
						apply_runtime_tint = true,
						scale = 0.5
					}
				}
			}
		}
	},
	fast_replaceable_group = "modular-turret-electric",
	next_upgrade = "w93-plaser-turret",
	circuit_connector = circuit_connector_definitions["w93-turret-base2"],
	circuit_wire_max_distance = default_circuit_wire_max_distance,
	starting_attack_sound =
	{
		filename = "__scattergun_turret__/sound/plaser-turret-fire.ogg",
		volume = 0.35
	},
	vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
	prepare_range = 45,
	shoot_in_prepare_state = false,
	attack_parameters =
	{
		type = "beam",
		cooldown = 20,
		min_range = 25,
		range = 45,
		turn_range = 1/3,
		health_penalty = 1.0,
		source_direction_count = 36,

		source_offset = {0, -1},
		damage_modifier = 1.5,
		ammo_category = "laser",
		ammo_type =
		{
			category = "laser",

			energy_consumption = "600kJ",
			action =
			{
				type = "direct",
				action_delivery =
				{
					type = "beam",
					beam = "w93-plaser-beam",
					max_length = 45,
					duration = 2,
					source_offset = {0, -0.38},
				},
			},
		},
	},
	call_for_help_radius = 40
}})
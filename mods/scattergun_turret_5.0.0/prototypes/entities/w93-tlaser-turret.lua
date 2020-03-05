local function tlaser_turret_attack(inputs)
	return
	{
		layers =
		{
			{
				width = 68,
				height = 76,
				run_mode = inputs.run_mode or "forward",
				frame_count = inputs.frame_count or 1,
				direction_count = 36,
				axially_symmetrical = false,
				shift = {0.1, 0.0},
				stripes =
				{
					{
						filename = "__scattergun_turret__/graphics/entity/modular-turret-1.png",
          					width_in_frames = inputs.frame_count or 1,
						height_in_frames = 18
					},
					{
						filename = "__scattergun_turret__/graphics/entity/modular-turret-2.png",
          					width_in_frames = inputs.frame_count or 1,
						height_in_frames = 18
					},
				},
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
				priority = "very-low",
				width = 86,
				height = 80,
				run_mode = inputs.run_mode or "forward",
				frame_count = inputs.frame_count or 1,
				direction_count = 36,
				axially_symmetrical = false,
				shift = {0.1, -0.2},
				stripes =
				{
					{
						filename = "__scattergun_turret__/graphics/entity/tlaser-turret/turret-tlaser-1.png",
          					width_in_frames = inputs.frame_count or 1,
						height_in_frames = 18
					},
					{
						filename = "__scattergun_turret__/graphics/entity/tlaser-turret/turret-tlaser-2.png",
          					width_in_frames = inputs.frame_count or 1,
						height_in_frames = 18
					},
				},
			},
			{
				priority = "very-low",
				width = 86,
				height = 80,
				run_mode = inputs.run_mode or "forward",
				frame_count = inputs.frame_count or 1,
				draw_as_shadow = true,
				direction_count = 36,
				shift = {0.3, 0.0},
				stripes =
				{
					{
						filename = "__scattergun_turret__/graphics/entity/tlaser-turret/turret-tlaser-shadow-1.png",
          					width_in_frames = inputs.frame_count or 1,
						height_in_frames = 18
					},
					{
						filename = "__scattergun_turret__/graphics/entity/tlaser-turret/turret-tlaser-shadow-2.png",
          					width_in_frames = inputs.frame_count or 1,
						height_in_frames = 18
					},
				},
			},
		}
	}
end

local function tlaser_turret2_attack(inputs)
	return
	{
		layers =
		{
			{
				width = 70,
				height = 76,
				run_mode = inputs.run_mode or "forward",
				frame_count = inputs.frame_count or 1,
				direction_count = 36,
				axially_symmetrical = false,
				shift = {0.0, 0.1},
				stripes =
				{
					{
						filename = "__scattergun_turret__/graphics/entity/modular-turret2-1.png",
          					width_in_frames = inputs.frame_count or 1,
						height_in_frames = 18
					},
					{
						filename = "__scattergun_turret__/graphics/entity/modular-turret2-2.png",
          					width_in_frames = inputs.frame_count or 1,
						height_in_frames = 18
					},
				},
			},
			{
				width = 70,
				height = 76,
				run_mode = inputs.run_mode or "forward",
				frame_count = inputs.frame_count or 1,
				direction_count = 36,
				shift = {0.0, 0.1},
				flags = { "mask" },
				apply_runtime_tint = true,
				stripes =
				{
					{
						filename = "__scattergun_turret__/graphics/entity/modular-turret2-mask-1.png",
          					width_in_frames = inputs.frame_count or 1,
						height_in_frames = 18
					},
					{
						filename = "__scattergun_turret__/graphics/entity/modular-turret2-mask-2.png",
          					width_in_frames = inputs.frame_count or 1,
						height_in_frames = 18
					},
				},
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
				priority = "very-low",
				width = 86,
				height = 80,
				run_mode = inputs.run_mode or "forward",
				frame_count = inputs.frame_count or 1,
				direction_count = 36,
				axially_symmetrical = false,
				shift = {0.0, -0.2},
				stripes =
				{
					{
						filename = "__scattergun_turret__/graphics/entity/tlaser-turret/turret-tlaser-1.png",
          					width_in_frames = inputs.frame_count or 1,
						height_in_frames = 18
					},
					{
						filename = "__scattergun_turret__/graphics/entity/tlaser-turret/turret-tlaser-2.png",
          					width_in_frames = inputs.frame_count or 1,
						height_in_frames = 18
					},
				},
			},
			{
				priority = "very-low",
				width = 86,
				height = 80,
				run_mode = inputs.run_mode or "forward",
				frame_count = inputs.frame_count or 1,
				draw_as_shadow = true,
				direction_count = 36,
				shift = {0.2, 0.0},
				stripes =
				{
					{
						filename = "__scattergun_turret__/graphics/entity/tlaser-turret/turret-tlaser-shadow-1.png",
          					width_in_frames = inputs.frame_count or 1,
						height_in_frames = 18
					},
					{
						filename = "__scattergun_turret__/graphics/entity/tlaser-turret/turret-tlaser-shadow-2.png",
          					width_in_frames = inputs.frame_count or 1,
						height_in_frames = 18
					},
				},
			},
		}
	}
end

data:extend({
{
	type = "electric-turret",
	name = "w93-tlaser-turret",
	icon = "__scattergun_turret__/graphics/icons/tlaser-turret.png",
    	icon_size = 64,
	flags = {"placeable-player", "player-creation", "building-direction-8-way"},
	minable = {mining_time = 0.5, result = "w93-tlaser-turret"},
	max_health = 1500,
	corpse = "medium-remnants",
	collision_box = {{-1.2, -1.2 }, {1.2, 1.2}},
	selection_box = {{-1.3, -1.3 }, {1.3, 1.3}},
	rotation_speed = 0.003,
	preparing_speed = 0.8,
	folding_speed = 0.8,
	dying_explosion = "medium-explosion",
	turret_base_has_direction = true,
	energy_source =

	{

		type = "electric",
		buffer_capacity = "12MJ",

		input_flow_limit = "120MW",
		drain = "50kW",

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
	folded_animation = tlaser_turret_attack{},
	preparing_animation = tlaser_turret_attack{},
	prepared_animation = tlaser_turret_attack{},
	attacking_animation = tlaser_turret_attack{},
	folding_animation = tlaser_turret_attack{run_mode = "backward"},

	base_picture =
	{
		layers =
		{
			{
				filename = "__scattergun_turret__/graphics/entity/modular-turret-base.png",
				priority = "high",
				width = 88,
				height = 68,
				axially_symmetrical = false,
				direction_count = 1,
				frame_count = 1,
				shift = {0.0, 0.0},
			},
			{
				filename = "__scattergun_turret__/graphics/entity/modular-turret-base-mask.png",
				flags = { "mask" },
				line_length = 1,
				width = 88,
				height = 68,
				frame_count = 1,
				axially_symmetrical = false,
				direction_count = 1,
				shift = {0.0, 0.0},
				apply_runtime_tint = true
			}
		}
	},

	vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
	prepare_range = 45,
	shoot_in_prepare_state = false,
	attack_parameters =
	{
		type = "projectile",
		ammo_category = "electric",
		cooldown = 90,
		projectile_creation_distance = 1.6,
		projectile_center = {0.0, 0.4},
		min_range = 10,
		range = 35,
		ammo_type =
		{
        		target_type = "entity",

			category = "laser-turret",

			energy_consumption = "4MJ",
			action =
			{
				type = "direct",
				action_delivery =
				{
					type = "instant",
					target_effects =
					{
						{
							type = "create-explosion",
							entity_name = "w93-tlaser"
						},
						{
							type = "damage",
							damage = { amount = 120, type="fire"}
						},
					},
				},
			},
		},
		sound = 
		{
			{
				filename = "__scattergun_turret__/sound/tlaser-turret-fire.ogg",
				volume = 0.75
			}
		}
	},
	call_for_help_radius = 40
},
{
	type = "electric-turret",
	name = "w93-tlaser-turret2",
	icon = "__scattergun_turret__/graphics/icons/tlaser-turret2.png",
    	icon_size = 64,
	flags = {"placeable-player", "player-creation", "building-direction-8-way"},
	minable = {mining_time = 0.5, result = "w93-tlaser-turret2"},
	max_health = 600,
	corpse = "medium-remnants",
	collision_box = {{-1.2, -1.2 }, {1.2, 1.2}},
	selection_box = {{-1.3, -1.3 }, {1.3, 1.3}},
	rotation_speed = 0.006,
	preparing_speed = 0.8,
	folding_speed = 0.8,
	dying_explosion = "medium-explosion",
	turret_base_has_direction = true,
	energy_source =

	{

		type = "electric",
		buffer_capacity = "12MJ",

		input_flow_limit = "120MW",
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
	folded_animation = tlaser_turret2_attack{},
	preparing_animation = tlaser_turret2_attack{},
	prepared_animation = tlaser_turret2_attack{},
	attacking_animation = tlaser_turret2_attack{},
	folding_animation = tlaser_turret2_attack{run_mode = "backward"},

	base_picture =
	{
		layers =
		{
			{
				filename = "__scattergun_turret__/graphics/entity/modular-turret2-base.png",
				priority = "high",
				width = 80,
				height = 64,
				axially_symmetrical = false,
				direction_count = 1,
				frame_count = 1,
				shift = {0.0, 0.0},
			},
			{
				filename = "__scattergun_turret__/graphics/entity/modular-turret2-base-mask.png",
				flags = { "mask" },
				line_length = 1,
				width = 80,
				height = 64,
				frame_count = 1,
				axially_symmetrical = false,
				direction_count = 1,
				shift = {0.0, 0.0},
				apply_runtime_tint = true
			}
		}
	},

	vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
	prepare_range = 47,
	shoot_in_prepare_state = false,
	attack_parameters =
	{
		type = "projectile",
		ammo_category = "electric",
		cooldown = 90,
		projectile_creation_distance = 1.6,
		projectile_center = {0.0, 0.4},
		min_range = 17,
		range = 42,
		ammo_type =
		{
        		target_type = "entity",

			category = "laser-turret",

			energy_consumption = "4MJ",
			action =
			{
				type = "direct",
				action_delivery =
				{
					type = "instant",
					target_effects =
					{
						{
							type = "create-explosion",
							entity_name = "w93-tlaser"
						},
						{
							type = "damage",
							damage = { amount = 120, type="fire"}
						},
					},
				},
			},
		},
		sound = 
		{
			{
				filename = "__scattergun_turret__/sound/tlaser-turret-fire.ogg",
				volume = 0.75
			}
		}
	},
	call_for_help_radius = 40
}})
local function scattergun_turret_extension(inputs)
	return
	{
		filename = "__scattergun_turret__/graphics/entity/scattergun-turret/scattergun-turret.png",
		priority = "medium",
		scale = 1.1,
		line_length = 1,
		width = 92,
		height = 69,
		direction_count = 8,
		frame_count = 1,
		run_mode = inputs.run_mode and inputs.run_mode or "forward",
		shift = {0.055, -0.5},
		axially_symmetrical = false
	}
end

local function scattergun_turret_extension_shadow(inputs)
	return
	{
		filename = "__scattergun_turret__/graphics/entity/scattergun-turret/scattergun-turret-shadow.png",
		scale = 1.1,
		line_length = 1,
		width = 95,
		height = 67,
		frame_count = 1,
		draw_as_shadow = true,
		direction_count = 8,
		run_mode = inputs.run_mode and inputs.run_mode or "forward",
		shift = {0.405, 0.2},
		axially_symmetrical = false,
		draw_as_shadow = true
	}
end

local function scattergun_turret_attack(inputs)
	return
	{
		layers =
		{
			{
				filename = "__scattergun_turret__/graphics/entity/scattergun-turret/scattergun-turret.png",
				scale = 1.1,
				line_length = 8,
				width = 92,
				height = 69,
				frame_count = 1,
				direction_count = 64,
				shift = {0.055, -0.5},
				animation_speed = 8,
			},
			{
				filename = "__scattergun_turret__/graphics/entity/scattergun-turret/scattergun-turret-shadow.png",
				scale = 1.1,
				line_length = 8,
				width = 95,
				height = 67,
				frame_count = 1,
				draw_as_shadow = true,
				direction_count = 64,
				shift = {0.405, 0.2},
			}
		}
	}
end

data:extend({
{
	type = "ammo-turret",
	name = "scattergun-turret",
	icon = "__scattergun_turret__/graphics/icons/scattergun-turret.png",
    	icon_size = 32,
	flags = {"placeable-player", "player-creation", "building-direction-8-way"},
	minable = {mining_time = 0.5, result = "scattergun-turret"},
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
			decrease = 50,
			percent = 65,
		},
		{
			type = "acid",
			decrease = 0,
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
	rotation_speed = 0.015,
	preparing_speed = 0.08,
	folding_speed = 0.08,
	dying_explosion = "medium-explosion",
	inventory_size = 1,
	automated_ammo_count = 5,
	turret_base_has_direction = true,
	folded_animation = 
	{
		layers =
		{
			scattergun_turret_extension{},
			scattergun_turret_extension_shadow{}
		}
	},
	preparing_animation = 
	{
		layers =
		{
			scattergun_turret_extension{},
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
			scattergun_turret_extension_shadow{run_mode = "backward"}
		}
	},
	base_picture =
	{
		layers =
		{
			{
				filename = "__scattergun_turret__/graphics/entity/scattergun-turret/scattergun-turret-base.png",
				priority = "high",
				width = 90,
				height = 75,
				axially_symmetrical = false,
				direction_count = 1,
				frame_count = 1,
				shift = {0.0625, -0.046875},
			},
			{
				filename = "__scattergun_turret__/graphics/entity/scattergun-turret/scattergun-turret-base-mask.png",
				flags = { "mask" },
				line_length = 1,
				width = 52,
				height = 47,
				frame_count = 1,
				axially_symmetrical = false,
				direction_count = 1,
				frame_count = 1,
				shift = {0.0625, -0.234375},
				apply_runtime_tint = true
			}
		}
	},
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
		damage_modifier = 1.5,
		range = 15,
		turn_range = 0.35,
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
				volume = 0.75
			}
		}
	},
	call_for_help_radius = 40
}})
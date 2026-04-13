local sounds = require("__base__.prototypes.entity.sounds")

local max_nuke_shockwave_movement_distance_deviation = 2
local max_nuke_shockwave_movement_distance = 19 + max_nuke_shockwave_movement_distance_deviation / 6
local nuke_shockwave_starting_speed_deviation = 0.075

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
			filename = "__AtomicArtillery2__/graphics/entity/artillery-projectile/atomic-shell.png",
			width = 64,
			height = 64,
			scale = 0.5,
		},
		shadow =
		{
			filename = "__base__/graphics/entity/artillery-projectile/shell-shadow.png",
			width = 64,
			height = 64,
			scale = 0.5,
		},
		chart_picture =
		{
			filename = "__AtomicArtillery2__/graphics/entity/artillery-projectile/atomic-artillery-shoot-map-visualization.png",
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
				--Damage effects				
				{
					type = "nested-result",
					action = 
					{
						radius = 35, --same size as the shockwave to follow, needed to get auto-targeting to space shots correctly. Switched to fire because the thermal pulse is also a thing on nukes.
						--Finally, by having this here, you get the radar update with everything dying like you expect with a nuke.
						type = "area",
						action_delivery = {
							type = "instant",
							target_effects = {
								{
									type = "damage",
									damage = { amount = 1500, type = "fire" },
								},
							},
						},
					},
				},
				{
				  type = "destroy-cliffs",
				  radius = 9,
				  explosion = "explosion"
				},
				{
				  type = "nested-result",
				  action =
				  {
					type = "area",
					target_entities = false,
					trigger_from_target = true,
					repeat_count = 1000,
					radius = 35,
					action_delivery =
					{
					  type = "projectile",
					  projectile = "atomic-bomb-wave",
					  starting_speed = 0.5 * 0.7,
					  starting_speed_deviation = nuke_shockwave_starting_speed_deviation,
					}
				  }
				},
				{
				  type = "nested-result",
				  action =
				  {
					type = "area",
					target_entities = false,
					trigger_from_target = true,
					repeat_count = 1000,
					radius = 7,
					action_delivery =
					{
					  type = "projectile",
					  projectile = "atomic-bomb-ground-zero-projectile",
					  starting_speed = 0.6 * 0.8,
					  starting_speed_deviation = nuke_shockwave_starting_speed_deviation,
					}
				  }
				},
				--Sound effects
				{
				  type = "play-sound",
				  sound = sounds.nuclear_explosion_aftershock(0.4),
				  play_on_target_position = false,
				  -- min_distance = 200,
				  max_distance = 1000,
				  -- volume_modifier = 1,
				  audible_distance_modifier = 3
				},
				{
				  type = "play-sound",
				  sound = sounds.nuclear_explosion(0.9),
				  play_on_target_position = false,
				  -- min_distance = 200,
				  max_distance = 1000,
				  -- volume_modifier = 1,
				  audible_distance_modifier = 3
				},
				--Graphical effects
				{
				  type = "set-tile",
				  tile_name = "nuclear-ground",
				  radius = 12,
				  apply_projection = true,
				  tile_collision_mask = { layers = {water_tile=true} },
				},
				{
				  type = "create-entity",
				  entity_name = "nuke-explosion"
				},
				{
				  type = "camera-effect",
				  effect = "screen-burn",
				  duration = 60,
				  ease_in_duration = 5,
				  ease_out_duration = 60,
				  delay = 0,
				  strength = 6,
				  full_strength_max_distance = 200,
				  max_distance = 800
				},
				{
				  type = "create-entity",
				  entity_name = "huge-scorchmark",
				  check_buildability = true,
				},
				{
				  type = "invoke-tile-trigger",
				  repeat_count = 1,
				},
				{
				  type = "destroy-decoratives",
				  include_soft_decoratives = true, -- soft decoratives are decoratives with grows_through_rail_path = true
				  include_decals = true,
				  invoke_decorative_trigger = true,
				  decoratives_with_trigger_only = false, -- if true, destroys only decoratives that have trigger_effect set
				  radius = 14 -- large radius for demostrative purposes
				},
				{
				  type = "create-decorative",
				  decorative = "nuclear-ground-patch",
				  spawn_min_radius = 11.5,
				  spawn_max_radius = 12.5,
				  spawn_min = 30,
				  spawn_max = 40,
				  apply_projection = true,
				  spread_evenly = true
				},
				{
				  type = "nested-result",
				  action =
				  {
					type = "area",
					show_in_tooltip = false,
					target_entities = false,
					trigger_from_target = true,
					repeat_count = 1000,
					radius = 26,
					action_delivery =
					{
					  type = "projectile",
					  projectile = "atomic-bomb-wave-spawns-cluster-nuke-explosion",
					  starting_speed = 0.5 * 0.7,
					  starting_speed_deviation = nuke_shockwave_starting_speed_deviation,
					}
				  }
				},
				{
				  type = "nested-result",
				  action =
				  {
					type = "area",
					show_in_tooltip = false,
					target_entities = false,
					trigger_from_target = true,
					repeat_count = 700,
					radius = 4,
					action_delivery =
					{
					  type = "projectile",
					  projectile = "atomic-bomb-wave-spawns-fire-smoke-explosion",
					  starting_speed = 0.5 * 0.65,
					  starting_speed_deviation = nuke_shockwave_starting_speed_deviation,
					}
				  }
				},
				{
				  type = "nested-result",
				  action =
				  {
					type = "area",
					show_in_tooltip = false,
					target_entities = false,
					trigger_from_target = true,
					repeat_count = 1000,
					radius = 8,
					action_delivery =
					{
					  type = "projectile",
					  projectile = "atomic-bomb-wave-spawns-nuke-shockwave-explosion",
					  starting_speed = 0.5 * 0.65,
					  starting_speed_deviation = nuke_shockwave_starting_speed_deviation,
					}
				  }
				},
				{
				  type = "nested-result",
				  action =
				  {
					type = "area",
					show_in_tooltip = false,
					target_entities = false,
					trigger_from_target = true,
					repeat_count = 300,
					radius = 26,
					action_delivery =
					{
					  type = "projectile",
					  projectile = "atomic-bomb-wave-spawns-nuclear-smoke",
					  starting_speed = 0.5 * 0.65,
					  starting_speed_deviation = nuke_shockwave_starting_speed_deviation,
					}
				  }
				},
				{
				  type = "nested-result",
				  action =
				  {
					type = "area",
					show_in_tooltip = false,
					target_entities = false,
					trigger_from_target = true,
					repeat_count = 10,
					radius = 8,
					action_delivery =
					{
					  type = "instant",
					  target_effects =
					  {
						{
						  type = "create-entity",
						  entity_name = "nuclear-smouldering-smoke-source",
						  tile_collision_mask = { layers = {water_tile=true}, }
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
}
)
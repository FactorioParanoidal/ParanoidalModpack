local sounds = require("__base__/prototypes/entity/sounds.lua")

local bm_Fire = table.deepcopy(data.raw["fire"]["fire-flame"])
bm_Fire.name = "bm_Fire"
bm_Fire.initial_lifetime = 700
bm_Fire.damage_per_tick = { amount = 100 / 60, type = "fire" }
bm_Fire.on_fuel_added_action = nil
bm_Fire.damage_multiplier_decrease_per_tick = 0.0005
bm_Fire.maximum_damage_multiplier = 1
bm_Fire.fade_out_duration = 60
bm_Fire.lifetime_increase_by = 0


local boss_scale = 3.5



function fire_stream(data)
  return
  {
    type = "stream",
    name = data.name,
    flags = {"not-on-map"},
    stream_light = {intensity = 1, size = 6}, -----
    ground_light = {intensity = 0.8, size = 6}, ---
    particle_buffer_size = 90,
    particle_spawn_interval = data.particle_spawn_interval,
    particle_spawn_timeout = data.particle_spawn_timeout,
    particle_vertical_acceleration = 0.005 * 0.60 *1.5, --x
    particle_horizontal_speed = 0.2* 0.75 * 1.5 * 1.5, --x
    particle_horizontal_speed_deviation = 0.005 * 0.70,
    particle_start_alpha = 0.5,
    particle_end_alpha = 1,
    particle_alpha_per_part = 0.8,
    particle_scale_per_part = 0.8,
    particle_loop_frame_count = 15,
    --particle_fade_out_threshold = 0.95,
    particle_fade_out_duration = 2, 
    particle_loop_exit_threshold = 0.25,
    special_neutral_target_damage = {amount = 1, type = "acid"},
    initial_action =
    {
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            {
              type = "play-sound",
              sound =
              {
                {
                  filename = "__base__/sound/creatures/projectile-acid-burn-1.ogg",
                  volume = 0.8
                },
                {
                  filename = "__base__/sound/creatures/projectile-acid-burn-2.ogg",
                  volume = 0.8
                },
                {
                  filename = "__base__/sound/creatures/projectile-acid-burn-long-1.ogg",
                  volume = 0.8
                },
                {
                  filename = "__base__/sound/creatures/projectile-acid-burn-long-2.ogg",
                  volume = 0.8
                }
              }
            },
            {
              type = "create-fire",
              entity_name = data.splash_fire_name,
              tile_collision_mask = { "water-tile" },
              show_in_tooltip = true			  
            },
            {
              type = "create-entity",
              entity_name = "water-splash",
              tile_collision_mask = { "ground-tile" }
            },
			{
			  type = "create-fire",
			  entity_name = "bm_Fire",
			  initial_ground_flame_count = 30,
			  tile_collision_mask = { "water-tile" }
			},	


          }
        }
      },
      {
        type = "area",
        radius = data.spit_radius,
        force = "enemy",
        ignore_collision_condition = true,
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            {
              type = "create-sticker",
              sticker = data.sticker_name
            },
            {
              type = "damage", --added so it can break stones
              damage = {amount = 10, type = "physical"}
            },
            {
              type = "damage",
              damage = {amount = 20, type = "fire"}
            }			
          }
        }
      }
    },
    particle = {
      filename = "__base__/graphics/entity/acid-projectile/acid-projectile-head.png",
      line_length = 5,
      width = 22,
      height = 84,
      frame_count = 15,
      shift = util.mul_shift(util.by_pixel(-2, 30), data.scale),
      tint = data.tint,
      priority = "high",
      scale = data.scale,
      animation_speed = 1,
      hr_version =
      {
        filename = "__base__/graphics/entity/acid-projectile/hr-acid-projectile-head.png",
        line_length = 5,
        width = 42,
        height = 164,
        frame_count = 15,
        shift = util.mul_shift(util.by_pixel(-2, 31), data.scale),
        tint = data.tint,
        priority = "high",
        scale = 0.5 * data.scale,
        animation_speed = 1,
      }
    },
    spine_animation = {
      filename = "__base__/graphics/entity/acid-projectile/acid-projectile-tail.png",
      line_length = 5,
      width = 66,
      height = 12,
      frame_count = 15,
      shift = util.mul_shift(util.by_pixel(0, -2), data.scale),
      tint = data.tint,
      priority = "high",
      scale = data.scale,
      animation_speed = 1,
      hr_version =
      {
        filename = "__base__/graphics/entity/acid-projectile/hr-acid-projectile-tail.png",
        line_length = 5,
        width = 132,
        height = 20,
        frame_count = 15,
        shift = util.mul_shift(util.by_pixel(0, -1), data.scale),
        tint = data.tint,
        priority = "high",
        scale = 0.5 * data.scale,
        animation_speed = 1,
      }
    },
    shadow = {
      filename = "__base__/graphics/entity/acid-projectile/acid-projectile-shadow.png",
      line_length = 15,
      width = 22,
      height = 84,
      frame_count = 15,
      priority = "high",
      shift = util.mul_shift(util.by_pixel(-2, 30), data.scale),
      draw_as_shadow = true,
      scale = data.scale,
      animation_speed = 1,
      hr_version =
      {
        filename = "__base__/graphics/entity/acid-projectile/hr-acid-projectile-shadow.png",
        line_length = 15,
        width = 42,
        height = 164,
        frame_count = 15,
        shift = util.mul_shift(util.by_pixel(-2, 31), data.scale),
        draw_as_shadow = true,
        priority = "high",
        scale = 0.5 * data.scale,
        animation_speed = 1,
      }
    },

    oriented_particle = true,
    shadow_scale_enabled = true,
  }
end

function fire_stream_cluster(data)
  return
  {
    type = "stream",
    name = data.name,
    flags = {"not-on-map"},
    stream_light = {intensity = 1, size = 4}, -----
    ground_light = {intensity = 0.8, size = 4}, ---
    particle_buffer_size = 90,
    particle_spawn_interval = data.particle_spawn_interval,
    particle_spawn_timeout = data.particle_spawn_timeout,
    particle_vertical_acceleration = 0.005 * 0.60 *1.5, --x
    particle_horizontal_speed = 0.2* 0.75 * 1.5 * 1.5, --x
    particle_horizontal_speed_deviation = 0.005 * 0.70,
    particle_start_alpha = 0.5,
    particle_end_alpha = 1,
    particle_alpha_per_part = 0.8,
    particle_scale_per_part = 0.8,
    particle_loop_frame_count = 15,
    --particle_fade_out_threshold = 0.95,
    particle_fade_out_duration = 2, 
    particle_loop_exit_threshold = 0.25,
    special_neutral_target_damage = {amount = 1, type = "acid"},
    initial_action =
    {
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            {
              type = "play-sound",
              sound =
              {
                {
                  filename = "__base__/sound/creatures/projectile-acid-burn-1.ogg",
                  volume = 0.8
                },
                {
                  filename = "__base__/sound/creatures/projectile-acid-burn-2.ogg",
                  volume = 0.8
                },
                {
                  filename = "__base__/sound/creatures/projectile-acid-burn-long-1.ogg",
                  volume = 0.8
                },
                {
                  filename = "__base__/sound/creatures/projectile-acid-burn-long-2.ogg",
                  volume = 0.8
                }
              }
            },
            {
              type = "create-fire",
              entity_name = data.splash_fire_name,
              tile_collision_mask = { "water-tile" },
              show_in_tooltip = true			  
            },
            {
              type = "create-entity",
              entity_name = "water-splash",
              tile_collision_mask = { "ground-tile" }
            },
			{
			  type = "create-fire",
			  entity_name = "bm_Fire",
			  initial_ground_flame_count = 30,
			  tile_collision_mask = { "water-tile" }
			},	
			
			{
				type = "nested-result",
				action =
						{
							type = "cluster",
							cluster_count = 5,
							distance = 5,
							distance_deviation = 20,
							action_delivery =
							{
								type = "stream",
								stream = "msi-fire-stream",
								starting_speed = 0.1,
								max_range = 20
							},
						}
			},
          }
        }
      },
      {
        type = "area",
        radius = data.spit_radius,
        force = "enemy",
        ignore_collision_condition = true,
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            {
              type = "create-sticker",
              sticker = data.sticker_name
            },
            {
              type = "damage",
              damage = {amount = 20, type = "fire"}
            },
            {
              type = "damage",
              damage = {amount = 10, type = "physical"}
            }			
          }
        }
      }
    },
    particle = {
      filename = "__base__/graphics/entity/acid-projectile/acid-projectile-head.png",
      line_length = 5,
      width = 22,
      height = 84,
      frame_count = 15,
      shift = util.mul_shift(util.by_pixel(-2, 30), data.scale),
      tint = data.tint,
      priority = "high",
      scale = data.scale,
      animation_speed = 1,
      hr_version =
      {
        filename = "__base__/graphics/entity/acid-projectile/hr-acid-projectile-head.png",
        line_length = 5,
        width = 42,
        height = 164,
        frame_count = 15,
        shift = util.mul_shift(util.by_pixel(-2, 31), data.scale),
        tint = data.tint,
        priority = "high",
        scale = 0.5 * data.scale,
        animation_speed = 1,
      }
    },
    spine_animation = {
      filename = "__base__/graphics/entity/acid-projectile/acid-projectile-tail.png",
      line_length = 5,
      width = 66,
      height = 12,
      frame_count = 15,
      shift = util.mul_shift(util.by_pixel(0, -2), data.scale),
      tint = data.tint,
      priority = "high",
      scale = data.scale,
      animation_speed = 1,
      hr_version =
      {
        filename = "__base__/graphics/entity/acid-projectile/hr-acid-projectile-tail.png",
        line_length = 5,
        width = 132,
        height = 20,
        frame_count = 15,
        shift = util.mul_shift(util.by_pixel(0, -1), data.scale),
        tint = data.tint,
        priority = "high",
        scale = 0.5 * data.scale,
        animation_speed = 1,
      }
    },
    shadow = {
      filename = "__base__/graphics/entity/acid-projectile/acid-projectile-shadow.png",
      line_length = 15,
      width = 22,
      height = 84,
      frame_count = 15,
      priority = "high",
      shift = util.mul_shift(util.by_pixel(-2, 30), data.scale),
      draw_as_shadow = true,
      scale = data.scale,
      animation_speed = 1,
      hr_version =
      {
        filename = "__base__/graphics/entity/acid-projectile/hr-acid-projectile-shadow.png",
        line_length = 15,
        width = 42,
        height = 164,
        frame_count = 15,
        shift = util.mul_shift(util.by_pixel(-2, 31), data.scale),
        draw_as_shadow = true,
        priority = "high",
        scale = 0.5 * data.scale,
        animation_speed = 1,
      }
    },

    oriented_particle = true,
    shadow_scale_enabled = true,
  }
end
	
local fire_tint = {r = 1.0, g = 0.3, b = 0.1, a = 1.000}	





function acid_stream_cluster(data)
  return
  {
    type = "stream",
    name = data.name,
    flags = {"not-on-map"},
    --stream_light = {intensity = 1, size = 4},
    --ground_light = {intensity = 0.8, size = 4},

    particle_buffer_size = 90,
    particle_spawn_interval = data.particle_spawn_interval,
    particle_spawn_timeout = data.particle_spawn_timeout,
    particle_vertical_acceleration = 0.005 * 0.60 *1.5, --x
    particle_horizontal_speed = 0.2* 0.75 * 1.5 * 1.5, --x
    particle_horizontal_speed_deviation = 0.005 * 0.70,
    particle_start_alpha = 0.5,
    particle_end_alpha = 1,
    particle_alpha_per_part = 0.8,
    particle_scale_per_part = 0.8,
    particle_loop_frame_count = 15,
    --particle_fade_out_threshold = 0.95,
    particle_fade_out_duration = 2, 
    particle_loop_exit_threshold = 0.25,
    special_neutral_target_damage = {amount = 1, type = "acid"},
    initial_action =
    {
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            {
              type = "play-sound",
              sound =
              {
                {
                  filename = "__base__/sound/creatures/projectile-acid-burn-1.ogg",
                  volume = 0.8
                },
                {
                  filename = "__base__/sound/creatures/projectile-acid-burn-2.ogg",
                  volume = 0.8
                },
                {
                  filename = "__base__/sound/creatures/projectile-acid-burn-long-1.ogg",
                  volume = 0.8
                },
                {
                  filename = "__base__/sound/creatures/projectile-acid-burn-long-2.ogg",
                  volume = 0.8
                }
              }
            },
            {
              type = "create-fire",
              entity_name = data.splash_fire_name,
              tile_collision_mask = { "water-tile" },
              show_in_tooltip = true				  
            },
            {
              type = "create-entity",
              entity_name = "water-splash",
              tile_collision_mask = { "ground-tile" }
            },			
			{
				type = "nested-result",
				action =
						{
							type = "cluster",
							cluster_count = 5,
							distance = 5,
							distance_deviation = 20,
							action_delivery =
							{
								type = "stream",
								stream = "bm-acid-stream",
								starting_speed = 0.2,
								max_range = 20
							},
						}
			},
          }
        }
      },
      {
        type = "area",
        radius = data.spit_radius,
        force = "enemy",
        ignore_collision_condition = true,
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            {
              type = "create-sticker",
              sticker = data.sticker_name
            },
            {
              type = "damage",
              damage = {amount = 30, type = "acid"}
            }
          }
        }
      }
    },
    particle = {
      filename = "__base__/graphics/entity/acid-projectile/acid-projectile-head.png",
      line_length = 5,
      width = 22,
      height = 84,
      frame_count = 15,
      shift = util.mul_shift(util.by_pixel(-2, 30), data.scale),
      tint = data.tint,
      priority = "high",
      scale = data.scale,
      animation_speed = 1,
      hr_version =
      {
        filename = "__base__/graphics/entity/acid-projectile/hr-acid-projectile-head.png",
        line_length = 5,
        width = 42,
        height = 164,
        frame_count = 15,
        shift = util.mul_shift(util.by_pixel(-2, 31), data.scale),
        tint = data.tint,
        priority = "high",
        scale = 0.5 * data.scale,
        animation_speed = 1,
      }
    },
    spine_animation = {
      filename = "__base__/graphics/entity/acid-projectile/acid-projectile-tail.png",
      line_length = 5,
      width = 66,
      height = 12,
      frame_count = 15,
      shift = util.mul_shift(util.by_pixel(0, -2), data.scale),
      tint = data.tint,
      priority = "high",
      scale = data.scale,
      animation_speed = 1,
      hr_version =
      {
        filename = "__base__/graphics/entity/acid-projectile/hr-acid-projectile-tail.png",
        line_length = 5,
        width = 132,
        height = 20,
        frame_count = 15,
        shift = util.mul_shift(util.by_pixel(0, -1), data.scale),
        tint = data.tint,
        priority = "high",
        scale = 0.5 * data.scale,
        animation_speed = 1,
      }
    },
    shadow = {
      filename = "__base__/graphics/entity/acid-projectile/acid-projectile-shadow.png",
      line_length = 15,
      width = 22,
      height = 84,
      frame_count = 15,
      priority = "high",
      shift = util.mul_shift(util.by_pixel(-2, 30), data.scale),
      draw_as_shadow = true,
      scale = data.scale,
      animation_speed = 1,
      hr_version =
      {
        filename = "__base__/graphics/entity/acid-projectile/hr-acid-projectile-shadow.png",
        line_length = 15,
        width = 42,
        height = 164,
        frame_count = 15,
        shift = util.mul_shift(util.by_pixel(-2, 31), data.scale),
        draw_as_shadow = true,
        priority = "high",
        scale = 0.5 * data.scale,
        animation_speed = 1,
      }
    },

    oriented_particle = true,
    shadow_scale_enabled = true,
  }
end




data:extend(
{

  acid_sticker({
    name = "bm-acid-sticker",
    tint = sticker_tint_behemoth,
    slow_player_movement = 0.5,
    slow_vehicle_speed = 0.5,
    slow_vehicle_friction = 1.5,
    slow_seconds = 5
  }),
  
  acid_splash_fire({
    name = "bm-acid-splash-fire",
    scale = (boss_scale-1),
    tint = splash_tint_worm_behemoth,
    ground_patch_scale = (boss_scale-1) * ground_patch_scale_modifier,
    patch_tint_multiplier = patch_opacity,
    splash_damage_per_tick = 1,
    sticker_name = "bm-acid-sticker"
  }),
  
  acid_stream({
    name = "bm-acid-stream",
    scale = boss_scale-1,
    tint = stream_tint_worm_behemoth,
    corpse_name = "bm-acid-splash",
    spit_radius = stream_radius_worm_behemoth, --2
    particle_spawn_interval = 1,
    particle_spawn_timeout = 6,
    splash_fire_name = "bm-acid-splash-fire",
    sticker_name = "bm-acid-sticker"
  }),

  acid_stream_cluster({
    name = "maf-area-acid-projectile-purple",
    scale = boss_scale,
    tint = stream_tint_worm_behemoth,
    corpse_name = "bm-acid-splash",
    spit_radius = stream_radius_worm_behemoth, --2
    particle_spawn_interval = 1,
    particle_spawn_timeout = 6,
    splash_fire_name = "bm-acid-splash-fire",
    sticker_name = "bm-acid-sticker"
  }),

   	
	
-- FIRE ATTACKS	
	
	
	bm_Fire, 
  
  acid_sticker({
    name = "msi-fire-sticker",
    tint = fire_tint,
    slow_player_movement = 0.5,
    slow_vehicle_speed = 0.5,
    slow_vehicle_friction = 1.5,
    slow_seconds = 5
  }),
  
  acid_splash_fire({
    name = "msi-fire-splash",
    scale = (boss_scale-1),
    tint = fire_tint,
    ground_patch_scale = (boss_scale-1) * ground_patch_scale_modifier,
    patch_tint_multiplier = patch_opacity,
    splash_damage_per_tick = 1,
    sticker_name = "msi-fire-sticker"
  }),

  fire_stream({
    name = "msi-fire-stream",
    scale = boss_scale-1,
    tint = fire_tint,
    corpse_name = "msi-fire-splash-corpse",
    spit_radius = stream_radius_worm_behemoth, --2
    particle_spawn_interval = 1,
    particle_spawn_timeout = 6,
    splash_fire_name = "msi-fire-splash",
    sticker_name = "msi-fire-sticker"
  }),

  fire_stream_cluster({
    name = "maf-cluster-fire-projectile",
    scale = boss_scale,
    tint = fire_tint,
    corpse_name = "msi-fire-splash-corpse",
    spit_radius = stream_radius_worm_behemoth, --2
    particle_spawn_interval = 1,
    particle_spawn_timeout = 6,
    splash_fire_name = "msi-fire-splash",
    sticker_name = "msi-fire-sticker"
  }),


	
  








-- small atomic rocket


  {
    type = "projectile",
    name = "bm-small-atomic-rocket",
    flags = {"not-on-map"},
    acceleration = 0.005,
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
            type = "set-tile",
            tile_name = "nuclear-ground",
            radius = 4,
            apply_projection = true,
            tile_collision_mask = { "water-tile" }
          },
          {
            type = "create-entity",
            entity_name = "nuke-explosion"
          },
          {
            type = "camera-effect",
            effect = "screen-burn",
            duration = 20,
            ease_in_duration = 5,
            ease_out_duration = 20,
            delay = 0,
            strength = 2,
            full_strength_max_distance = 100,
            max_distance = 200
          },
          {
            type = "play-sound",
            sound = sounds.nuclear_explosion(0.8),
            play_on_target_position = false,
            -- min_distance = 200,
            max_distance = 400,
            -- volume_modifier = 1,
            audible_distance_modifier = 2
          },
          {
            type = "play-sound",
            sound = sounds.nuclear_explosion_aftershock(0.3),
            play_on_target_position = false,
            -- min_distance = 200,
            max_distance = 400,
            -- volume_modifier = 1,
            audible_distance_modifier = 2
          },
          {
            type = "damage",
            damage = {amount = 400, type = "explosion"}
          },
          {
            type = "create-entity",
            entity_name = "huge-scorchmark",
            offsets = {{ 0, -0.5 }},
            check_buildability = true
          },
          {
            type = "invoke-tile-trigger",
            repeat_count = 1
          },
          {
            type = "destroy-decoratives",
            include_soft_decoratives = true, -- soft decoratives are decoratives with grows_through_rail_path = true
            include_decals = true,
            invoke_decorative_trigger = true,
            decoratives_with_trigger_only = false, -- if true, destroys only decoratives that have trigger_effect set
            radius = 4 -- large radius for demostrative purposes
          },
          {
            type = "nested-result",
            action =
            {
              type = "area",
              target_entities = false,
              trigger_from_target = true,
              repeat_count = 500,
              radius = 7,
              action_delivery =
              {
                type = "projectile",
                projectile = "atomic-bomb-ground-zero-projectile",
                starting_speed = 0.6 * 0.8,
                starting_speed_deviation = nuke_shockwave_starting_speed_deviation
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
              repeat_count = 500,
              radius = 8,
              action_delivery =
              {
                type = "projectile",
                projectile = "atomic-bomb-wave",
                starting_speed = 0.5 * 0.7,
                starting_speed_deviation = nuke_shockwave_starting_speed_deviation
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
              repeat_count = 500,
              radius = 8,
              action_delivery =
              {
                type = "projectile",
                projectile = "atomic-bomb-wave-spawns-cluster-nuke-explosion",
                starting_speed = 0.5 * 0.7,
                starting_speed_deviation = nuke_shockwave_starting_speed_deviation
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
                    tile_collision_mask = { "water-tile" }
                  }
                }
              }
            }
          }
        }
      }
    },
    --light = {intensity = 0.8, size = 15},
    animation =
    {
      filename = "__base__/graphics/entity/rocket/rocket.png",
      draw_as_glow = true,
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
        position = {0, 1},
        slow_down_factor = 1,
        starting_frame = 3,
        starting_frame_deviation = 5,
        starting_frame_speed = 0,
        starting_frame_speed_deviation = 5
      }
    }
  },










-- mini nuke rocket ammo
  {
    type = "ammo",
    name = "maf-small-atomic-rocket",
	icons= {{icon = "__base__/graphics/icons/atomic-bomb.png",icon_size = 64, scale=0.6}},
    pictures =
    {
      layers =
      {
        {
          size = 64,
          filename = "__base__/graphics/icons/atomic-bomb.png",
          scale = 0.25,
          mipmap_count = 4,
		  scale=0.75,
        },
        {
          draw_as_light = true,
          flags = {"light"},
          size = 64,
          filename = "__base__/graphics/icons/atomic-bomb-light.png",
          scale = 0.25,
          mipmap_count = 4,
		  scale=0.75,
        }
      }
    },
    ammo_type =
    {
      range_modifier = 1.5,
      cooldown_modifier = 5,
      target_type = "position",
      category = "rocket",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "projectile",
          projectile = "bm-small-atomic-rocket",
          starting_speed = 0.05,
          source_effects =
          {
            type = "create-entity",
            entity_name = "explosion-hit"
          }
        }
      }
    },
    subgroup = "ammo",
    order = "d[rocket-launcher]-c[atomic-bomb]m",
    stack_size = 10
  },




})




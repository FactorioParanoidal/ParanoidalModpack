
--Requires space age
require("__space-age__.prototypes.entity.gleba-enemy-animations")
require("sound-util")


  data:extend{
 {
    type = "explosion",
    name = "cyborg_electric_projectile_explosion",
    flags = {"not-on-map"},
    animations =
    {
      {
        filename =  "__base__/graphics/entity/bigass-explosion/bigass-explosion-36f-2.png",
        priority = "high",
        line_length=6,
        width = 1944/6,
        height = 1248/3,
        frame_count = 18,
        animation_speed = 0.2,
        shift = util.by_pixel(0, -5),
        scale=0.35,
		tint={r=0.2,g=0.5,b=1.0, a=1},
        draw_as_glow=true,
      },
    },
    light = {intensity = 1, size = 20, color = {r=1.0, g=1.0, b=1.0}},
    sound ={filename = "__base__/sound/fight/pulse.ogg",volume =1}
  },


    {
      type = "projectile",
      name = "cyborg_strafer_projectile",
      hidden = true,
      flags = {"not-on-map"},
      acceleration = 0.001,
      turn_speed = 0.002,
      max_speed = 1,
      turning_speed_increases_exponentially_with_projectile_speed = true,
      hit_collision_mask = {layers={player=true, train=true, is_object=true}, not_colliding_with_itself=true},
      force_condition = "not-friend", --don't hit allies or trees, rocks, etc
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          target_effects =
          {         -- Chain effect 
            {
              type = "nested-result",
              action =
              {
                type = "direct",
                action_delivery =
                {
                  type = "chain",
                  chain = "chain-tesla-gun-chain",
                }
              }
            },
            {
              type = "nested-result",
              action =
              {
                type = "area",
                radius = 1,
                force = "enemy",
                ignore_collision_condition = true,
                action_delivery =
                {
                  type = "instant",
                  target_effects =
                  {
                    {
                      type = "damage",
                      damage = {amount = 80, type = "electric"}
                    },
                    {
                      type = "create-entity",
                      entity_name = "cyborg_electric_projectile_explosion",
                    }
                  }
                }
              }
            }			
          }
        }
      },
      animation =
      {
        layers = {
			{
			filename = "__mferrari_lib__/graphics/icon/electric_ball.png",
			width = 256,
			height = 256,
			scale = 0.15,
			},
      },
     -- working_sound = sounds.projectile_working_sound,
    }
}}





function make_leg(entity_name, scale, leg_thickness, movement_speed, graphics_definitions, sounds, extra)
  return util.merge{
  {
    type = "spider-leg",
    name = entity_name,
    hidden = true,
    localised_name = {"entity-name.leg"},
    collision_box = {{-0.05, -0.05}, {0.05, 0.05}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    collision_mask = {layers={player=true, train=true, is_object=true}}, -- object not player so can step in water
    -- legs breathe air so that poison works. alternatively, change torsos to collide with poison clouds.
    flags = {"not-repairable"},
    icon = graphics_definitions.icon,
    walking_sound_volume_modifier = sounds.walking_sound_volume_modifier,
    walking_sound_speed_modifier = sounds.walking_sound_speed_modifier,
    target_position_randomisation_distance = 0.25 * scale,
    minimal_step_size = 1 * scale,
    stretch_force_scalar = 1.5,
    initial_movement_speed = 0.06 * movement_speed,
    movement_acceleration = 0.03 * movement_speed,
    max_health = 100,
    base_position_selection_distance = 6 * scale,
    movement_based_position_selection_distance = 4 * scale,
    selectable_in_game = false,
    graphics_set = create_leg_graphics_set(scale * leg_thickness, graphics_definitions)
  }, extra }
end


function make_cyborg_strafer(prefix, scale, health, damage, speed, tints, localised_name)
  local head_mask = tints.head_mask
  local tint_mask = tints.mask
  local tint_mask_thigh = tints.mask_thigh or tint_mask
  local tint_body = tints.body
  local tint_body_thigh = tints.body_thigh or tint_body  -- used on legs 
  local strafer_scale = 1 * scale
  local strafer_head_size = 0.6 * scale
  local strafer_leg_thickness = 0.8
  local strafer_leg_ground_position = {0, -5 * scale}
  local strafer_leg_mount_position = {0, -0.25 * scale}
  local strafer_hip_flexibility = 1
  local strafer_knee_distance_factor = 0.5
  local strafer_knee_height = 1
  local strafer_ankle_height = 0
  local strafer_leg_orientations = {0.85, 0.65, 0.45, 0.25, 0.05}
  local strafer_speed = speed
  local strafer_resistances =
  {
    {
      type = "physical",
      decrease = 4,
      percent = 20 + scale*10
    },
    {
      type = "laser",
      percent = 30 + scale*10
    },
    {
      type = "poison",
      percent = 100
    }
  }

local strafer_leg_part_template_layers =
{
  middle =
  {
    { key = "middle", row = 1 },
    { key = "middle_shadow", row = 1, draw_as_shadow = true },
    { key = "middle_tint", row = 1},
    { key = "reflection_middle", row = 1, draw_as_water_reflection = true }
  }
}

  local strafer_graphics_definitions =
  {
    icon = "__space-age__/graphics/icons/medium-strafer.png",
    leg_lower_part =
    {
      layers = strafer_leg_part_template_layers,
      graphics_properties =
      {
        middle_offset_from_top = 0.01, -- offset length in tiles (= px / 32)
        middle_offset_from_bottom = 0.01
      },

      middle =
      util.sprite_load("__space-age__/graphics/entity/strafer/legs/leg-shin",
      {
        scale=0.5 ,
        direction_count=32,
        multiply_shift=0,
        tint_as_overlay = true,
        tint = tint_body,
        surface = "gleba",
        usage = "enemy"
      }),

      middle_shadow =
      util.sprite_load("__space-age__/graphics/entity/strafer/legs/leg-shin-shadow",
      {
        scale=0.5,
        direction_count=32,
        multiply_shift=0,
        surface = "gleba",
        usage = "enemy"
      }),

      middle_tint =
      util.sprite_load("__space-age__/graphics/entity/strafer/legs/leg-shin-mask",
      {
        scale=0.5,
        direction_count=32,
        multiply_shift=0,
        tint=tint_mask,
        surface = "gleba",
        usage = "enemy"
      }),

      reflection_middle =
      {
        filename = "__space-age__/graphics/entity/strafer/legs/strafer-legs-lower-stretchable-water-reflection.png",
        width = 72,
        height = 384,
        line_length = 1,
        direction_count = 1,
        scale = 0.25,
        shift = util.by_pixel(1 * 0.5, 0)
      }
    },
    leg_upper_part =
    {
      layers = strafer_leg_part_template_layers,
      graphics_properties =
      {
        middle_offset_from_top = 0.01, -- offset length in tiles (= px / 32)
        middle_offset_from_bottom = 0.01
      },

      middle =
      util.sprite_load("__space-age__/graphics/entity/strafer/legs/leg-thigh",
      {
        scale=0.5,
        direction_count=32,
        multiply_shift=0,
        tint_as_overlay = true,
        tint = tint_body_thigh,
        surface = "gleba",
        usage = "enemy"
      }),

      middle_shadow =
      util.sprite_load("__space-age__/graphics/entity/strafer/legs/leg-thigh-shadow",
      {
        scale=0.5,
        direction_count=32,
        multiply_shift=0,
        surface = "gleba",
        usage = "enemy"
      }),
      middle_tint =
      util.sprite_load("__space-age__/graphics/entity/strafer/legs/leg-thigh-mask",
      {
        scale=0.5,
        direction_count=32,
        multiply_shift=0,
        tint=tint_mask_thigh,
        surface = "gleba",
        usage = "enemy"
      }),

      reflection_middle =
      {
        filename = "__space-age__/graphics/entity/strafer/legs/strafer-legs-upper-stretchable-water-reflection.png",
        width = 80,
        height = 256,
        line_length = 1,
        direction_count = 1,
        scale = 0.25,
        shift = util.by_pixel(-4 * 0.5, 0),
        surface = "gleba",
        usage = "enemy"
      }
    },
    leg_joint =
    util.sprite_load("__space-age__/graphics/entity/strafer/legs/leg-knee",
    {
      scale=0.5,
      direction_count=32,
      multiply_shift=0,
      tint_as_overlay = true,
      tint = tint_body,
      surface = "gleba",
      usage = "enemy"
    }),
    leg_joint_tint =
    util.sprite_load("__space-age__/graphics/entity/strafer/legs/leg-knee-mask",
    {
      scale=0.5,
      direction_count=32,
      multiply_shift=0,
      tint_as_overlay = true,
      tint = tint_mask,
      surface = "gleba",
      usage = "enemy"
    }),
    leg_joint_shadow =
    util.sprite_load("__space-age__/graphics/entity/strafer/legs/leg-knee",
    {
      scale=0.5,
      direction_count=32,
      multiply_shift=0,
      draw_as_shadow = true,
      surface = "gleba",
      usage = "enemy"
    })
  }

  local sounds =
  {
    working_sound =
    {
      sound = {category = "enemy", variations = sound_variations("__space-age__/sound/enemies/strafer/strafer-idle-big", 10, 0.6)},
      probability = 1 / (8 * 60), -- average pause between the sound is 8 seconds
    },
    walking_sound_volume_modifier = 1.2,
    walking_sound_speed_modifier = 0.5,
    dying_sound = sound_variations("__space-age__/sound/enemies/strafer/strafer-death-big", 5, 1.0, volume_multiplier("main-menu", 1.21)),
    warcry =
    {
      variations = sound_variations_with_volume_variations("__space-age__/sound/enemies/strafer/strafer-warcry-big", 6, 0.4, 1.0, volume_multiplier("main-menu", 2.9)),
      aggregation = {max_count = 2, remove = true, count_already_playing = true}
    },
    projectile_working_sound = {category = "enemy", filename = "__space-age__/sound/enemies/strafer/strafer-fly.ogg", volume = 0.5},
    projectile_impact = sound_variations("__space-age__/sound/enemies/strafer/fly-impact-big", 5, 0.8),
  }



data:extend({
    make_leg(prefix .. "cyborg_strafer-pentapod-leg", strafer_scale, strafer_leg_thickness, strafer_speed, table.deepcopy(strafer_graphics_definitions), sounds,
    {
      hip_flexibility = strafer_hip_flexibility,
      knee_height = strafer_knee_height, -- tiles, in screen space, above the ground that the knee naturally rests at
      knee_distance_factor = strafer_knee_distance_factor, -- distance from torso, as multiplier of leg length
      ankle_height = 0, -- tiles, in screen space, above the ground, the point at which the leg connects to the foot
    --  upper_leg_dying_trigger_effects = make_pentapod_leg_dying_trigger_effects(prefix .. "strafer-pentapod-leg-die", pentapod_upper_leg_dying_trigger_effect_positions),
     -- lower_leg_dying_trigger_effects = make_pentapod_leg_dying_trigger_effects(prefix .. "strafer-pentapod-leg-die", pentapod_lower_leg_dying_trigger_effect_positions),
      resistances = util.table.deepcopy(strafer_resistances),
    })
})



local strafer= table.deepcopy(data.raw["spider-unit"]["small-strafer-pentapod"])
strafer.name = "cyborg_strafer-" ..prefix 
if localised_name then strafer.localised_name=localised_name end
strafer.icon = "__mferrari_lib__/graphics/icon/cyborg_strafer.png"
strafer.collision_box = scale_box(strafer.collision_box, scale+1)
strafer.selection_box = scale_box(strafer.selection_box, scale+1)
strafer.max_health = health
strafer.max_pursue_distance = 100
strafer.min_pursue_time = 1200
strafer.order = "mf_strafer-"..prefix
strafer.dying_trigger_effect = nil
if string.find(prefix, "boss") then strafer.corpse = "big-strafer-corpse" else strafer.corpse = prefix .. "-strafer-corpse" end
strafer.graphics_set = {
    animation = {
      layers = {
        {
          direction_count = 32,
          filename = "__space-age__/graphics/entity/capture-robot-rocket/capture-robot.png",
			width = 190,
			height = 184,
			--shift = util.by_pixel( 0.0, -66.5),
          line_length = 8,
          scale=0.5 * scale
        },
        {
          direction_count = 32,
          filename = "__space-age__/graphics/entity/capture-robot-rocket/capture-robot-mask.png",
          line_length = 8,
		  scale=0.5 * scale,
			width = 148,
			height = 148,
			--shift = util.by_pixel( 0.0, -73.5),
          tint = head_mask,
          tint_as_overlay = true,
        }
      }
    },
    base_animation = {
      layers = {
        {
          direction_count = 32,
          filename = "__space-age__/graphics/entity/capture-robot-rocket/capture-robot.png",
			width = 190,
			height = 184,
			--shift = util.by_pixel( 0.0, -66.5),
          line_length = 8,
          scale=0.5* scale
        },
      }
    },
    base_render_layer = "higher-object-above",
    render_layer = "under-elevated",
    shadow_animation = {
      direction_count = 32,
      draw_as_shadow = true,
      filename = "__space-age__/graphics/entity/capture-robot-rocket/capture-robot-shadow.png",
		width = 248,
		height = 134,
		shift = util.by_pixel( 30, 9.5),
		line_length = 8,
		scale=0.5* scale
    },
    shadow_base_animation = {
      direction_count = 32,
      draw_as_shadow = true,
      filename = "__space-age__/graphics/entity/capture-robot-rocket/capture-robot-shadow.png",
		width = 248,
		height = 134,
		shift = util.by_pixel(30, 9.5),
		line_length = 8,
		scale=0.5* scale
    },
    water_reflection = {
      pictures = {
        filename = "__space-age__/graphics/entity/strafer/torso/strafer-body-water-reflection.png",
        height = 448,
        scale = 0.5* scale,
        shift = {
          0,
          0
        },
        variation_count = 1,
        width = 448
      }
    }
  }
strafer.attack_parameters.ammo_type.action.action_delivery.projectile = "cyborg_strafer_projectile"
strafer.attack_parameters.damage_modifier = damage
strafer.attack_parameters.cooldown = 150 - damage*20
strafer.attack_parameters.range = 28 + damage*2
strafer.ai_settings = {
    allow_try_return_to_spawner = false,
    destroy_when_commands_fail = false,
    size_in_group = 10,
    strafe_settings = {
      face_target = true,
      ideal_distance = 25 + damage,
      ideal_distance_importance = 0.25,
      ideal_distance_importance_variance = 0.1,
      ideal_distance_tolerance = 2.5,
      ideal_distance_variance = 1+damage,
      max_distance = 33+damage*2
    }
  }
strafer.resistances=strafer_resistances
strafer.absorptions_to_join_attack = {pollution = 15+damage*5}
strafer.spider_engine =
      {
        walking_group_overlap = 0.6,
        legs =
        {
          {
            leg = prefix .. "cyborg_strafer-pentapod-leg",
            mount_position = util.rotate_position(strafer_leg_mount_position, strafer_leg_orientations[1]),
            ground_position = util.rotate_position(strafer_leg_ground_position, strafer_leg_orientations[1]),
            walking_group = 1,
            leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
          },
          {
            leg = prefix .. "cyborg_strafer-pentapod-leg",
            mount_position = util.rotate_position(strafer_leg_mount_position, strafer_leg_orientations[2]),
            ground_position = util.rotate_position(strafer_leg_ground_position, strafer_leg_orientations[2]),
            walking_group = 3,
            leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
          },
          {
            leg = prefix .. "cyborg_strafer-pentapod-leg",
            mount_position = util.rotate_position(strafer_leg_mount_position, strafer_leg_orientations[3]),
            ground_position = util.rotate_position(strafer_leg_ground_position, strafer_leg_orientations[3]),
            walking_group = 5,
            leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
          },
          {
            leg = prefix .. "cyborg_strafer-pentapod-leg",
            mount_position = util.rotate_position(strafer_leg_mount_position, strafer_leg_orientations[4]),
            ground_position = util.rotate_position(strafer_leg_ground_position, strafer_leg_orientations[4]),
            walking_group = 2,
            leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
          },
          {
            leg = prefix .. "cyborg_strafer-pentapod-leg",
            mount_position = util.rotate_position(strafer_leg_mount_position, strafer_leg_orientations[5]),
            ground_position = util.rotate_position(strafer_leg_ground_position, strafer_leg_orientations[5]),
            walking_group = 4,
            leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
          },
        },
      }
data:extend({strafer})
end


--[[
absorptions_to_join_attack = {
    spores = 20
  },
  ai_settings = {
    allow_try_return_to_spawner = true,
    destroy_when_commands_fail = true,
    size_in_group = 4,
    strafe_settings = {
      face_target = true,
      ideal_distance = 23,
      ideal_distance_importance = 0.25,
      ideal_distance_importance_variance = 0.1,
      ideal_distance_tolerance = 2.5,
      ideal_distance_variance = 1,
      max_distance = 33
    }
  },
  attack_parameters = {
    ammo_category = "biological",
    ammo_type = {
      action = {
        action_delivery = {
          max_range = 140,
          projectile = "medium-strafer-projectile",
          starting_speed = 0.2,
          type = "projectile"
        },
        type = "direct"
      }
    },
    cooldown = 120,
    range = 28,
    sound = {
      aggregation = {
        count_already_playing = true,
        max_count = 2,
        remove = true
      },
      variations = {
        {
          filename = "__space-age__/sound/enemies/strafer/fly-projectile-shoot-1.ogg",
          volume = 0.45
        },
        {
          filename = "__space-age__/sound/enemies/strafer/fly-projectile-shoot-2.ogg",
          volume = 0.45
        },
        {
          filename = "__space-age__/sound/enemies/strafer/fly-projectile-shoot-3.ogg",
          volume = 0.45
        },
        {
          filename = "__space-age__/sound/enemies/strafer/fly-projectile-shoot-4.ogg",
          volume = 0.45
        },
        {
          filename = "__space-age__/sound/enemies/strafer/fly-projectile-shoot-5.ogg",
          volume = 0.45
        }
      }
    },
    type = "projectile",
    use_shooter_direction = true
  },
  collision_box = {
    {
      -1.2,
      -1.2
    },
    {
      1.2,
      1.2
    }
  },
  corpse = "medium-strafer-corpse",
  damaged_trigger_effect = {
    damage_type_filters = "fire",
    entity_name = "gleba-enemy-damaged-explosion",
    offset_deviation = {
      {
        -0.5,
        -0.5
      },
      {
        0.5,
        0.5
      }
    },
    offsets = {
      {
        0,
        0
      }
    },
    type = "create-entity"
  },
  distraction_cooldown = 30,
  drawing_box_vertical_extension = 3,
  dying_explosion = "medium-strafer-pentapod-die",
  dying_sound = {
    {
      filename = "__space-age__/sound/enemies/strafer/strafer-death-1.ogg",
      modifiers = {
        type = "main-menu",
        volume_multiplier = 1.21
      },
      volume = 0.7
    },
    {
      filename = "__space-age__/sound/enemies/strafer/strafer-death-2.ogg",
      modifiers = "SERPENT PLACEHOLDER",
      volume = 0.7
    },
    {
      filename = "__space-age__/sound/enemies/strafer/strafer-death-3.ogg",
      modifiers = "SERPENT PLACEHOLDER",
      volume = 0.7
    },
    {
      filename = "__space-age__/sound/enemies/strafer/strafer-death-4.ogg",
      modifiers = "SERPENT PLACEHOLDER",
      volume = 0.7
    },
    {
      filename = "__space-age__/sound/enemies/strafer/strafer-death-5.ogg",
      modifiers = "SERPENT PLACEHOLDER",
      volume = 0.7
    }
  },
  dying_trigger_effect = {
    {
      entity_name = "medium-wriggler-pentapod-premature",
      offsets = {
        {
          x = -0.58778525481902069,
          y = 0.8090169895887783
        },
        {
          x = -0.95105652123062967,
          y = -0.30901699498598911
        },
        {
          x = -0,
          y = -1
        },
        {
          x = 0.95105652123062985,
          y = -0.3090169949859888
        },
        {
          x = 0.58778525481902051,
          y = 0.8090169895887783
        }
      },
      type = "create-entity"
    }
  },
  factoriopedia_simulation = {
    init = "    game.simulation.camera_zoom = 1    game.simulation.camera_position = {0, 0}\n    game.surfaces[1].build_checkerboard{{-40, -40}, {40, 40}}\n\n    enemy = game.surfaces[1].create_entity{name = \"medium-strafer-pentapod\", position = {0, 0}}\n\n    step_0 = function()\n      if enemy.valid then\n          game.simulation.camera_position = {enemy.position.x, enemy.position.y - 0.5}\n      end\n\n      script.on_nth_tick(1, function()\n          step_0()\n      end)\n    end\n\n    step_0()\n  "
  },
  flags = {
    "placeable-player",
    "placeable-enemy",
    "placeable-off-grid",
    "breaths-air",
    "not-repairable"
  },
  graphics_set = {
    animation = {
      layers = {
        {
          direction_count = 32,
          filename = "__space-age__/graphics/entity/capture-robot-rocket/capture-robot.png",
			width = 190,
			height = 184,
			shift = util.by_pixel( 0.0, -66.5),
          line_length = 8,
          scale=0.5
        },
        {
          direction_count = 32,
          filename = "__space-age__/graphics/entity/capture-robot-rocket/capture-robot-mask.png",
          line_length = 8,
		  scale=0.5,
			width = 148,
			height = 148,
			shift = util.by_pixel( 0.0, -73.5),
          tint = {
            175.30000000000001,
            129.09999999999999,
            0.3,
            179.10000000000002
          },
          tint_as_overlay = true,
        }
      }
    },
    base_animation = {
      layers = {
        {
          direction_count = 32,
          filename = "__space-age__/graphics/entity/capture-robot-rocket/capture-robot.png",
			width = 190,
			height = 184,
			shift = util.by_pixel( 0.0, -66.5),
          line_length = 8,
          scale=0.5
        },
      }
    },
    base_render_layer = "higher-object-above",
    render_layer = "under-elevated",
    shadow_animation = {
      direction_count = 64,
      draw_as_shadow = true,
      filename = "__space-age__/graphics/entity/capture-robot-rocket/capture-robot-shadow.png",
		width = 248,
		height = 134,
		shift = util.by_pixel( 86.5, 9.5),
		line_length = 8,
		scale=0.5
    },
    shadow_base_animation = {
      direction_count = 64,
      draw_as_shadow = true,
      filename = "__space-age__/graphics/entity/capture-robot-rocket/capture-robot-shadow.png",
		width = 248,
		height = 134,
		shift = util.by_pixel( 86.5, 9.5),
		line_length = 8,
		scale=0.5
    },
    water_reflection = {
      pictures = {
        filename = "__space-age__/graphics/entity/strafer/torso/strafer-body-water-reflection.png",
        height = 448,
        scale = 0.6,
        shift = {
          0,
          0
        },
        variation_count = 1,
        width = 448
      }
    }
  },
  healing_per_tick = 0.046666666666666661,
  height = 1.5,
  icon = "__space-age__/graphics/icons/medium-strafer.png",
  impact_category = "organic",
  is_military_target = true,
  max_health = 1400,
  max_pursue_distance = 50,
  min_pursue_time = 600,
  name = "mf_robot_spider",
  order = "gleba-b-strafer-1.2",
  resistances = {
    {
      decrease = 2,
      percent = 10,
      type = "physical"
    },
    {
      percent = 50,
      type = "laser"
    }
  },
  selection_box = {
    {
      -1.7999999999999998,
      -1.7999999999999998
    },
    {
      1.7999999999999998,
      1.7999999999999998
    }
  },
  spider_engine = {
    legs = {
      {
        ground_position = {
          x = -4.8541019375326702,
          y = -3.5267115289141233
        },
        leg = "medium-strafer-pentapod-leg",
        leg_hit_the_ground_trigger = {
          {
            offset_deviation = {
              {
                -0.2,
                -0.2
              },
              {
                0.2,
                0.2
              }
            },
            repeat_count = 4,
            smoke_name = "smoke-building",
            speed_from_center = 0.03,
            starting_frame_deviation = 5,
            type = "create-trivial-smoke"
          }
        },
        mount_position = {
          x = -0.24270509687663351,
          y = -0.17633557644570617
        },
        walking_group = 1
      },
      {
        ground_position = {
          x = -4.8541019375326702,
          y = 3.5267115289141233
        },
        leg = "medium-strafer-pentapod-leg",
        leg_hit_the_ground_trigger = {
          {
            offset_deviation = {
              {
                -0.2,
                -0.2
              },
              {
                0.2,
                0.2
              }
            },
            repeat_count = 4,
            smoke_name = "smoke-building",
            speed_from_center = 0.03,
            starting_frame_deviation = 5,
            type = "create-trivial-smoke"
          }
        },
        mount_position = {
          x = -0.24270509687663351,
          y = 0.17633557644570617
        },
        walking_group = 3
      },
      {
        ground_position = {
          x = 1.8541019699159346,
          y = 5.706339127383778
        },
        leg = "medium-strafer-pentapod-leg",
        leg_hit_the_ground_trigger = {
          {
            offset_deviation = {
              {
                -0.2,
                -0.2
              },
              {
                0.2,
                0.2
              }
            },
            repeat_count = 4,
            smoke_name = "smoke-building",
            speed_from_center = 0.03,
            starting_frame_deviation = 5,
            type = "create-trivial-smoke"
          }
        },
        mount_position = {
          x = 0.092705098495796729,
          y = 0.2853169563691889
        },
        walking_group = 5
      },
      {
        ground_position = {
          x = 6,
          y = 0
        },
        leg = "medium-strafer-pentapod-leg",
        leg_hit_the_ground_trigger = {
          {
            offset_deviation = {
              {
                -0.2,
                -0.2
              },
              {
                0.2,
                0.2
              }
            },
            repeat_count = 4,
            smoke_name = "smoke-building",
            speed_from_center = 0.03,
            starting_frame_deviation = 5,
            type = "create-trivial-smoke"
          }
        },
        mount_position = {
          x = 0.3,
          y = 0
        },
        walking_group = 2
      },
      {
        ground_position = {
          x = 1.8541019699159346,
          y = -5.706339127383778
        },
        leg = "medium-strafer-pentapod-leg",
        leg_hit_the_ground_trigger = {
          {
            offset_deviation = {
              {
                -0.2,
                -0.2
              },
              {
                0.2,
                0.2
              }
            },
            repeat_count = 4,
            smoke_name = "smoke-building",
            speed_from_center = 0.03,
            starting_frame_deviation = 5,
            type = "create-trivial-smoke"
          }
        },
        mount_position = {
          x = 0.092705098495796729,
          y = -0.2853169563691889
        },
        walking_group = 4
      }
    },
    walking_group_overlap = 0.6
  },
  sticker_box = {
    {
      -1.2,
      -1.2
    },
    {
      1.2,
      1.2
    }
  },
  subgroup = "enemies",
  torso_rotation_speed = 0.005,
  type = "spider-unit",
  vision_distance = 40,
  warcry = {
    aggregation = {
      count_already_playing = true,
      max_count = 2,
      remove = true
    },
    variations = {
      {
        filename = "__space-age__/sound/enemies/strafer/strafer-warcry-1.ogg",
        max_volume = 0.8,
        min_volume = 0.4,
        modifiers = {
          type = "main-menu",
          volume_multiplier = 2.9
        }
      },
      {
        filename = "__space-age__/sound/enemies/strafer/strafer-warcry-2.ogg",
        max_volume = 0.8,
        min_volume = 0.4,
        modifiers = "SERPENT PLACEHOLDER"
      },
      {
        filename = "__space-age__/sound/enemies/strafer/strafer-warcry-3.ogg",
        max_volume = 0.8,
        min_volume = 0.4,
        modifiers = "SERPENT PLACEHOLDER"
      },
      {
        filename = "__space-age__/sound/enemies/strafer/strafer-warcry-4.ogg",
        max_volume = 0.8,
        min_volume = 0.4,
        modifiers = "SERPENT PLACEHOLDER"
      },
      {
        filename = "__space-age__/sound/enemies/strafer/strafer-warcry-5.ogg",
        max_volume = 0.8,
        min_volume = 0.4,
        modifiers = "SERPENT PLACEHOLDER"
      },
      {
        filename = "__space-age__/sound/enemies/strafer/strafer-warcry-6.ogg",
        max_volume = 0.8,
        min_volume = 0.4,
        modifiers = "SERPENT PLACEHOLDER"
      }
    }
  },
  working_sound = {
    probability = 0.002083333333333333,
    sound = {
      category = "enemy",
      variations = {
        {
          filename = "__space-age__/sound/enemies/strafer/strafer-idle-1.ogg",
          volume = 0.35
        },
        {
          filename = "__space-age__/sound/enemies/strafer/strafer-idle-2.ogg",
          volume = 0.35
        },
        {
          filename = "__space-age__/sound/enemies/strafer/strafer-idle-3.ogg",
          volume = 0.35
        },
        {
          filename = "__space-age__/sound/enemies/strafer/strafer-idle-4.ogg",
          volume = 0.35
        },
        {
          filename = "__space-age__/sound/enemies/strafer/strafer-idle-5.ogg",
          volume = 0.35
        },
        {
          filename = "__space-age__/sound/enemies/strafer/strafer-idle-6.ogg",
          volume = 0.35
        },
        {
          filename = "__space-age__/sound/enemies/strafer/strafer-idle-7.ogg",
          volume = 0.35
        },
        {
          filename = "__space-age__/sound/enemies/strafer/strafer-idle-8.ogg",
          volume = 0.35
        },
        {
          filename = "__space-age__/sound/enemies/strafer/strafer-idle-9.ogg",
          volume = 0.35
        },
        {
          filename = "__space-age__/sound/enemies/strafer/strafer-idle-10.ogg",
          volume = 0.35
        }
      }
    }
  }
}

]]




local gleba_small_mask_tint = {103, 151, 11, 255}
local gleba_small_mask2_tint = {173, 156, 240, 255} -- thighs
local gleba_small_body_tint = {125, 124, 111, 255}

local electric_blue = {201,228,255,255}
local purp_m = {201,130,255,200}


function make_basic_cyborg_strafers()
make_cyborg_strafer("small", 1, 2000, 1, 1,  {
    head_mask = {r=0.4,g=0.3,b=0.9},
    mask = purp_m, 
    mask_thigh = gleba_small_mask2_tint, 
    body = electric_blue,
  }
)

make_cyborg_strafer("medium", 1.25, 5000, 2, 1.5,  {
    head_mask = {r=0.2,g=0.6,b=0.5},
    mask = purp_m, 
    mask_thigh =  {223, 251, 121, 255}, 
    body =electric_blue,
  })


make_cyborg_strafer("big", 1.6, 10000, 3, 2.5,  {
    head_mask = {r=0.6,g=0.2,b=0.7},
    mask = purp_m, 
    mask_thigh =  {223, 251, 121, 255}, 
    body =electric_blue,
  })
end



function make_cyborg_strafer_bosses()
for x=1, 10 do 
make_cyborg_strafer("boss-" ..x, 1.7 + x/20, 15000 *x, 3 + x/8, 2 + x/5,  {
    head_mask = {r=1-x/10, g=0.6 - x/20 ,b=x/10},
    mask = purp_m, 
    mask_thigh =  {223, 251, 121, 255}, 
    body =electric_blue,
  }, {"entity-name.cyborg_strafer-boss"})
end
end
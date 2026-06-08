
local boss_hp_multiplier  = mf_hp_multiplier or 1
local boss_hp_variant     = mf_hp_variant or 1
local boss_dmg_multiplier = mf_dmg_multiplier or 1


local function make_biter_area_damage(level,radius)
return  {
					type = "area",
					radius = radius,
					force = "enemy",
					ignore_collision_condition = true,
					action_delivery =
					{
					  type = "instant",
					  target_effects =
					  {
						{
						  type = "damage",
						  damage = {amount = (30+level*5), type = "physical"}
						},
						{
						type = "create-particle",
						repeat_count = 5,
						particle_name = "explosion-remnants-particle",
						initial_height = 0.5,
						speed_from_center = 0.08,
						speed_from_center_deviation = 0.15,
						initial_vertical_speed = 0.08,
						initial_vertical_speed_deviation = 0.15,
						offset_deviation = {{-0.2, -0.2}, {0.2, 0.2}}
						},
					  }
					}
                   }
end



local function get_wrig_resist(k)
	local base_resist = 20+k*2
	local resistances =  
    {
      {
        type = "physical",
        decrease = k,
        percent = base_resist,
      },
      {
        type = "explosion",
        decrease = k,
        percent = base_resist,
      },
      {
        type = "laser",
        percent = base_resist + 50,
      },
      {
        type = "impact",
        percent = base_resist,
      },

      {
        type = "fire",
        percent = -50-k,
      },
      {
        type = "electric",
        percent = base_resist + 30,
      },
      {
        type = "poison",
        percent = base_resist + 30,
      },
      {
        type = "acid",
        percent = base_resist + 30,
      },
    }
	return resistances
	end




function make_wriggler_boss(name,level, scale)
local damage = (100+level*40)*boss_dmg_multiplier
local wriggler = table.deepcopy( data.raw.unit["big-wriggler-pentapod"])
hack_scale(wriggler, scale)
wriggler.name=name
wriggler.localised_name =  {"",{"entity-name.maf-wriggler-boss"}," ",tostring(level)}
wriggler.factoriopedia_simulation = nil
wriggler.max_health =  (40000 * level^boss_hp_variant) * boss_hp_multiplier/boss_hp_variant
wriggler.loot = get_mf_Loot() 
wriggler.healing_per_tick = 0.1 + level/100
wriggler.collision_box = {{-0.7, -0.7}, {0.7, 0.7}}
wriggler.selection_box = {{-1.2 * (1+level/30) , -1.2* (1+level/30)}, {1.2* (1+level/30), 1.2* (1+level/30)}}
wriggler.distraction_cooldown = 100
wriggler.has_belt_immunity = true
wriggler.resistances = get_wrig_resist(level)

local attack_parameters=wriggler.attack_parameters
attack_parameters.cooldown = 45-level*2
attack_parameters.range = 1.5 + level/2
attack_parameters.ammo_type.action.action_delivery.target_effects[1].damage.amount=damage/2
attack_parameters.ammo_type.action.action_delivery.target_effects[2].damage.amount=damage/2
table.insert (attack_parameters.ammo_type.action,  make_biter_area_damage(level,level+1) )
wriggler.icons = 	{{icon=wriggler.icon}, {icon="__base__/graphics/icons/parameter/parameter-"..(level-1)..".png",icon_size=64,scale=0.4, shift = {10,10}}}

local corpse = table.deepcopy(data.raw.corpse[wriggler.corpse])
hack_scale(corpse, scale)
corpse.name = name .. "-corpse"
corpse.localised_name =  {"",{"entity-name.maf-wriggler-boss-corpse"}," ",tostring(level)}

wriggler.corpse=name .. "-corpse"

data:extend({wriggler,corpse})
end

for x=1,10 do
	make_wriggler_boss("maf-wriggler-boss-" ..x ,x, 2 + x/10)
	end






    --[[
{
  absorptions_to_join_attack = {
    spores = 2
  },
  ai_settings = {
    allow_try_return_to_spawner = true,
    destroy_when_commands_fail = true,
    join_attacks = false
  },
  attack_parameters = {
    ammo_category = "melee",
    ammo_type = {
      action = {
        action_delivery = {
          target_effects = {
            {
              damage = {
                amount = 9,
                type = "physical"
              },
              type = "damage"
            },
            {
              damage = {
                amount = 9,
                type = "poison"
              },
              type = "damage"
            }
          },
          type = "instant"
        },
        type = "direct"
      },
      target_type = "entity"
    },
    animation = {
      layers = {
        {
          animation_speed = 0.47999999999999998,
          direction_count = 16,
          draw_as_shadow = false,
          filenames = {
            "__space-age__/graphics/entity/wriggler/wriggler-attack-1.png",
            "__space-age__/graphics/entity/wriggler/wriggler-attack-2.png",
            "__space-age__/graphics/entity/wriggler/wriggler-attack-3.png",
            "__space-age__/graphics/entity/wriggler/wriggler-attack-4.png",
            "__space-age__/graphics/entity/wriggler/wriggler-attack-5.png"
          },
          flags = {},
          frame_count = 19,
          height = 308,
          line_length = 5,
          lines_per_file = 13,
          scale = 0.6,
          shift = {
            0,
            -0.640625
          },
          slice = 5,
          surface = "gleba",
          tint = {
            117,
            116,
            104,
            255
          },
          tint_as_overlay = true,
          width = 314
        },
        {
          animation_speed = 0.47999999999999998,
          direction_count = 16,
          draw_as_shadow = false,
          filenames = {
            "__space-age__/graphics/entity/wriggler/wriggler-attack-tint-1.png",
            "__space-age__/graphics/entity/wriggler/wriggler-attack-tint-2.png",
            "__space-age__/graphics/entity/wriggler/wriggler-attack-tint-3.png",
            "__space-age__/graphics/entity/wriggler/wriggler-attack-tint-4.png",
            "__space-age__/graphics/entity/wriggler/wriggler-attack-tint-5.png"
          },
          flags = {},
          frame_count = 19,
          height = 308,
          line_length = 5,
          lines_per_file = 13,
          scale = 0.6,
          shift = {
            0,
            -0.640625
          },
          slice = 5,
          surface = "gleba",
          tint = {
            108.5,
            0.5,
            18,
            128.5
          },
          tint_as_overlay = true,
          width = 314
        },
        {
          animation_speed = 0.47999999999999998,
          direction_count = 16,
          draw_as_shadow = true,
          filenames = {
            "__space-age__/graphics/entity/wriggler/wriggler-attack-shadow-1.png",
            "__space-age__/graphics/entity/wriggler/wriggler-attack-shadow-2.png",
            "__space-age__/graphics/entity/wriggler/wriggler-attack-shadow-3.png",
            "__space-age__/graphics/entity/wriggler/wriggler-attack-shadow-4.png"
          },
          frame_count = 19,
          height = 218,
          line_length = 5,
          lines_per_file = 16,
          scale = 0.6,
          shift = {
            0,
            0
          },
          slice = 5,
          surface = "gleba",
          width = 256
        }
      }
    },
    cooldown = 26,
    cooldown_deviation = 0.1,
    range = 1.8,
    range_mode = "bounding-box-to-bounding-box",
    sound = {
      aggregation = {
        count_already_playing = true,
        max_count = 2,
        remove = true
      },
      variations = {
        {
          filename = "__space-age__/sound/enemies/wriggler/wriggler-attack-1.ogg",
          max_volume = 0.7,
          min_volume = 0.25,
          modifiers = {
            type = "main-menu",
            volume_multiplier = 0.7
          }
        },
        {
          filename = "__space-age__/sound/enemies/wriggler/wriggler-attack-2.ogg",
          max_volume = 0.7,
          min_volume = 0.25,
          modifiers = "SERPENT PLACEHOLDER"
        },
        {
          filename = "__space-age__/sound/enemies/wriggler/wriggler-attack-3.ogg",
          max_volume = 0.7,
          min_volume = 0.25,
          modifiers = "SERPENT PLACEHOLDER"
        },
        {
          filename = "__space-age__/sound/enemies/wriggler/wriggler-attack-4.ogg",
          max_volume = 0.7,
          min_volume = 0.25,
          modifiers = "SERPENT PLACEHOLDER"
        },
        {
          filename = "__space-age__/sound/enemies/wriggler/wriggler-attack-5.ogg",
          max_volume = 0.7,
          min_volume = 0.25,
          modifiers = "SERPENT PLACEHOLDER"
        },
        {
          filename = "__space-age__/sound/enemies/wriggler/wriggler-attack-6.ogg",
          max_volume = 0.7,
          min_volume = 0.25,
          modifiers = "SERPENT PLACEHOLDER"
        },
        {
          filename = "__space-age__/sound/enemies/wriggler/wriggler-attack-7.ogg",
          max_volume = 0.7,
          min_volume = 0.25,
          modifiers = "SERPENT PLACEHOLDER"
        },
        {
          filename = "__space-age__/sound/enemies/wriggler/wriggler-attack-8.ogg",
          max_volume = 0.7,
          min_volume = 0.25,
          modifiers = "SERPENT PLACEHOLDER"
        },
        {
          filename = "__space-age__/sound/enemies/wriggler/wriggler-attack-9.ogg",
          max_volume = 0.7,
          min_volume = 0.25,
          modifiers = "SERPENT PLACEHOLDER"
        }
      }
    },
    type = "projectile"
  },
  collision_box = {
    {
      -0.2,
      -0.2
    },
    {
      0.2,
      0.2
    }
  },
  collision_mask = {
    layers = {
      is_object = true,
      player = true,
      train = true
    },
    not_colliding_with_itself = true
  },
  corpse = "big-wriggler-pentapod-corpse",
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
  distance_per_frame = 0.125,
  distraction_cooldown = 300,
  dying_explosion = "big-wriggler-die",
  dying_sound = {
    aggregation = {
      count_already_playing = true,
      max_count = 2,
      remove = true
    },
    variations = {
      {
        filename = "__space-age__/sound/enemies/wriggler/wriggler-death-1.ogg",
        modifiers = {
          type = "main-menu",
          volume_multiplier = 1.5
        },
        volume = 1
      },
      {
        filename = "__space-age__/sound/enemies/wriggler/wriggler-death-2.ogg",
        modifiers = "SERPENT PLACEHOLDER",
        volume = 1
      },
      {
        filename = "__space-age__/sound/enemies/wriggler/wriggler-death-3.ogg",
        modifiers = "SERPENT PLACEHOLDER",
        volume = 1
      },
      {
        filename = "__space-age__/sound/enemies/wriggler/wriggler-death-4.ogg",
        modifiers = "SERPENT PLACEHOLDER",
        volume = 1
      },
      {
        filename = "__space-age__/sound/enemies/wriggler/wriggler-death-5.ogg",
        modifiers = "SERPENT PLACEHOLDER",
        volume = 1
      },
      {
        filename = "__space-age__/sound/enemies/wriggler/wriggler-death-6.ogg",
        modifiers = "SERPENT PLACEHOLDER",
        volume = 1
      },
      {
        filename = "__space-age__/sound/enemies/wriggler/wriggler-death-7.ogg",
        modifiers = "SERPENT PLACEHOLDER",
        volume = 1
      },
      {
        filename = "__space-age__/sound/enemies/wriggler/wriggler-death-8.ogg",
        modifiers = "SERPENT PLACEHOLDER",
        volume = 1
      }
    }
  },
  factoriopedia_simulation = {
    init = "    game.simulation.camera_zoom = 1.8    game.simulation.camera_position = {0, 0}\n    game.surfaces[1].build_checkerboard{{-40, -40}, {40, 40}}\n\n    enemy = game.surfaces[1].create_entity{name = \"big-wriggler-pentapod\", position = {0, 0}}\n\n    step_0 = function()\n      if enemy.valid then\n          game.simulation.camera_position = {enemy.position.x, enemy.position.y - 0.5}\n      end\n\n      script.on_nth_tick(1, function()\n          step_0()\n      end)\n    end\n\n    step_0()\n  "
  },
  flags = {
    "placeable-player",
    "placeable-enemy",
    "placeable-off-grid",
    "not-repairable",
    "breaths-air"
  },
  healing_per_tick = 0.013333333333333333,
  icon = "__space-age__/graphics/icons/big-wriggler.png",
  impact_category = "organic",
  max_health = 400,
  max_pursue_distance = 50,
  min_pursue_time = 600,
  movement_speed = 0.2,
  name = "big-wriggler-pentapod",
  order = "gleba-a-wriggler-1",
  resistances = {
    {
      percent = 50,
      type = "laser"
    }
  },
  run_animation = {
    layers = {
      {
        animation_speed = 0.47999999999999998,
        direction_count = 16,
        draw_as_shadow = false,
        filenames = {
          "__space-age__/graphics/entity/wriggler/wriggler-run-1.png",
          "__space-age__/graphics/entity/wriggler/wriggler-run-2.png",
          "__space-age__/graphics/entity/wriggler/wriggler-run-3.png",
          "__space-age__/graphics/entity/wriggler/wriggler-run-4.png"
        },
        flags = {},
        frame_count = 21,
        height = 228,
        line_length = 5,
        lines_per_file = 17,
        scale = 0.6,
        shift = {
          0,
          -0.171875
        },
        slice = 5,
        surface = "gleba",
        tint = {
          117,
          116,
          104,
          255
        },
        tint_as_overlay = true,
        width = 284
      },
      {
        animation_speed = 0.47999999999999998,
        direction_count = 16,
        draw_as_shadow = false,
        filenames = {
          "__space-age__/graphics/entity/wriggler/wriggler-run-tint-1.png",
          "__space-age__/graphics/entity/wriggler/wriggler-run-tint-2.png",
          "__space-age__/graphics/entity/wriggler/wriggler-run-tint-3.png",
          "__space-age__/graphics/entity/wriggler/wriggler-run-tint-4.png"
        },
        flags = {},
        frame_count = 21,
        height = 226,
        line_length = 5,
        lines_per_file = 17,
        scale = 0.6,
        shift = {
          0,
          -0.171875
        },
        slice = 5,
        surface = "gleba",
        tint = {
          108.5,
          0.5,
          18,
          128.5
        },
        tint_as_overlay = true,
        width = 284
      },
      {
        animation_speed = 0.47999999999999998,
        direction_count = 16,
        draw_as_shadow = true,
        filenames = {
          "__space-age__/graphics/entity/wriggler/wriggler-run-shadow-1.png",
          "__space-age__/graphics/entity/wriggler/wriggler-run-shadow-2.png",
          "__space-age__/graphics/entity/wriggler/wriggler-run-shadow-3.png",
          "__space-age__/graphics/entity/wriggler/wriggler-run-shadow-4.png"
        },
        frame_count = 21,
        height = 198,
        line_length = 5,
        lines_per_file = 17,
        scale = 0.6,
        shift = {
          0.28125,
          0
        },
        slice = 5,
        surface = "gleba",
        width = 316
      }
    }
  },
  running_sound_animation_positions = {
    2
  },
  selection_box = {
    {
      -0.9,
      -0.9
    },
    {
      0.9,
      0.9
    }
  },
  sticker_box = {
    {
      -0.5,
      -0.5
    },
    {
      0.5,
      0.5
    }
  },
  subgroup = "enemies",
  type = "unit",
  vision_distance = 20,
  walking_sound = {
    aggregation = {
      count_already_playing = true,
      max_count = 3,
      remove = true
    },
    variations = {
      {
        filename = "__space-age__/sound/enemies/wriggler/wriggler-walk-1.ogg",
        modifiers = {
          type = "main-menu",
          volume_multiplier = 2
        },
        volume = 0.2
      },
      {
        filename = "__space-age__/sound/enemies/wriggler/wriggler-walk-2.ogg",
        modifiers = "SERPENT PLACEHOLDER",
        volume = 0.2
      },
      {
        filename = "__space-age__/sound/enemies/wriggler/wriggler-walk-3.ogg",
        modifiers = "SERPENT PLACEHOLDER",
        volume = 0.2
      },
      {
        filename = "__space-age__/sound/enemies/wriggler/wriggler-walk-4.ogg",
        modifiers = "SERPENT PLACEHOLDER",
        volume = 0.2
      },
      {
        filename = "__space-age__/sound/enemies/wriggler/wriggler-walk-5.ogg",
        modifiers = "SERPENT PLACEHOLDER",
        volume = 0.2
      },
      {
        filename = "__space-age__/sound/enemies/wriggler/wriggler-walk-6.ogg",
        modifiers = "SERPENT PLACEHOLDER",
        volume = 0.2
      }
    }
  },
  warcry = {
    aggregation = {
      count_already_playing = true,
      max_count = 2,
      remove = true
    },
    variations = {
      {
        filename = "__space-age__/sound/enemies/wriggler/wriggler-warcry-1.ogg",
        max_volume = 0.8,
        min_volume = 0.6,
        modifiers = {
          type = "main-menu",
          volume_multiplier = 0.5
        }
      },
      {
        filename = "__space-age__/sound/enemies/wriggler/wriggler-warcry-2.ogg",
        max_volume = 0.8,
        min_volume = 0.6,
        modifiers = "SERPENT PLACEHOLDER"
      },
      {
        filename = "__space-age__/sound/enemies/wriggler/wriggler-warcry-3.ogg",
        max_volume = 0.8,
        min_volume = 0.6,
        modifiers = "SERPENT PLACEHOLDER"
      },
      {
        filename = "__space-age__/sound/enemies/wriggler/wriggler-warcry-4.ogg",
        max_volume = 0.8,
        min_volume = 0.6,
        modifiers = "SERPENT PLACEHOLDER"
      },
      {
        filename = "__space-age__/sound/enemies/wriggler/wriggler-warcry-5.ogg",
        max_volume = 0.8,
        min_volume = 0.6,
        modifiers = "SERPENT PLACEHOLDER"
      },
      {
        filename = "__space-age__/sound/enemies/wriggler/wriggler-warcry-6.ogg",
        max_volume = 0.8,
        min_volume = 0.6,
        modifiers = "SERPENT PLACEHOLDER"
      }
    }
  },
  water_reflection = {
    pictures = {
      filename = "__space-age__/graphics/entity/wriggler/wriggler-effect-map.png",
      height = 21,
      scale = 2.5,
      variation_count = 1,
      width = 32
    }
  },
  working_sound = {
    max_sounds_per_prototype = 2,
    probability = 0.0016666666666666665,
    sound = {
      category = "enemy",
      variations = {
        {
          filename = "__space-age__/sound/enemies/wriggler/wriggler-idle-1.ogg",
          modifiers = {
            type = "main-menu",
            volume_multiplier = 1
          },
          volume = 0.5
        },
        {
          filename = "__space-age__/sound/enemies/wriggler/wriggler-idle-2.ogg",
          modifiers = "SERPENT PLACEHOLDER",
          volume = 0.5
        },
        {
          filename = "__space-age__/sound/enemies/wriggler/wriggler-idle-3.ogg",
          modifiers = "SERPENT PLACEHOLDER",
          volume = 0.5
        },
        {
          filename = "__space-age__/sound/enemies/wriggler/wriggler-idle-4.ogg",
          modifiers = "SERPENT PLACEHOLDER",
          volume = 0.5
        },
        {
          filename = "__space-age__/sound/enemies/wriggler/wriggler-idle-5.ogg",
          modifiers = "SERPENT PLACEHOLDER",
          volume = 0.5
        },
        {
          filename = "__space-age__/sound/enemies/wriggler/wriggler-idle-6.ogg",
          modifiers = "SERPENT PLACEHOLDER",
          volume = 0.5
        },
        {
          filename = "__space-age__/sound/enemies/wriggler/wriggler-idle-7.ogg",
          modifiers = "SERPENT PLACEHOLDER",
          volume = 0.5
        },
        {
          filename = "__space-age__/sound/enemies/wriggler/wriggler-idle-8.ogg",
          modifiers = "SERPENT PLACEHOLDER",
          volume = 0.5
        },
        {
          filename = "__space-age__/sound/enemies/wriggler/wriggler-idle-9.ogg",
          modifiers = "SERPENT PLACEHOLDER",
          volume = 0.5
        }
      }
    }
  }
}
]]
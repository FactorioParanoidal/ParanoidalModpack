data:extend({

   {
    type = "explosion",
    name = "small-atomic-explosion",
    flags = {"not-on-map"},
    animations = table.deepcopy(data.raw.explosion["nuke-explosion"].animations),
    light = {intensity = 1, size = 50, color = {r=1.0, g=1.0, b=1.0}},
    sound =
    {
      aggregation =
      {
        max_count = 1,
        remove = true
      },
      variations =
      {
        {
          filename = "__base__/sound/fight/large-explosion-1.ogg",
          volume = 1.25
        },
        {
          filename = "__base__/sound/fight/large-explosion-2.ogg",
          volume = 1.25
        }
      }
    },
    created_effect =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "nested-result",
            action =
            {
              type = "area",
              target_entities = false,
              trigger_from_target = true,
              repeat_count = 1000,
              radius = 8,
              action_delivery =
              {
                type = "projectile",
                projectile = "atomic-bomb-ground-zero-projectile",
                starting_speed = 0.6 * 0.8,
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
              radius = 8,
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
                    tile_collision_mask = { "water-tile" }
                  }
                }
              }
            }
          },
		  {
            type = "create-entity",
            entity_name = "big-scorchmark",
            check_buildability = true
          },
		  
        }
      }
    }
  },











--electric

  
   {
    type = "explosion",
    name = "electric-shock2",
    flags = {"not-on-map"},
    
      animations = {
        {
          scale = 3,
          axially_symmetrical = false,
          direction_count = 1,
          filename = "__Big-Monsters__/graphics/electroshock-pulse-explosion.png",
          animation_speed = 1,
          frame_count = 7*5,
          line_length = 5,
          width = 1675/5,
          height = 2044/7,
          priority = "extra-high",
          hr_version = {
            scale = 1.5,
            axially_symmetrical = false,
            direction_count = 1,
            filename = "__Big-Monsters__/graphics/hr-electroshock-pulse-explosion.png",
            animation_speed = 1,
            frame_count = 7*5,
            line_length = 5,
            width = 3350/5,
            height = 4088/7,
            priority = "extra-high",
          }
        }
      },
      flags = {
        "not-on-map"
      },
      light = {
        intensity = 1,
        size = 25,
        color = {
          a = 1,
          b = 1,
          g = 0.3,
          r = 0.1
        },
      },
      sound = {
        aggregation = {
          max_count = 1,
          remove = true
        },
        variations = {
          {
            filename = "__Big-Monsters__/sound/electroshock-pulse-explosion.ogg",
            volume = 1
          }
        }
      },
	  
	created_effect =
    {
              type = "area",
              radius = 13,
              --entity_flags = {"breaths-air","placeable-neutral","player-creation"},
              action_delivery =
              {
                type = "instant",
                target_effects = {
                  {
                    type = "create-sticker",
                    sticker = "electroshock-pulse-sticker",
                  },
                  {
                    type = "damage",
                    damage = { amount = 80, type = "laser"}
                  }
                }
              }
      
    }
  },

    
  
  {
    type = "sticker",
    name = "electroshock-pulse-sticker",
      animation = {
        scale = 1,
        filename = "__Big-Monsters__/graphics/electroshock-pulse-sticker.png",
        animation_speed = 3.14,
        frame_count = 16*6,
        line_length = 16,
        width = 800/16,
        height = 240/6,
       -- priority = "extra-high",
        hr_version = {
          scale = 0.5,
          filename = "__Big-Monsters__/graphics/hr-electroshock-pulse-sticker.png",
          animation_speed = 3.14,
          frame_count = 16*6,
          line_length = 16,
          width = 1600/16,
          height = 480/6,
        }
      },
      duration_in_ticks = 60*5, --75
      --flags ={"not-on-map"},
      target_movement_modifier = 0.25,
  },
  
  
   
  
	{
		type = "simple-entity",
		name = "electric-animation",
		flags = {"not-blueprintable", "not-deconstructable","placeable-off-grid", "not-on-map"},
		map_color = {r=0.5, g=0.5, b=1},
		max_health = 1,
		collision_box = {{0, -0.2}, {0, 0.2}},
		collision_mask = { "item-layer", "object-layer", "water-tile"},
		selection_box = {{-0.5, -0.9}, {0.5, 0.9}},
		random_animation_offset = false,
		animations = {{
			scale = 1,
			filename = "__Big-Monsters__/graphics/electroshock-pulse-sticker.png",
			animation_speed = 3.14,
			frame_count = 16*6,
			line_length = 16,
			width = 800/16,
			height = 240/6,
			-- priority = "extra-high",
      hr_version = {
        scale = 0.5,
        filename = "__Big-Monsters__/graphics/hr-electroshock-pulse-sticker.png",
        animation_speed = 3.14,
        frame_count = 16*6,
        line_length = 16,
        width = 1600/16,
        height = 480/6,
      }
			}},
		working_sound =
		{
			sound = { filename = "__base__/sound/accumulator-working.ogg" },
			volume = 0.9,
			audible_distance_modifier = 1,
			probability = 1
		},
		render_layer = "air-object", --render_layer = "smoke",
		tile_width = 1,
		tile_height = 1,
	},

 
  
})


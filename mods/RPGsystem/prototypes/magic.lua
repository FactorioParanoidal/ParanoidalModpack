--[[
data:extend({
 
   {
    type = "capsule",
    name = "rpg_magic_shock",
    icon = "__base__/graphics/icons/discharge-defense-equipment-controller.png",
    icon_size = 64, icon_mipmaps = 4,
    capsule_action =
    {
      type = "throw",
    attack_parameters =
    {
      type = "projectile",
      ammo_category = "electric",
      damage_modifier = 10,
      cooldown = 150,
      projectile_center = {0, 0},
      projectile_creation_distance = 0.6,
      range = 10,
      sound =
      {
         filename = "__base__/sound/fight/pulse.ogg",
         volume = 0.7
      },
      ammo_type =
      {
        type = "projectile",
        category = "electric",
        energy_consumption = "2MJ",
        action =
        {
          {
            type = "area",
            radius = 8,
            force = "enemy",
            action_delivery =
            {
             {
               type = "instant",
               target_effects =
               {
                {
                  type = "create-sticker",
                  sticker = "stun-sticker"
                },
                {
                  type = "push-back",
                  distance = 4
                }
               }
             },
             {
               type = "beam",
               beam = "electric-beam-no-sound",
               max_length = 16,
               duration = 15,
               source_offset = {0, -0.5},
               add_to_shooter = false
             }
            }
          }
        }
      }
    },
    },
    -- radius_color = { r = 0.25, g = 0.05, b = 0.25, a = 0.25 },
    subgroup = "capsule",
    order = "a[grenade]-e[e]",
    stack_size = 100
  },

  
})

]]


data:extend({

  {
    type = "projectile",
    name = "rpg_fireaball",
    flags = {"not-on-map"},
    acceleration = 0,--0.005,
    action =
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
                filename = "__base__/sound/fight/throw-projectile-1.ogg",
                volume = 0.8
              },
              {
                filename = "__base__/sound/fight/throw-projectile-2.ogg",
                volume = 0.8
              },
              {
                filename = "__base__/sound/fight/throw-projectile-3.ogg",
                volume = 0.8
              },
              {
                filename = "__base__/sound/fight/throw-projectile-4.ogg",
                volume = 0.8
              }
            }
          },

          {
            type = "damage",
            damage = {amount = 120, type = "fire"}
          },
          {
            type = "create-entity",
            entity_name = "big-explosion"
          },	  
          {
            type = "create-trivial-smoke",
            smoke_name = "artillery-smoke",
            initial_height = 0,
            speed_from_center = 0.05,
            speed_from_center_deviation = 0.005,
            offset_deviation = {{-3, -3}, {3, 3}},
            max_radius = 2.5,
            repeat_count = 2 * 4 * 15
          },
		    {
              type = "create-fire",
              entity_name = "fire-flame",
            },
          {
            type = "nested-result",
            action =
            {
              type = "area",
              radius = 5,
              action_delivery =
              {
                type = "instant",
                target_effects =
                {
                  {
                    type = "damage",
                    damage = {amount = 120, type = "fire"}
                  },

				  {
					type = "create-entity",
					entity_name = "explosion"
				  },
		    {
              type = "create-fire",
              entity_name = "fire-flame",
            },				  
                }
              }
            }
          }		  
        }
      }
    },
    animation =
    {
      filename = "__RPGsystem__/graphics/fireball.png",
      line_length = 1,
	  scale=0.25,
      width = 128,
      height = 128,
      frame_count = 1,
      priority = "high"
    },
    rotatable = true
  },


  {
    type = "projectile",
    name = "rpg_hadouken",
    flags = {"not-on-map"},
    acceleration = 0,--0.005,
    action =
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
                filename = "__base__/sound/fight/throw-projectile-1.ogg",
                volume = 0.8
              },
              {
                filename = "__base__/sound/fight/throw-projectile-2.ogg",
                volume = 0.8
              },
              {
                filename = "__base__/sound/fight/throw-projectile-3.ogg",
                volume = 0.8
              },
              {
                filename = "__base__/sound/fight/throw-projectile-4.ogg",
                volume = 0.8
              }
            }
          },

          {
            type = "damage",
            damage = {amount = 80, type = "electric"}
          },
                {
                    type = "create-particle",
					particle_name = 'tintable-water-particle',
                    repeat_count = 50,
              initial_height = 1,
              initial_vertical_speed = 0.1,
              initial_vertical_speed_deviation = 0.05,
              offset_deviation = {{-0.1, -0.1}, {0.1, 0.1}},
              speed_from_center = 0.05,
              speed_from_center_deviation = 0.01					
                  },		  
          {
            type = "nested-result",
            action =
            {
              type = "area",
              radius = 7,
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
                    type = "create-particle",
					particle_name = 'tintable-water-particle',
                    repeat_count = 30,
              initial_height = 1,
              initial_vertical_speed = 0.1,
              initial_vertical_speed_deviation = 0.05,
              offset_deviation = {{-0.1, -0.1}, {0.1, 0.1}},
              speed_from_center = 0.05,
              speed_from_center_deviation = 0.01
			  
                  },

                }
              }
            }
          }		  
        }
      }
    },
    animation =
    {
      filename = "__RPGsystem__/graphics/LV_Magic_icon.png",
      line_length = 1,
	  scale=0.25,
      width = 128,
      height = 128,
      frame_count = 1,
      priority = "high"
    },
    rotatable = true
  }

})





--[[
function rpg_create_explosion(explosion_name,damage,radius)
data:extend({

   {
    type = "explosion",
    name = "rpg-"..explosion_name,
    flags = {"not-on-map"},
    animations = table.deepcopy(data.raw.explosion['explosion'].animations),
    light = {intensity = 0.7, size = radius * 10, color = {r=1.0, g=1.0, b=1.0}},
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
			  {
				type = "area",
				radius = 8,
				force = "enemy",
				action_delivery =
				{
				 {
				   type = "instant",
				   target_effects =
				   {
					{
					  type = "create-sticker",
					  sticker = "stun-sticker"
					},
					{
					  type = "push-back",
					  distance = 4
					}
				   }
				 },
				 {
				   type = "beam",
				   beam = "electric-beam-no-sound",
				   max_length = 16,
				   duration = 15,
				   source_offset = {0, -0.5},
				   add_to_shooter = false
				 }
				}
			  }
			}
          },

	  
	  
        }
      }
    }
  }



})
end


--rpg_create_explosion("explosion",90,2)   -- eb-explosion
rpg_create_explosion("magic-shock",140,3) -- eb-medium-explosion
]]
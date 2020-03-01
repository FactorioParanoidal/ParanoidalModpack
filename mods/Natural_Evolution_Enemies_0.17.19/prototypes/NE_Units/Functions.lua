
if not NE_Enemies then NE_Enemies = {} end
if not NE_Enemies.Settings then NE_Enemies.Settings = {} end

NE_Enemies.Settings.NE_Difficulty = settings.startup["NE_Difficulty"].value

--- Tint
--- Transparency
trans = 0.7

ne_blue_tint1 = {r=0, g=0, b=1, a=trans}	
ne_blue_tint2 = {r=0, g=200/255, b=1, a=trans}	

ne_fire_tint = {r=1, g=0, b=0, a=trans} -- Red
ne_fire_tint2 = {r=1, g=0, b=50/255, a=0.8} 

ne_green_tint = {r=0, g=204/255, b=0, a=trans}
ne_green_tint2 = {r=204/255, g=1, b=153/255, a=trans}

ne_pink_tint = {r=1, g=0, b=200/255, a=trans}

ne_yellow_tint = {r=1, g=1, b=50/255, a=trans}
ne_yellow_tint2 = {r=1, g=1, b=100/255, a=0.2}

ne_orange_tint = {r=1, g=150/255, b=0, a=trans}

ne_purple_tint = {r=150/255, g=50/255, b=1, a=trans}
ne_black_tint = {r=0, g=0, b=0, a=trans}
ne_brown_tint = {r=150/255, g=100/255, b=50/255, a=trans}

ne_grey_tint = {r=192/255, g=192/255, b=192/255, a=trans}

--- Biters
function ne_biter_run_animation(scale, tint1, tint2)
  return
  {
    layers=
    {
      {
        width = 169,
        height = 114,
        frame_count = 16,
        direction_count = 16,
        shift = {scale * 0.714844, scale * -0.246094},
        scale = scale,
        stripes =
        {
         {
          filename = "__base__/graphics/entity/biter/biter-run-1.png",
          width_in_frames = 8,
          height_in_frames = 16
         },
         {
          filename = "__base__/graphics/entity/biter/biter-run-2.png",
          width_in_frames = 8,
          height_in_frames = 16
         }
        }
      },

      {
        filename = "__base__/graphics/entity/biter/biter-run-mask1.png",
        flags = { "mask" },
        width = 105,
        height = 81,
        frame_count = 16,
        direction_count = 16,
        shift = {scale * 0.117188, scale * -0.867188},
        scale = scale,
        tint = tint1
      },

      {
        filename = "__base__/graphics/entity/biter/biter-run-mask2.png",
        flags = { "mask" },
        line_length = 16,
        width = 95,
        height = 81,
        frame_count = 16,
        direction_count = 16,
        shift = {scale * 0.117188, scale * -0.855469},
        scale = scale,
        tint = tint2
      }
    }
  }
end

--[[
function ne_biter_attack_animation(scale, tint1, tint2)
  return
  {
    layers=
    {
      {
        width = 279,
        height = 184,
        frame_count = 11,
        direction_count = 16,
        shift = {scale * 1.74609, scale * -0.644531},
        animation_speed = 0.3,
        scale = scale,
        stripes =
        {
         {
          filename = "__base__/graphics/entity/biter/biter-attack-1.png",
          width_in_frames = 6,
          height_in_frames = 8
         },
         {
          filename = "__base__/graphics/entity/biter/biter-attack-2.png",
          width_in_frames = 5,
          height_in_frames = 8
         },
         {
          filename = "__base__/graphics/entity/biter/biter-attack-3.png",
          width_in_frames = 6,
          height_in_frames = 8
         },
         {
          filename = "__base__/graphics/entity/biter/biter-attack-4.png",
          width_in_frames = 5,
          height_in_frames = 8
         }
        }
      },

      {
        filename = "__base__/graphics/entity/biter/biter-attack-mask1.png",
        flags = { "mask" },
        width = 125,
        height = 108,
        frame_count = 11,
        direction_count = 16,
        shift = {scale * 0.117188, scale * -1.11328},
        scale = scale,
        tint = tint1
      },

      {
        filename = "__base__/graphics/entity/biter/biter-attack-mask2.png",
        flags = { "mask" },
        width = 114,
        height = 100,
        frame_count = 11,
        direction_count = 16,
        shift = {scale * 0.117188, scale * -1.06641},
        scale = scale,
        tint = tint2
      }
    }
  }
end

function ne_biter_die_animation(scale, tint1, tint2)
  return
  {
    layers=
    {
      {
        width = 190,
        height = 129,
        frame_count = 17,
        direction_count = 16,
        shift = {scale * 0.621094, scale * -0.1875},
        scale = scale,
        stripes =
        {
          {
            filename = "__base__/graphics/entity/biter/biter-die-1.png",
            width_in_frames = 9,
            height_in_frames = 8
          },
          {
            filename = "__base__/graphics/entity/biter/biter-die-2.png",
            width_in_frames = 8,
            height_in_frames = 8
          },
          {
            filename = "__base__/graphics/entity/biter/biter-die-3.png",
            width_in_frames = 9,
            height_in_frames = 8
          },
          {
            filename = "__base__/graphics/entity/biter/biter-die-4.png",
            width_in_frames = 8,
            height_in_frames = 8
          }
        }
      },

      {
        filename = "__base__/graphics/entity/biter/biter-die-mask1.png",
        flags = { "mask" },
        width = 120,
        height = 109,
        frame_count = 17,
        direction_count = 16,
        shift = {scale * 0.117188, scale * -0.574219},
        scale = scale,
        tint = tint1
      },

      {
        filename = "__base__/graphics/entity/biter/biter-die-mask2.png",
        flags = { "mask" },
        width = 115,
        height = 108,
        frame_count = 17,
        direction_count = 16,
        shift = {scale * 0.128906, scale * -0.585938},
        scale = scale,
        tint = tint2
      }
    }
  }
end



--- Spitters
function ne_spitter_attack_animation(scale, tint)
  return
  {
    layers =
    {
      {
        width = 199,
        height = 164,
        frame_count = 22,
        direction_count = 16,
        scale=scale,
        shift = {scale * 0.765625, scale * 0.0625},
        animation_speed = 0.4,
        stripes =
        {
          {
            filename = "__base__/graphics/entity/spitter/spitter-attack-1.png",
            width_in_frames = 8,
            height_in_frames = 8
          },
          {
            filename = "__base__/graphics/entity/spitter/spitter-attack-2.png",
            width_in_frames = 8,
            height_in_frames = 8
          },
          {
            filename = "__base__/graphics/entity/spitter/spitter-attack-3.png",
            width_in_frames = 6,
            height_in_frames = 8
          },
          {
            filename = "__base__/graphics/entity/spitter/spitter-attack-4.png",
            width_in_frames = 8,
            height_in_frames = 8
          },
          {
            filename = "__base__/graphics/entity/spitter/spitter-attack-5.png",
            width_in_frames = 8,
            height_in_frames = 8
          },
          {
            filename = "__base__/graphics/entity/spitter/spitter-attack-6.png",
            width_in_frames = 6,
            height_in_frames = 8
          }
        }
      },
      {
        flags = { "mask" },
        width = 108,
        height = 90,
        frame_count = 22,
        direction_count = 16,
        shift = {scale * 0, scale * -0.625},
        scale = scale,
        tint = tint,
        animation_speed = 0.4,
        stripes =
        {
          {
            filename = "__base__/graphics/entity/spitter/spitter-attack-mask-1.png",
            width_in_frames = 11,
            height_in_frames = 16
          },
          {
            filename = "__base__/graphics/entity/spitter/spitter-attack-mask-2.png",
            width_in_frames = 11,
            height_in_frames = 16
          }
        }
      }
    }
  }
end

function ne_spitter_run_animation(scale, tint)
  return
  {
    layers =
    {
      {
        width = 193,
        height = 164,
        priority="very-low",
        frame_count = 24,
        direction_count = 16,
        shift = {scale * 1.01562, 0},
        scale = scale,
        still_frame = 4,
        stripes =
        {
          {
            filename = "__base__/graphics/entity/spitter/spitter-run-1.png",
            width_in_frames = 8,
            height_in_frames = 8
          },
          {
            filename = "__base__/graphics/entity/spitter/spitter-run-2.png",
            width_in_frames = 8,
            height_in_frames = 8
          },
          {
            filename = "__base__/graphics/entity/spitter/spitter-run-3.png",
            width_in_frames = 8,
            height_in_frames = 8
          },
          {
            filename = "__base__/graphics/entity/spitter/spitter-run-4.png",
            width_in_frames = 8,
            height_in_frames = 8
          },
          {
            filename = "__base__/graphics/entity/spitter/spitter-run-5.png",
            width_in_frames = 8,
            height_in_frames = 8
          },
          {
            filename = "__base__/graphics/entity/spitter/spitter-run-6.png",
            width_in_frames = 8,
            height_in_frames = 8
          }
        }
      },
      {
        width = 81,
        height = 90,
        frame_count = 24,
        direction_count = 16,
        shift = {scale * 0.015625, scale * -0.6875},
        scale = scale,
        filename = "__base__/graphics/entity/spitter/spitter-run-mask.png",
        flags = { "mask" },
        tint = tint
      }
    }
  }
end

function ne_spitter_dying_animation(scale, tint)
  return
  {
    layers =
    {
      {
        width = 225,
        height = 174,
        frame_count = 16,
        direction_count = 16,
        shift = {scale * 0.546875, scale * 0.21875},
        priority = "very-low",
        scale = scale,
        stripes =
        {
          {
            filename = "__base__/graphics/entity/spitter/spitter-die-1.png",
            width_in_frames = 8,
            height_in_frames = 8
          },
          {
            filename = "__base__/graphics/entity/spitter/spitter-die-2.png",
            width_in_frames = 8,
            height_in_frames = 8
          },
          {
            filename = "__base__/graphics/entity/spitter/spitter-die-3.png",
            width_in_frames = 8,
            height_in_frames = 8
          },
          {
            filename = "__base__/graphics/entity/spitter/spitter-die-4.png",
            width_in_frames = 8,
            height_in_frames = 8
          }
        }
      },
      {
        flags = { "mask" },
        width = 166,
        height = 144,
        frame_count = 16,
        direction_count = 16,
        shift = {scale * 0, scale * -0.0625},
        priority = "very-low",
        tint = tint,
        scale = scale,
        stripes =
        {
          {
            filename = "__base__/graphics/entity/spitter/spitter-die-mask-1.png",
            width_in_frames = 8,
            height_in_frames = 8
          },
          {
            filename = "__base__/graphics/entity/spitter/spitter-die-mask-2.png",
            width_in_frames = 8,
            height_in_frames = 8
          },
          {
            filename = "__base__/graphics/entity/spitter/spitter-die-mask-3.png",
            width_in_frames = 8,
            height_in_frames = 8
          },
          {
            filename = "__base__/graphics/entity/spitter/spitter-die-mask-4.png",
            width_in_frames = 8,
            height_in_frames = 8
          }
        }
      }
    }
  }
end


]]



function NE_Biter_Melee_Single_Attack(data)
  return
    {
      type = "projectile",
      range = data.range,
      cooldown = data.cooldown,
	  damage_modifier = data.damage_modifier or 1,
      ammo_category = "melee",
      ammo_type =   {
			category = "melee",
			target_type = "entity",
			action =
			{
			  type = "direct",
			  action_delivery =
			  {
				type = "instant",
				target_effects =
				{
				  type = "damage",
				  damage = { amount = data.damage_amount_1 + NE_Enemies.Settings.NE_Difficulty, type = data.damage_type_1}
				},
			  }
			}
		  },
      sound =  make_biter_roars(sound),
      animation = biterattackanimation(data.scale, data.tint1, data.tint2)
    }
	
end


function NE_Biter_Melee_Double_Attack(data)
  return
    {
      type = "projectile",
      range = data.range,
      cooldown = data.cooldown,
	  damage_modifier = data.damage_modifier or 1,
      ammo_category = "melee",
      ammo_type =   {
			category = "melee",
			target_type = "entity",
			action =
			{
			  type = "direct",
			  action_delivery =
			  {
				type = "instant",
				target_effects =
				{
					{
					  type = "damage",
					  damage = { amount = data.damage_amount_1 + NE_Enemies.Settings.NE_Difficulty, type = data.damage_type_1}
					},
					{
					  type = "damage",
					  damage = { amount = data.damage_amount_2 + NE_Enemies.Settings.NE_Difficulty, type = data.damage_type_2}
					},
				}
			  }
			}
		  },
      sound =  make_biter_roars(sound),
      animation = biterattackanimation(data.scale, data.tint1, data.tint2)
    }
	
end


function NE_Biter_Melee_Tripple_Attack(data)
  return
    {
      type = "projectile",
      range = data.range,
      cooldown = data.cooldown,
	  damage_modifier = data.damage_modifier or 1,
      ammo_category = "melee",
      ammo_type =   {
			category = "melee",
			target_type = "entity",
			action =
			{
			  type = "direct",
			  action_delivery =
			  {
				type = "instant",
				target_effects =
				{
					{
					  type = "damage",
					  damage = { amount = data.damage_amount_1 + NE_Enemies.Settings.NE_Difficulty, type = data.damage_type_1}
					},
					{
					  type = "damage",
					  damage = { amount = data.damage_amount_2 + NE_Enemies.Settings.NE_Difficulty, type = data.damage_type_2}
					},
					{
					  type = "damage",
					  damage = { amount = data.damage_amount_3 + NE_Enemies.Settings.NE_Difficulty, type = data.damage_type_3}
					},
				}
			  }
			}
		  },
      sound =  make_biter_roars(sound),
      animation = biterattackanimation(data.scale, data.tint1, data.tint2)
    }
	
end


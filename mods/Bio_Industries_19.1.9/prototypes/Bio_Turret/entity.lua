local BioInd = require('common')('Bio_Industries')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"

-- demo-sounds has been removed in Factorio 1.1, so we need to check the game version!
local sound_def = BioInd.check_version("base", "<", "1.1.0") and
                    require("__base__.prototypes.entity.demo-sounds") or
                    require("__base__.prototypes.entity.sounds")
local sounds = {}
sounds.car_wood_impact = sound_def.car_wood_impact(0.8)
sounds.generic_impact = sound_def.generic_impact
for _, sound in ipairs(sounds.generic_impact) do
  sound.volume = 0.65
end

data:extend({
  --- Basic Dart
  {
    type = "ammo",
    name = "bi-dart-magazine-basic",
    icon = ICONPATH .. "basic_dart_icon.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "basic_dart_icon.png",
        icon_size = 64,
      }
    },
    ammo_type = {
      category = "Bio_Turret_Ammo",
      action = {
        type = "direct",
        action_delivery = {
          type = "instant",
          source_effects = {
            type = "create-explosion",
            entity_name = "explosion-gunshot",
          },
          target_effects = {
            {
              type = "create-entity",
              entity_name = "explosion-hit"
            },
            {
              type = "damage",
              damage = { amount = 3 , type = "physical"}
            },
          }
        }
      }
    },
    magazine_size = 10,
    subgroup = "ammo",
    order = "[aaa]-a[basic-clips]-aa[firearm-magazine]",
    stack_size = 400
  },

  --- Standard Dart
  {
    type = "ammo",
    name = "bi-dart-magazine-standard",
    icon = ICONPATH .. "standard_dart_icon.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "standard_dart_icon.png",
        icon_size = 64,
      }
    },
    ammo_type = {
      category = "Bio_Turret_Ammo",
      action = {
        type = "direct",
        action_delivery = {
          type = "instant",
          source_effects = {
            type = "create-explosion",
            entity_name = "explosion-gunshot",
          },
          target_effects = {
            {
              type = "create-entity",
              entity_name = "explosion-hit"
            },
            {
              type = "damage",
              damage = { amount = 3 , type = "physical"}
            },
            {
              type = "damage",
              damage = { amount = 2 , type = "bob-pierce"}
            },
          }
        }
      }
    },
    magazine_size = 10,
    subgroup = "ammo",
    order = "[aab]-a[basic-clips]-ab[firearm-magazine]",
    stack_size = 400
  },


  --- Enhanced Dart
  {
    type = "ammo",
    name = "bi-dart-magazine-enhanced",
    icon = ICONPATH .. "enhanced_dart_icon.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "enhanced_dart_icon.png",
        icon_size = 64,
      }
    },
    ammo_type = {
      category = "Bio_Turret_Ammo",
      action = {
        type = "direct",
        action_delivery = {
          type = "instant",
          source_effects = {
            type = "create-explosion",
            entity_name = "explosion-gunshot",
          },
          target_effects = {
            {
              type = "create-entity",
              entity_name = "explosion-hit"
            },
            {
              type = "damage",
              damage = { amount = 3 , type = "physical"}
            },
            {
              type = "damage",
              damage = { amount = 2 , type = "bob-pierce"}
            },
            {
              type = "damage",
              damage = { amount = 2 , type = "acid"}
            },
          }
        }
      }
    },
    magazine_size = 10,
    subgroup = "ammo",
    order = "[aac]-a[basic-clips]-ac[firearm-magazine]",
    stack_size = 400
  },


  --- Poison Dart
  {
    type = "ammo",
    name = "bi-dart-magazine-poison",
    icon = ICONPATH .. "poison_dart_icon.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "poison_dart_icon.png",
        icon_size = 64,
      }
    },
    ammo_type = {
      category = "Bio_Turret_Ammo",
      action = {
      type = "direct",
      action_delivery = {
          type = "instant",
          source_effects = {
            type = "create-explosion",
            entity_name = "explosion-gunshot",
          },
          target_effects = {
            {
              type = "create-entity",
              entity_name = "explosion-hit"
            },
            {
              type = "damage",
              damage = { amount = 3 , type = "physical"}
            },
            {
              type = "damage",
              damage = { amount = 2 , type = "bob-pierce"}
            },
            {
              type = "damage",
              damage = { amount = 2 , type = "acid"}
            },
            {
              type = "damage",
              damage = { amount = 2 , type = "poison"}
            },
          }
        }
      }
    },
    magazine_size = 10,
    subgroup = "ammo",
    order = "[aad]-a[basic-clips]-ad[firearm-magazine]",
    stack_size = 400
  },

})




function turret_pic(inputs)
return
{
  layers = {
    {
      filename = "__Bio_Industries__/graphics/entities/bio_turret/bio_turret.png",
      priority = "medium",
      scale = 0.5,
      width = 224,
      height = 160,
      direction_count = inputs.direction_count and inputs.direction_count or 64,
      frame_count = 1,
      line_length = inputs.line_length and inputs.line_length or 8,
      axially_symmetrical = false,
      run_mode = inputs.run_mode and inputs.run_mode or "forward",
      shift = { 0.25, -0.25 },
    }
  }
}
end


--- Dart Turret
data:extend({
  {
    type = "ammo-turret",
    name = "bi-dart-turret",
    icon = ICONPATH .. "bio_turret_icon.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "bio_turret_icon.png",
        icon_size = 64,
      }
    },
    flags = {"placeable-player", "player-creation"},
    minable = {mining_time = 0.25, result = "bi-dart-turret"},
    max_health = 300,
    corpse = "medium-remnants",
    collision_box = {{-0.2, -0.2 }, {0.2, 0.2}},
    selection_box = {{-0.4, -0.4 }, {0.4, 0.4}},
    rotation_speed = 0.05,
    preparing_speed = 0.08,
    folding_speed = 0.08,
    dying_explosion = "medium-explosion",
    inventory_size = 1,
    automated_ammo_count = 14,
    attacking_speed = 1, -- makes nothing, it's animation's parameter

    folded_animation = turret_pic{direction_count = 8, line_length = 1},
    preparing_animation = turret_pic{direction_count = 8, line_length = 1},
    prepared_animation = turret_pic{},
    attacking_animation = turret_pic{},
    folding_animation = turret_pic{direction_count = 8, line_length = 1, run_mode = "backward"},

    -- darkfrei: wood impact sound for woods!
    vehicle_impact_sound = sounds.car_wood_impact,
    attack_parameters = {
      type = "projectile",
      ammo_category = "Bio_Turret_Ammo",
      cooldown = 3.6,  -- cooldown = 6 -- darkfrei: means cooldown 6/60 sec or 10 shoots at second; = 60 is one shoot/sec
      projectile_creation_distance = 1.41,
      projectile_center = {-0.0625, 0.55},
      -- darkfrei: darts haven't shells :)
--[[      shell_particle = {
  name = "shell-particle",
  direction_deviation = 0.1,
  speed = 0.15,
  speed_deviation = 0.03,
  center = {-0.0625, 0},
  creation_distance = -1.925,
  starting_frame_speed = 0.2,
  starting_frame_speed_deviation = 0.1
      }, ]]
      range = 20,
      sound = {
        filename = "__Bio_Industries__/sound/dart-turret.ogg",
        volume = 0.85
      },
    },
    call_for_help_radius = 40
  },


})


--- Dart Rifle
data:extend({
  {
    type = "gun",
    name = "bi-dart-rifle",
    icon = ICONPATH .. "bi_dart_rifle_icon.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "bi_dart_rifle_icon.png",
        icon_size = 64,
      }
    },
    subgroup = "gun",
    order = "a[basic-clips]-ab[submachine-gun]",
    attack_parameters = {
      type = "projectile",
      ammo_category = "Bio_Turret_Ammo",
      cooldown = 5,
      movement_slow_down_factor = 0.5,
      --shell_particle = {},
      projectile_creation_distance = 1.125,
      range = 17,
      sound = {
        filename = "__Bio_Industries__/sound/dart-turret.ogg",
        volume = 0.65
      },
    },
    stack_size = 5
  },
})

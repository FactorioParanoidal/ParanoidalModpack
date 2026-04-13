--set up bits and bobs
local sounds = require("__base__.prototypes.entity.sounds")
local item_sounds = require("__base__.prototypes.item_sounds")
--cloud formation
local neurotoxincloud = table.deepcopy(data.raw["smoke-with-trigger"]["poison-cloud"])
  neurotoxincloud.name="neurotoxin-cloud"
  neurotoxincloud.action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          type = "nested-result",
          action =
          {
            type = "area",
            radius = 16,--poison cloud has radius = 11,
            entity_flags = {"breaths-air"},
            action_delivery =
            {
              type = "instant",
              target_effects =
              {
                type = "damage",
                damage = { amount = 20, type = "poison"}--poison cloud has damage = { amount = 8, type = "poison"}
              }
            }
          }
        }
      }
    }
  neurotoxincloud.particle_spread = { 4.5 * 1.05, 4.5 * 0.6 * 1.05 }
  neurotoxincloud.particle_count = 30
  neurotoxincloud.created_effect = {
    {
      type = "cluster",
      cluster_count = 25, --10
      distance = 9,--4
      distance_deviation = 8,
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "create-smoke",
            show_in_tooltip = false,
            entity_name = "poison-cloud-visual-dummy",
            initial_height = 0
          },
          {
            type = "play-sound",
            sound = sounds.poison_capsule_explosion
          }
        }
      }
    },
    {
      type = "cluster",
      cluster_count = 40,--11
      distance = 25,--8 * 1.1,
      distance_deviation = 3,--2
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "create-smoke",
            show_in_tooltip = false,
            entity_name = "poison-cloud-visual-dummy",
            initial_height = 0
          }
        }
      }
    }
  }
  --capsule projectile definition
local neuroproj = table.deepcopy(data.raw["projectile"]["poison-capsule"])
  neuroproj.name = "clowns-neurotoxin-capsule"
  neuroproj.action = {
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "create-smoke",
            show_in_tooltip = true,
            entity_name = "poison-cloud",
            initial_height = 0
          },
          {
            type = "create-particle",
            particle_name = "poison-capsule-metal-particle",
            repeat_count = 8,
            initial_height = 1,
            initial_vertical_speed = 0.1,
            initial_vertical_speed_deviation = 0.05,
            offset_deviation = {{-0.1, -0.1}, {0.1, 0.1}},
            speed_from_center = 0.05,
            speed_from_center_deviation = 0.01
          }
        }
      }
    }
  }
data:extend(
  {
    neurotoxincloud, -- make sure above is ready for below
    neuroproj,
    {-- the actual capsule
      type = "capsule",
      name = "clowns-neurotoxin-capsule",
      icons ={
        {icon = "__Clowns-Processing__/graphics/icons/neurotoxin-capsule.png",icon_size = 32, --[[tint = { 118, 141, 138 }]]},
      },
      capsule_action =
      {
        type = "throw",
        attack_parameters =
        {
          type = "projectile",
          activation_type = "throw",
          ammo_category = "capsule",
          cooldown = 30,
          projectile_creation_distance = 0.6,
          range = 25,
          ammo_type =
          {
            target_type = "position",
            action =
            {
              {
                type = "direct",
                action_delivery =
                {
                  type = "projectile",
                  projectile = "clowns-neurotoxin-capsule",
                  starting_speed = 0.3
                }
              },
              {
                type = "direct",
                action_delivery =
                {
                  type = "instant",
                  target_effects =
                  {
                    {
                      type = "play-sound",
                      sound = sounds.throw_projectile
                    }
                  }
                }
              }
            }
          }
        }
      },
      subgroup = "capsule",
      order = "b[poison-capsule]-a",
      inventory_move_sound = item_sounds.grenade_inventory_move,
      pick_sound = item_sounds.grenade_inventory_pickup,
      drop_sound = item_sounds.grenade_inventory_move,
      stack_size = 200,
      weight = 8*kg
    },
  })
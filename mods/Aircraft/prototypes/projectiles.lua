data:extend({
  { -- High explosive cannon projectile
    type = "projectile",
    name = "high-explosive-cannon-projectile",
    flags = {"not-on-map"},
    collision_box = {{-0.05, -1.1}, {0.05, 1.1}},
    acceleration = 0,
    direction_only = true,
    piercing_damage = 125,
    action = {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = { {
            type = "damage",
            damage = { amount = 275, type = "physical"}
          }
        }
      }
    },
    final_action = {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type = "create-entity",
            entity_name = "big-explosion",
            check_buildability = true
          },
          {
            type = "nested-result",
            action = {
              type = "area",
              radius = 6,
              action_delivery = {
                type = "instant",
                target_effects = {
                  {
                    type = "damage",
                    damage = {amount = 325, type = "explosion"}
                  },
                  {
                    type = "create-entity",
                    entity_name = "big-explosion"
                  }
                }
              }
            }
          }
        }
      }
    },
    animation = {
      filename = "__base__/graphics/entity/bullet/bullet.png",
      frame_count = 1,
      width = 3,
      height = 50,
      priority = "high"
    },
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
})
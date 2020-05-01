local neurotoxincloud=table.deepcopy(data.raw["smoke-with-trigger"]["poison-cloud"])

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
neurotoxincloud.particle_spread={ 4.5 * 1.05, 4.5 * 0.6 * 1.05 }
neurotoxincloud.particle_count=30
neurotoxincloud.created_effect = {
    {
      action_delivery = {
        target_effects = {
          entity_name = "poison-cloud-visual-dummy",
          initial_height = 0,
          show_in_tooltip = false,
          type = "create-smoke"
        },
        type = "instant"
      },
      cluster_count = 15,--10,
      distance = 7,--4,
      distance_deviation = 5,
      type = "cluster"
    },
    {
      action_delivery = {
        target_effects = {
          entity_name = "poison-cloud-visual-dummy",
          initial_height = 0,
          show_in_tooltip = false,
          type = "create-smoke"
        },
        type = "instant"
      },
      cluster_count = 15,--11,
      distance = 15,--8.8000000000000007,
      distance_deviation = 3, --2,
      type = "cluster"
    }
  },
data:extend({neurotoxincloud})

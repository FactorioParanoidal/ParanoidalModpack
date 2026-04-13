local modutils = require("prototypes.modutils")

data:extend({
    {
      type = "technology",
      name = "space-mining-theory",
      icon_size = 128,
      order = "y-a",    
      icon = "__expanded-rocket-payloads-continued__/graphic/space-mining-theory-128.png",
      prerequisites = {"extremely-advanced-rocket-payloads"},
      unit =
      {
        count = 100,
        ingredients =
        {
          {"station-science", 1},
          {"planetary-data", 1},
        },
        time = 120
      },
    },
    {
      type = "technology",
      name = "autonomous-space-mining-drones",
      icon_size = 128,
      order = "y-a",    
      icon = "__expanded-rocket-payloads-continued__/graphic/mining-drones-128.png",
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "autonomous-space-mining-drone",
        },

      },
      prerequisites = {"space-mining-theory"},
      unit =
      {
        count = 15000,
        ingredients = modutils.full_science_pack(),
        time = 80
      },
    },
})
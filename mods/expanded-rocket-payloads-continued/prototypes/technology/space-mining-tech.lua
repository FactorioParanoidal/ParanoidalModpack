local modutils = require("prototypes.modutils")

data:extend({
  {
    type = "technology",
    name = "asteroid-mining",
    icon_size = 128,
    order = "y-a",
    icon = "__expanded-rocket-payloads-continued__/graphic/space-mining-128.png",
    effects =
        modutils.select_any(
          {
            {
              type = "unlock-recipe",
              recipe = "mining-shuttle",
            },
            {
              type = "unlock-recipe",
              recipe = "iron-dropship-unboxing",
            },
            {
              type = "unlock-recipe",
              recipe = "copper-dropship-unboxing",
            },
            {
              type = "unlock-recipe",
              recipe = "refurbish-mining-shuttle",
            },
          }, nil, {
            {
              type = "unlock-recipe",
              recipe = "multiore-dropship-unboxing",
            },
          }),
    prerequisites = { "autonomous-space-mining-drones", "space-shuttle" },
    unit =
    {
      count = 100000,
      ingredients = modutils.full_science_pack(),
      time = 80
    },
  },
})

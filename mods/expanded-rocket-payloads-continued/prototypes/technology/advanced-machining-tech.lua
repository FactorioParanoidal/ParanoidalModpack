local modutils = require("prototypes.modutils")

data:extend({
  {
    type = "technology",
    name = "advanced-machining",
    icon_size = 128,
    icon = "__expanded-rocket-payloads-continued__/graphic/advanced-assembler-128.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "advanced-assembler"
      },

    },
    prerequisites = { "improved-space-program-theory" },
    order = "y-a",
    unit =
    {
      count = 3000,
      ingredients = modutils.full_science_pack(),
      time = 60
    },
  },
})

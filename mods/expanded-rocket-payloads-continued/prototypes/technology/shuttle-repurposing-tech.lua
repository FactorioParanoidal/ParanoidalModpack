local modutils = require("prototypes.modutils")

data:extend({
    {
      type = "technology",
      name = "shuttle-repurposing",
      icon_size = 128,
      icon = "__expanded-rocket-payloads-continued__/graphic/shuttle-repurposeing-128.png",
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "repurpose-space-shuttle"
        },
        {
          type = "unlock-recipe",
          recipe = "repurpose-spy-shuttle"
        },
        {
          type = "unlock-recipe",
          recipe = "repurpose-mining-shuttle"
        },
      },
      prerequisites = {"spy-shuttle"},
      unit =
      {
        count = 40000,
        ingredients = modutils.full_science_pack(),
        time = 80,
        order = "y-b"
      },
    },
  })
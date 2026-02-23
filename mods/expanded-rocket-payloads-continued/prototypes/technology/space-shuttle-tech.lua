local modutils = require("prototypes.modutils")

data:extend({
    {
      type = "technology",
      name = "space-shuttle",
      icon_size = 128,
      order = "y-a",    
      icon = "__expanded-rocket-payloads-continued__/graphic/dreamchaser-128.png",
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "shuttle-hull-recipe"
        },
        {
          type = "unlock-recipe",
          recipe = "space-shuttle"
        },
        {
          type = "unlock-recipe",
          recipe = "refurbish-space-shuttle"
        },
      },
      prerequisites = {"extremely-advanced-rocket-payloads"},
      unit =
      {
        count = 100000,
        ingredients = modutils.full_science_pack(),
        time = 80
      },
    },
    {
      type = "technology",
      name = "spy-shuttle",
      icon_size = 128,
      order = "y-a",    
      icon = "__expanded-rocket-payloads-continued__/graphic/shuttle-telescope-128.png",
      effects =
      {

        {
          type = "unlock-recipe",
          recipe = "spy-shuttle"
        },
        {
          type = "unlock-recipe",
          recipe = "refurbish-spy-shuttle"
        },
      },
      prerequisites = {"space-shuttle"},
      unit =
      {
        count = 40000,
        ingredients = modutils.full_science_pack(),
        time = 80
      },
    },
})
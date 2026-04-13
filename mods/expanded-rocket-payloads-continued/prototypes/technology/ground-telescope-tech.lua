local modutils = require("prototypes.modutils")

data:extend({
    {
      type = "technology",
      name = "ground-telescope",
      icon_size = 128,
      order = "y-b",
      icon = "__expanded-rocket-payloads-continued__/graphic/ground-telescope-128.png",
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "ground-telescope"
        },
        {
          type = "unlock-recipe",
          recipe = "study-the-stars"
        },
        {
          type = "unlock-recipe",
          recipe = "telescope-components"
        },
      },
      prerequisites = {"extremely-advanced-material-processing"},
      unit =
      {
        count = 4000,
        ingredients = modutils.full_science_pack(),
        time = 60
      },
    },
})
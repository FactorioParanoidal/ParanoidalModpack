local modutils = require("prototypes.modutils")

data:extend({
    {
      type = "technology",
      name = "space-lab",
      icon_size = 128,
      icon = "__expanded-rocket-payloads-continued__/graphic/skylab-128.png",
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "space-lab"
        },
      },
      prerequisites = {"extremely-advanced-material-processing"},
      unit =
      {
        count = 5000,
        ingredients = modutils.full_science_pack(),
        time = 30
      },
      order = "y-a"
    },
})
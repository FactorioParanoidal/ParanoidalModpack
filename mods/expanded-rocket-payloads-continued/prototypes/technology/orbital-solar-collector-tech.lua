local modutils = require("prototypes.modutils")

data:extend({
    {
      type = "technology",
      name = "orbital-solar-collector",
      icon_size = 128,
      icon = "__expanded-rocket-payloads-continued__/graphic/orbital-solar-collector-128.png",
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "orbital-solar-collector"
        },
      },
      prerequisites = {"extremely-advanced-rocket-payloads"},
      unit =
      {
        count = 30000,
        ingredients = modutils.full_science_pack(),
        time = 40
      },
      order = "y-c"
    },
})
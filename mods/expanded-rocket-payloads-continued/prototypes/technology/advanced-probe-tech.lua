local modutils = require("prototypes.modutils")

data:extend({
  {
    type = "technology",
    name = "advanced-probe",
    icon_size = 128,
    icon = "__expanded-rocket-payloads-continued__/graphic/advanced-probe-128.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "advanced-probe"
      },
      {
        type = "unlock-recipe",
        recipe = "probe-data-processing"
      },
    },
    prerequisites = { "extremely-advanced-material-processing" },
    unit =
    {
      count = 6000,
      ingredients = modutils.full_science_pack(),
      time = 60
    },
    order = "y-b"
  },
})

local modutils = require("prototypes.modutils")

data:extend({
    {
      type = "technology",
      name = "erp-lab",
      icon_size = 128,
      order = "y-b",
      icon = "__expanded-rocket-payloads-continued__/graphic/advanced-chemistry.png",
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "erp-lab"
        },
      },
      prerequisites = {"extremely-advanced-material-processing"},
      unit =
      {
        count = 2000,
        ingredients = modutils.full_science_pack(),
        time = 60
      },
    },
})
local modutils = require("prototypes.modutils")

data:extend({
  {
    type = "technology",
    name = "improved-space-program-theory",
    icon_size = 256,
    icon = "__expanded-rocket-payloads-continued__/graphic/imports/techs/logistics.png",
    prerequisites = modutils.select_any({ "space-science-pack" }, nil, {
      "metallurgic-science-pack", "agricultural-science-pack", "electromagnetic-science-pack", "cryogenic-science-pack"
    }),
    order = "y-b",
    unit =
    {
      count = 2000,
      ingredients = modutils.full_science_pack(),
      time = 60
    },
  },
})

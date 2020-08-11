local BioInd = require('common')('Bio_Industries')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"

-------- Bio Garden

data:extend({

    {
    type = "item",
    name = "bi-bio-garden",
    icon = ICONPATH .. "bio_garden_icon.png",
    icon_size = 64,
    icons = {
        {
            icon = ICONPATH .. "bio_garden_icon.png",
            icon_size = 64,
        }
    },
   --flags = { "goes-to-quickbar" },
    subgroup = "production-machine",
    order = "x[bi]-b[bi-bio-garden]",
    place_result = "bi-bio-garden",
    stack_size = 10
  },

  {
    type = "item",
    name = "bi-purified-air",
    icon = ICONPATH .. "Clean_Air2.png",
    icon_size = 64,
    icons = {
        {
            icon = ICONPATH .. "Clean_Air2.png",
            icon_size = 64,
        }
    },
    flags = {"hidden"},
    subgroup = "bio-bio-gardens-fluid",
    order = "bi-purified-air",
    stack_size = 100
  },
})

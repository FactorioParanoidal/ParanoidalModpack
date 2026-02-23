local BioInd = require('common')('Bio_Industries_2')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"
local ICONPATH_E = BioInd.modRoot .. "/graphics/icons/entity/"

-------- Bio Garden

data:extend({

    {
    type = "item",
    name = "bi-bio-garden",
    icon = ICONPATH_E .. "bio_garden_icon.png",
    icon_size = 64,
    icons = {
        {
            icon = ICONPATH_E .. "bio_garden_icon.png",
            icon_size = 64,
        }
    },
    subgroup = "production-machine",
    order = "x[bi]-b[bi-bio-garden]",
    place_result = "bi-bio-garden",
    stack_size = 10
  },

    {
    type = "item",
    name = "bi-bio-garden-large",
    icon = ICONPATH_E .. "bio_garden_large_icon.png",
    icon_size = 64,
    icons = {
        {
            icon = ICONPATH_E .. "bio_garden_large_icon.png",
            icon_size = 64,
        }
    },
    subgroup = "production-machine",
    order = "x[bi]-c[bi-bio-garden]",
    place_result = "bi-bio-garden-large",
    stack_size = 10
  },

    {
    type = "item",
    name = "bi-bio-garden-huge",
    icon = ICONPATH_E .. "bio_garden_huge_icon.png",
    icon_size = 64,
    icons = {
        {
            icon = ICONPATH_E .. "bio_garden_huge_icon.png",
            icon_size = 64,
        }
    },
    subgroup = "production-machine",
    order = "x[bi]-d[bi-bio-garden]",
    place_result = "bi-bio-garden-huge",
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
    hidden = true,
    subgroup = "bio-bio-gardens-fluid",
    order = "bi-purified-air",
    stack_size = 100
  },
})

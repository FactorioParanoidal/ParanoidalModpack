local BioInd = require('common')('Bio_Industries')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"

data:extend({

  --- Conversion Turret
  {
    type = "item",
    name = "bi-dart-turret",
    icon = ICONPATH .. "bio_turret_icon.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "bio_turret_icon.png",
        icon_size = 64,
      }
    },
    subgroup = "defensive-structure",
    order = "aa[turret]-a[gun-turret]",
    place_result = "bi-dart-turret",
    stack_size = 50
  },
})

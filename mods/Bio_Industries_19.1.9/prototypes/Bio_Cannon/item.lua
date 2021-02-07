local BioInd = require('common')('Bio_Industries')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"

if BI.Settings.Bio_Cannon then
  data:extend({
    -- Hive Buster Turret
    {
      type = "item",
      name = "bi-bio-cannon-area",
      localised_name = {"entity-name.bi-bio-cannon"},
      localised_description = {"entity-description.bi-bio-cannon"},
      icon = ICONPATH .. "biocannon_icon.png",
      icon_size = 64,
      icon_mipmaps = 1,
      icons = {
        {
          icon = ICONPATH .. "biocannon_icon.png",
          icon_size = 64,
        }
      },
      subgroup = "defensive-structure",
      order = "x[turret]-x[gun-turret]",
      place_result = "bi-bio-cannon-area",
      stack_size = 1,
    },
  })
end

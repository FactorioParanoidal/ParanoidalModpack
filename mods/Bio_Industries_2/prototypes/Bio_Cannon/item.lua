local BioInd = require('common')('Bio_Industries_2')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"
local ICONPATH_W = BioInd.modRoot .. "/graphics/icons/weapons/"

if BI.Settings.Bio_Cannon then
  data:extend({
    -- Hive Buster Turret
    {
      type = "item",
      name = "bi-bio-cannon",
      localised_name = {"entity-name.bi-bio-cannon"},
      localised_description = {"entity-description.bi-bio-cannon"},
      icon = ICONPATH_W .. "biocannon_icon.png",
      icon_size = 64,
      subgroup = "defensive-structure",
      order = "x[turret]-x[gun-turret]",
      place_result = "bi-bio-cannon",
      stack_size = 1,
	  weight = 750000,
    },
  })
end

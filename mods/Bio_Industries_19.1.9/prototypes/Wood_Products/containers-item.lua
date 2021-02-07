if not BI.Settings.BI_Bigger_Wooden_Chests then
  return
end

local BioInd = require('common')('Bio_Industries')
local ICONPATH = BioInd.modRoot .. "/graphics/icons/"


BioInd.writeDebug("Creating items for bigger wooden chests!")

data:extend({
  --- Large wooden chest 2 x 2
  {
    type = "item",
    name = "bi-wooden-chest-large",
    localised_name = {"entity-name.bi-wooden-chest-large"},
    localised_description = {"entity-description.bi-wooden-chest-large"},
    icon = ICONPATH .. "large_wooden_chest_icon.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "large_wooden_chest_icon.png",
        icon_size = 64,
      }
    },
    fuel_category = "chemical",
    fuel_value = "32MJ",
    subgroup = "storage",
    order = "a[items]-aa[wooden-chest]",
    place_result = "bi-wooden-chest-large",
    stack_size = 48
  },

  --- Huge wooden chest 3 x 3
  {
    type = "item",
    name = "bi-wooden-chest-huge",
    localised_name = {"entity-name.bi-wooden-chest-huge"},
    localised_description = {"entity-description.bi-wooden-chest-huge"},
    icon = ICONPATH .. "huge_wooden_chest_icon.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "huge_wooden_chest_icon.png",
        icon_size = 64,
      }
    },
    fuel_category = "chemical",
    fuel_value = "200MJ",
    subgroup = "storage",
    order = "a[items]-ab[wooden-chest]",
    place_result = "bi-wooden-chest-huge",
    stack_size = 32
  },

  --- Giga wooden chest 6 x 6
  {
    type = "item",
    name = "bi-wooden-chest-giga",
    localised_name = {"entity-name.bi-wooden-chest-giga"},
    localised_description = {"entity-description.bi-wooden-chest-giga"},
    icon = ICONPATH .. "giga_wooden_chest_icon.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "giga_wooden_chest_icon.png",
        icon_size = 64,
      }
    },
    fuel_category = "chemical",
    fuel_value = "400MJ",
    subgroup = "storage",
    order = "a[items]-ac[wooden-chest]",
    place_result = "bi-wooden-chest-giga",
    stack_size = 16
  },
})

local BioInd = require('common')('Bio_Industries_2')
local ICONPATH = BioInd.modRoot .. "/graphics/icons/"
local ICONPATH_E = BioInd.modRoot .. "/graphics/icons/entity/"
local item_sounds = require("__base__.prototypes.item_sounds")

data:extend({

  --- Big Wooden Electric Pole
  {
    type = "item",
    name = "bi-wooden-pole-big",
    localised_name = {"entity-name.bi-wooden-pole-big"},
    localised_description = {"entity-description.bi-wooden-pole-big"},
	icons = { {icon = ICONPATH_E .. "big-wooden-pole.png", icon_size = 64, } },
    subgroup = "energy-pipe-distribution",
    order = "a[energy]-b[small-electric-pole]",
    place_result = "bi-wooden-pole-big",
    stack_size = 50
  },

  --- Huge Wooden Pole
  {
    type = "item",
    name = "bi-wooden-pole-huge",
    localised_name = {"entity-name.bi-wooden-pole-huge"},
    localised_description = {"entity-description.bi-wooden-pole-huge"},
	icons = { {icon = ICONPATH_E .. "huge-wooden-pole.png", icon_size = 64, } },
    subgroup = "energy-pipe-distribution",
    order = "a[energy]-d[big-electric-pole]",
    place_result = "bi-wooden-pole-huge",
    stack_size = 50
  },

  -- Wooden Fence
  {
    type = "item",
    name = "bi-wooden-fence",
    localised_name = {"entity-name.bi-wooden-fence"},
    localised_description = {"entity-description.bi-wooden-fence"},
	icons = { {icon = ICONPATH_E .. "wooden-fence.png", icon_size = 64, } },
    subgroup = "defensive-structure",
    order = "a-a[stone-wall]-a[wooden-fence]",
    place_result = "bi-wooden-fence",
    fuel_value = "4MJ",
    fuel_category = "chemical",
    stack_size = 50
  },

  --- Wood Pipe
  {
    type = "item",
    name = "bi-wood-pipe",
    localised_name = {"entity-name.bi-wood-pipe"},
    localised_description = {"entity-description.bi-wood-pipe"},
	icons = { {icon = ICONPATH_E .. "wood_pipe.png", icon_size = 64, } },
    subgroup = "energy-pipe-distribution",
    order = "a[pipe]-1a[pipe]",
    place_result = "bi-wood-pipe",
    fuel_value = "4MJ",
    fuel_category = "chemical",
    stack_size = 100
  },

  --- Wood Pipe to Ground
  {
    type = "item",
    name = "bi-wood-pipe-to-ground",
    localised_name = {"entity-name.bi-wood-pipe-to-ground"},
    localised_description = {"entity-description.bi-wood-pipe-to-ground"},
	icons = { {icon = ICONPATH_E .. "pipe-to-ground-wood.png", icon_size = 64, } },
    subgroup = "energy-pipe-distribution",
    order = "a[pipe]-1b[pipe-to-ground]",
    place_result = "bi-wood-pipe-to-ground",
    fuel_value = "20MJ",
    fuel_category = "chemical",
    stack_size = 50
  },
  
})


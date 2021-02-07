local BioInd = require('common')('Bio_Industries')

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"

data:extend({

  --- Big Wooden Electric Pole
  {
    type = "item",
    name = "bi-wooden-pole-big",
    localised_name = {"entity-name.bi-wooden-pole-big"},
    localised_description = {"entity-description.bi-wooden-pole-big"},
    icon = ICONPATH .. "big-wooden-pole.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "big-wooden-pole.png",
        icon_size = 64,
      }
    },
    subgroup = "energy-pipe-distribution",
    order = "a[energy]-b[small-electric-pole]",
    place_result = "bi-wooden-pole-big",
    fuel_value = "14MJ",
    fuel_category = "chemical",
    stack_size = 50
  },

  --- Huge Wooden Pole
  {
    type = "item",
    name = "bi-wooden-pole-huge",
    localised_name = {"entity-name.bi-wooden-pole-huge"},
    localised_description = {"entity-description.bi-wooden-pole-huge"},
    icon = ICONPATH .. "huge-wooden-pole.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "huge-wooden-pole.png",
        icon_size = 64,
      }
    },
    subgroup = "energy-pipe-distribution",
    order = "a[energy]-d[big-electric-pole]",
    place_result = "bi-wooden-pole-huge",
    fuel_value = "90MJ",
    fuel_category = "chemical",
    stack_size = 50
  },

  -- Wooden Fence
  {
    type = "item",
    name = "bi-wooden-fence",
    localised_name = {"entity-name.bi-wooden-fence"},
    localised_description = {"entity-description.bi-wooden-fence"},
    icon = ICONPATH .. "wooden-fence.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "wooden-fence.png",
        icon_size = 64,
      }
    },
    subgroup = "defensive-structure",
    order = "a-a[stone-wall]-a[wooden-fence]",
    place_result = "bi-wooden-fence",
    fuel_value = "4MJ",
    fuel_category = "chemical",
    stack_size = 50
  },

  --- Wood Rail Planner
  {
    type = "rail-planner",
    name = "bi-rail-wood",
    localised_name = {"entity-name.bi-rail-wood"},
    localised_description = {"entity-description.bi-rail-wood"},
    icon = ICONPATH .. "rail-wood.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "rail-wood.png",
        icon_size = 64,
      }
    },
    subgroup = "transport",
    order = "a[train-system]-a[rail]",
    place_result = "bi-straight-rail-wood",
    stack_size = 100,
    straight_rail = "bi-straight-rail-wood",
    curved_rail = "bi-curved-rail-wood"
  },

  --- Wooden Bridge Rail
  {
    type = "rail-planner",
    name = "bi-rail-wood-bridge",
    localised_name = {"entity-name.bi-rail-wood-bridge"},
    localised_description = {"entity-description.bi-rail-wood-bridge"},
    icon = ICONPATH .. "rail-wood-bridge.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "rail-wood-bridge.png",
        icon_size = 64,
      }
    },
    subgroup = "transport",
    order = "a[train-system]-aa[rail]",
    place_result = "bi-straight-rail-wood-bridge",
    stack_size = 100,
    straight_rail = "bi-straight-rail-wood-bridge",
    curved_rail = "bi-curved-rail-wood-bridge"
  },

  --- Electric Rail Planner
  --[[drd
  {
    type = "rail-planner",
    name = "bi-rail-power",
    localised_name = {"entity-name.bi-rail-power"},
    localised_description = {"entity-description.bi-rail-power"},
    icon = ICONPATH .. "rail-concrete-power.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "rail-concrete-power.png",
        icon_size = 64,
      }
    },
    subgroup = "transport",
    order = "a[train-system]-ab[rail]",
    place_result = "bi-straight-rail-power",
    stack_size = 100,
    straight_rail = "bi-straight-rail-power",
    curved_rail = "bi-curved-rail-power"
  },
]]--
  --- Wood Pipe
  {
    type = "item",
    name = "bi-wood-pipe",
    localised_name = {"entity-name.bi-wood-pipe"},
    localised_description = {"entity-description.bi-wood-pipe"},
    icon = ICONPATH .. "wood_pipe.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "wood_pipe.png",
        icon_size = 64,
      }
    },
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
    icon = ICONPATH .. "pipe-to-ground-wood.png",
    icon_size = 64,
    icons = {
      {
        icon = ICONPATH .. "pipe-to-ground-wood.png",
        icon_size = 64,
      }
    },
    subgroup = "energy-pipe-distribution",
    order = "a[pipe]-1b[pipe-to-ground]",
    place_result = "bi-wood-pipe-to-ground",
    fuel_value = "20MJ",
    fuel_category = "chemical",
    stack_size = 50
  },

  --~ --- Large wooden chest 2 x 2
  --~ {
    --~ type = "item",
    --~ name = "bi-wooden-chest-large",
    --~ localised_name = {"entity-name.bi-wooden-chest-large"},
    --~ localised_description = {"entity-description.bi-wooden-chest-large"},
    --~ icon = ICONPATH .. "large_wooden_chest_icon.png",
    --~ icon_size = 64,
    --~ icons = {
      --~ {
        --~ icon = ICONPATH .. "large_wooden_chest_icon.png",
        --~ icon_size = 64,
      --~ }
    --~ },
    --~ fuel_category = "chemical",
    --~ fuel_value = "32MJ",
    --~ subgroup = "storage",
    --~ order = "a[items]-aa[wooden-chest]",
    --~ place_result = "bi-wooden-chest-large",
    --~ stack_size = 48
  --~ },

  --~ --- Huge wooden chest 3 x 3
  --~ {
    --~ type = "item",
    --~ name = "bi-wooden-chest-huge",
    --~ localised_name = {"entity-name.bi-wooden-chest-huge"},
    --~ localised_description = {"entity-description.bi-wooden-chest-huge"},
    --~ icon = ICONPATH .. "huge_wooden_chest_icon.png",
    --~ icon_size = 64,
    --~ icons = {
      --~ {
        --~ icon = ICONPATH .. "huge_wooden_chest_icon.png",
        --~ icon_size = 64,
      --~ }
    --~ },
    --~ fuel_category = "chemical",
    --~ fuel_value = "200MJ",
    --~ subgroup = "storage",
    --~ order = "a[items]-ab[wooden-chest]",
    --~ place_result = "bi-wooden-chest-huge",
    --~ stack_size = 32
  --~ },

  --~ --- Giga wooden chest 6 x 6
  --~ {
    --~ type = "item",
    --~ name = "bi-wooden-chest-giga",
    --~ localised_name = {"entity-name.bi-wooden-chest-giga"},
    --~ localised_description = {"entity-description.bi-wooden-chest-giga"},
    --~ icon = ICONPATH .. "giga_wooden_chest_icon.png",
    --~ icon_size = 64,
    --~ icons = {
      --~ {
        --~ icon = ICONPATH .. "giga_wooden_chest_icon.png",
        --~ icon_size = 64,
      --~ }
    --~ },
    --~ fuel_category = "chemical",
    --~ fuel_value = "400MJ",
    --~ subgroup = "storage",
    --~ order = "a[items]-ac[wooden-chest]",
    --~ place_result = "bi-wooden-chest-giga",
    --~ stack_size = 16
  --~ },

  ---- Power pole to connect Rail to Power Grid
  --[[drd
  {
    type = "item",
    name = "bi-power-to-rail-pole",
    localised_name = {"entity-name.bi-power-to-rail-pole"},
    localised_description = {"entity-description.bi-power-to-rail-pole"},
    icon = ICONPATH .. "electric-to-rail.png",
    icon_size = 64,
    icon_mipmaps = 1,
    icons = {
      {
        icon = ICONPATH .. "electric-to-rail.png",
        icon_size = 64,
      }
    },
    subgroup = "transport",
    order = "a[train-system]-ac[rail]",
    place_result = "bi-power-to-rail-pole",
    stack_size = 50
  },
  ]]--
})

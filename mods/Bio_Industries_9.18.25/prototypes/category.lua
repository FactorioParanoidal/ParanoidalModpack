--~ local BioInd = require('common')('Bio_Industries')

data:extend(
  {

    {
      type = "item-group",
      name = "bio-industries",
      order = "vaa-a",
      inventory_order = "v-a",
      icon = "__Bio_Industries__/graphics/technology/BioIndustries_64.png",
      icon_size = 64,
      icons = {
          {
              icon = "__Bio_Industries__/graphics/technology/BioIndustries_64.png",
              icon_size = 64,
          }
      },
    },

     {
      type = "item-subgroup",
      name = "bio-bio-farm",
      group = "bio-industries",
      order = "a-a",
    },


  --- Bio Farm and Nursary
    {
      type = "item-subgroup",
      name = "bio-bio-farm-fluid-1",
      group = "bio-industries",
      order = "a-a",
    },
    {
      type = "item-subgroup",
      name = "bio-bio-farm-fluid-2",
      group = "bio-industries",
      order = "a-b",
    },
    {
      type = "item-subgroup",
      name = "bio-bio-farm-fluid-3",
      group = "bio-industries",
      order = "a-c",
    },
    {
      type = "item-subgroup",
      name = "bio-bio-farm-fluid-entity",
      group = "bio-industries",
      order = "a-d",
    },

    ---- Solar Entities
      {
      type = "item-subgroup",
      name = "bio-bio-solar-entity",
      group = "bio-industries",
      order = "a-solar",
    },


  --- Coals and Cokery and Crushed Stone and Crusher
    {
      type = "item-subgroup",
      name = "bio-bio-farm-raw",
      group = "bio-industries",
      order = "b-a",
    },
    {
      type = "item-subgroup",
      name = "bio-bio-farm-raw-entity",
      group = "bio-industries",
      order = "b-b",
    },

    ----- Other Int Products
    {
      type = "item-subgroup",
      name = "bio-bio-farm-intermediate-product",
      group = "bio-industries",
      order = "c-a",
    },

    ---- Arboretum
    {
      type = "item-subgroup",
      name = "bio-arboretum-fluid",
      group = "bio-industries",
      order = "c-c",
    },
    {
      type = "item-subgroup",
      name = "bio-arboretum-fluid-entity",
      group = "bio-industries",
      order = "c-d",
    },

    --- Bio Reactor and Bio-Mass
    {
      type = "item-subgroup",
      name = "bio-bio-fuel-fluid",
      group = "bio-industries",
      order = "d-a-1"
    },
    {
      type = "item-subgroup",
      name = "bio-bio-fuel-fluid-entity",
      group = "bio-industries",
      order = "d-a-2"
    },
    ---- Bio Fuel Solids
     {
      type = "item-subgroup",
      name = "bio-bio-fuel-solid",
      group = "bio-industries",
      order = "e"
    },
    ---- Bio Fuel OTHER
     {
      type = "item-subgroup",
      name = "bio-bio-fuel-other",
      group = "bio-industries",
      order = "f"
    },

    ---- Garden
    {
      type = "item-subgroup",
      name = "bio-bio-gardens-fluid",
      group = "bio-industries",
      order = "x-a"
    },
    {
      type = "item-subgroup",
      name = "bio-bio-gardens-fluid-entity",
      group = "bio-industries",
      order = "x-b"
    },

    {
      type = "item-subgroup",
      name = "bio-transport",
      group = "bio-industries",
      order = "e-a",
    },
    {
      type = "item-subgroup",
      name = "bio-logistic-robots",
      group = "bio-industries",
      order = "f-a",
    },
    {
      type = "item-subgroup",
      name = "bio-logistic-roboport",
      group = "bio-industries",
      order = "f-b",
    },


    {
      type = "item-subgroup",
      name = "bio-tool",
      group = "production",
      order = "a-1",
    },
    {
      type = "item-subgroup",
      name = "bio-energy-boiler",
      group = "production",
      order = "b-a"
    },
    {
      type = "item-subgroup",
      name = "bio-energy-steam-engine",
      group = "production",
      order = "b-b"
    },
    {
      type = "item-subgroup",
      name = "bio-energy-solar-panel",
      group = "production",
      order = "b-c"
    },
    {
      type = "item-subgroup",
      name = "bio-energy-accumulator",
      group = "production",
      order = "b-d"
    },
    {
      type = "item-subgroup",
      name = "bio-extraction-machine",
      group = "production",
      order = "c-a",
    },
    {
      type = "item-subgroup",
      name = "bio-pump",
      group = "production",
      order = "c-b",
    },
    {
      type = "item-subgroup",
      name = "bio-smelting-machine",
      group = "production",
      order = "d-a",
    },
    {
      type = "item-subgroup",
      name = "bio-production-machine",
      group = "production",
      order = "e-a",
    },
    {
      type = "item-subgroup",
      name = "bio-assembly-machine",
      group = "production",
      order = "e-b",
    },
    {
      type = "item-subgroup",
      name = "bio-chemical-machine",
      group = "production",
      order = "e-c",
    },
    {
      type = "item-subgroup",
      name = "bio-electrolyser-machine",
      group = "production",
      order = "e-d",
    },
    {
      type = "item-subgroup",
      name = "bio-refinery-machine",
      group = "production",
      order = "e-e",
    },

    ---- Ammo for Bio Turrets/Bio Cannon
    {
      type = "item-subgroup",
      name = "bi-ammo",
      group = "combat",
      order = "b-[bi-ammo]"
    },

    --[[
     {
      type = "recipe-category",
      name = "crafting-machine"
    },
    ]]
  }
)

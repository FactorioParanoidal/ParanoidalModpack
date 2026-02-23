local cfg1 = require("config.config-1")
local PTpt = require("lib.PTpt")



local PT_specs =
{
  recipe = {
    [1] = {
      energy_required = 10,
      ingredients = {
        {type = "item", name = "radar", amount = 1},
        {type = "item", name = "steel-chest", amount = 1},
        {type = "item", name = "electronic-circuit", amount = 10}
      },
    },
    [2] = {
      energy_required = 30,
      ingredients = {
        {type = "item", name = "__PT__1__", amount = 4},
        {type = "item", name = "advanced-circuit", amount = 10}
      },
    },
    [3] = {
      energy_required = 50,
      ingredients = {
        {type = "item", name = "__PT__2__", amount = 4},
        {type = "item", name = "advanced-circuit", amount = 10}
      },
    },
    [4] = {
      energy_required = 70,
      ingredients = {
        {type = "item", name = "__PT__3__", amount = 4},
        {type = "item", name = "processing-unit", amount = 10}
      },
    },
  },
  technology = {
    [1] = {
      prerequisites = {"military-science-pack", "electric-energy-distribution-1"},
      unit =
      {
        count = 150,
        ingredients =
        {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"military-science-pack", 1}
        },
        time = 15
      },
    },
    [2] = {
      prerequisites = {"__PT__1__", "electric-energy-distribution-2"},
      unit =
      {
        count = 200,
        ingredients =
        {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"military-science-pack", 1}
        },
        time = 30
      },
    },
    [3] = {
      prerequisites = {"__PT__2__"},
      unit =
      {
        count = 250,
        ingredients =
        {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"military-science-pack", 1}
        },
        time = 30
      },
    },
    [4] = {
      prerequisites = {"__PT__3__"},
      unit =
      {
        count = 300,
        ingredients =
        {
          {"automation-science-pack", 1},
          {"logistic-science-pack", 1},
          {"chemical-science-pack", 1},
          {"military-science-pack", 1},
          {"utility-science-pack", 1}
        },
        time = 45
      },
    },

  },
}

local dataextendlist = {}

local tier_max = cfg1.tier_max

for tier = 1, tier_max, 1 do
  table.insert( dataextendlist, PTpt.PT_item_1    (tier) )
  table.insert( dataextendlist, PTpt.PT_item_2    (tier) )
  table.insert( dataextendlist, PTpt.PT_entity_1  (tier) )
  table.insert( dataextendlist, PTpt.PT_entity_2  (tier) )
  table.insert( dataextendlist, PTpt.PT_recipe    (tier, PT_specs) )
  table.insert( dataextendlist, PTpt.PT_technology(tier, PT_specs) )
end


if next(dataextendlist) ~= nil then
  data:extend(dataextendlist)
end
local nuke_materials = require("__True-Nukes__.prototypes.nukes.data-nukes-material")

local dead = nuke_materials.deadMaterial
local boom = nuke_materials.UBoomMaterial
local small = nuke_materials.smallBoomMaterial
local light = nuke_materials.lightMaterial
local reflector = nuke_materials.reflector
local computer = nuke_materials.computer
local fusionMaterial = nuke_materials.fusionMaterial

log("hello")
if(warheads["TN-warhead-20--1"]) then
  data:extend{
    {
      type = "recipe",
      name = "TN-warhead-20--1-uranium",
      order = "x-n-a-m-00020-1z",
      energy_required = 90,
      enabled = false,
      subgroup = "large-warheads",
      ingredients = {
        {"steel-plate", 10},
        {computer, 8},
        {"explosives", 30},
        {dead, 15},
        {boom, 30}
      },
      result = "TN-warhead-20--1"
    }
  }
if(data.raw.technology["basic-atomic-weapons"]) then

  table.insert(data.raw.technology["basic-atomic-weapons"].effects, 1, {type = "unlock-recipe", recipe = "TN-warhead-20--1-uranium"})
end
end
if(warheads["TN-warhead-20--2"]) then
  data:extend{
  {
    type = "recipe",
    name = "TN-warhead-20--2-uranium",
    order = "x-n-a-m-00020-2z",
    energy_required = 180,
    enabled = false,
    subgroup = "medium-warheads",
    ingredients = {
      {light, 20},
      {computer, 20},
      {"explosives", 15},
      {dead, 5},
      {boom, 50}
    },
    result = "TN-warhead-20--2"
  }
  }
table.insert(data.raw.technology["atomic-bomb"].effects, 1, {type = "unlock-recipe", recipe = "TN-warhead-20--2-uranium"})
end



if(warheads["TN-warhead-8--1"]) then
  data:extend{
  {
    type = "recipe",
    name = "TN-warhead-8--1-uranium",
    order = "x-n-a-m-00008-1z",
    energy_required = 60,
    enabled = false,
    subgroup = "medium-warheads",
    ingredients = {
      {"steel-plate", 6},
      {computer, 5},
      {"explosives", 20},
      {dead, 10},
      {boom, 15}
    },
    result = "TN-warhead-8--1"
  }
  }
table.insert(data.raw.technology["atomic-bomb"].effects, 1, {type = "unlock-recipe", recipe = "TN-warhead-8--1-uranium"})
end
if(warheads["TN-warhead-4--1"]) then
  data:extend{
  {
    type = "recipe",
    name = "TN-warhead-4--1-uranium",
    order = "x-n-a-m-00004-1z",
    energy_required = 45,
    enabled = false,
    subgroup = "medium-warheads",
    ingredients = {
      {"steel-plate", 5},
      {computer, 5},
      {"explosives", 10},
      {dead, 5},
      {boom, 8}
    },
    result = "TN-warhead-4--1"
  }
  }
table.insert(data.raw.technology["atomic-bomb"].effects, 1, {type = "unlock-recipe", recipe = "TN-warhead-4--1-uranium"})
end

local shared = require("shared")
local util = require("util")

local packs =
{
  "automation-science-pack",
  "logistic-science-pack",
  "chemical-science-pack",
  "production-science-pack",
  "utility-science-pack"
}

-- Prerequisites another mod may not have: only those that exist are kept.
local function existing(names)
  local list = {}
  for _, name in pairs(names) do
    if data.raw.technology[name] then
      list[#list + 1] = name
    end
  end
  return list
end

-- An upgrade, a technology per level. The script applies it (it counts the levels researched), so the effect only
-- describes it. Each level is {count, the packs it takes, a prerequisite besides the level before}.
local function upgrade(spec)
  assert(#spec.levels == spec.level_count, spec.name .. "'s levels don't match shared.lua")
  for level, cost in pairs(spec.levels) do
    local ingredients = {}
    for _, index in pairs(cost[2]) do
      ingredients[#ingredients + 1] = {packs[index], 1}
    end
    data:extend
    {
      {
        type = "technology",
        name = spec.name .. "-" .. level,
        icons = spec.icons,
        effects =
        {
          {
            type = "nothing",
            effect_description = {"modifier-description." .. spec.name, tostring(spec.bonus * 100)},
            icon = spec.effect_icon,
            icon_size = 64
          }
        },
        prerequisites = level == 1 and existing(spec.prerequisites) or existing{spec.name .. "-" .. (level - 1), cost[3]},
        unit = {count = cost[1], ingredients = ingredients, time = 30},
        upgrade = true
      }
    }
  end
end

-- Д-ОК comes early: the crash leaves debris for him, and stone paths are the first floors.
data:extend
{
  {
    type = "technology",
    name = shared.technology,
    icon = shared.mod .. "/graphics/technology/droid-m-o.png",
    icon_size = 256,
    prerequisites = existing{"electronics", "automation"},
    effects = {{type = "unlock-recipe", recipe = shared.dock}},
    unit = {count = 60, ingredients = {{packs[1], 1}}, time = 15}
  }
}

upgrade
{
  name = shared.battery_technology,
  bonus = shared.battery_bonus,
  level_count = shared.battery_levels,
  icons = util.technology_icon_constant_capacity(shared.mod .. "/graphics/technology/droid-m-o.png"),
  effect_icon = shared.mod .. "/graphics/icons/droid-m-o.png",
  prerequisites = {shared.technology, "battery"},
  levels =
  {
    {150, {1, 2}},
    {200, {1, 2, 3}, "chemical-science-pack"},
    {300, {1, 2, 3, 4}, "production-science-pack"},
    {500, {1, 2, 3, 4, 5}, "utility-science-pack"}
  }
}

upgrade
{
  name = shared.charging_technology,
  bonus = shared.charging_bonus,
  level_count = shared.charging_levels,
  icons = util.technology_icon_constant_speed(shared.mod .. "/graphics/technology/droid-m-o-dock.png"),
  effect_icon = shared.mod .. "/graphics/icons/droid-m-o-dock.png",
  prerequisites = {shared.technology, "electric-energy-accumulators"},
  levels =
  {
    {150, {1, 2}},
    {250, {1, 2, 3}, "chemical-science-pack"},
    {400, {1, 2, 3, 5}, "utility-science-pack"}
  }
}

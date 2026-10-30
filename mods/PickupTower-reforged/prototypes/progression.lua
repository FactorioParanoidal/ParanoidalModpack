-- Recipes and research. Each tier is the previous tower plus Bob's radars of the matching tier
-- (vanilla radars without bobwarfare); research follows the same radar research.
local S = require("shared")

local function have_item(name) return data.raw.item[name] ~= nil end
local function radar(name) return have_item(name) and name or "radar" end

local function item(name, amount) return {type = "item", name = name, amount = amount} end

local recipes = {
  {time = 10, ingredients = {item("radar", 1), item("steel-chest", 1), item("electronic-circuit", 10)}},
  {time = 30, ingredients = {item(S.tower(1), 1), item(radar("bob-radar-3"), 2), item("advanced-circuit", 10)}},
  {time = 50, ingredients = {item(S.tower(2), 1), item(radar("bob-radar-4"), 2), item("advanced-circuit", 20)}},
  {time = 70, ingredients = {item(S.tower(3), 1), item(radar("bob-radar-5"), 2), item("processing-unit", 10)}},
}

local A, L, C, M, P, U = "automation-science-pack", "logistic-science-pack", "chemical-science-pack",
  "military-science-pack", "production-science-pack", "utility-science-pack"

local research = {
  {count = 150, time = 15, packs = {A, L, M}, prerequisites = {"military-science-pack", "electric-energy-distribution-1"}},
  {count = 200, time = 30, packs = {A, L, C, M}, prerequisites = {"electric-energy-distribution-2", "bob-radar-3"}},
  {count = 250, time = 30, packs = {A, L, C, M, P}, prerequisites = {"bob-radar-4"}},
  {count = 300, time = 45, packs = {A, L, C, M, P, U}, prerequisites = {"bob-radar-5"}},
}

local list = {}
for tier, r in ipairs(recipes) do
  local name = S.tower(tier)
  list[#list + 1] = {
    type = "recipe",
    name = name,
    enabled = false,
    energy_required = r.time,
    ingredients = r.ingredients,
    results = {item(name, 1)},
  }

  local t = research[tier]
  local prerequisites = tier > 1 and {S.tower(tier - 1)} or {}
  for _, p in ipairs(t.prerequisites) do
    if data.raw.technology[p] then prerequisites[#prerequisites + 1] = p end
  end
  local packs = {}
  for _, p in ipairs(t.packs) do
    if data.raw.tool[p] then packs[#packs + 1] = {p, 1} end
  end
  list[#list + 1] = {
    type = "technology",
    name = name,
    icons = {{icon = "__PickupTower-reforged__/graphics/technology/pickup-tower.png", icon_size = 256}},
    effects = {{type = "unlock-recipe", recipe = name}},
    prerequisites = prerequisites,
    unit = {count = t.count, ingredients = packs, time = t.time},
    upgrade = true,
    order = "c-e-c",
  }
end

data:extend(list)

local shared = require("shared")

local T = shared.tech
local icons = shared.mod .. "/graphics/technology/"
local red, green, blue = "automation-science-pack", "logistic-science-pack", "chemical-science-pack"

-- Her own technologies (added below, all at once) are always kept.
local own = {[T.base] = true, [T.lamp] = true, [T.trail] = true, [T.vacuum] = true, [T.defib] = true}
for _, name in pairs(T.memory) do
  own[name] = true
end
if mods["paranoidal-rain"] then
  own[T.umbrella] = true
end

-- Prerequisites another mod may not have: only those that exist are kept.
local function existing(names)
  local list = {}
  for _, name in pairs(names) do
    if own[name] or data.raw.technology[name] then
      list[#list + 1] = name
    end
  end
  return list
end

local function packs(count, ...)
  local ingredients = {}
  for _, pack in pairs{...} do
    ingredients[#ingredients + 1] = {pack, 1}
  end
  return {count = count, ingredients = ingredients, time = 30}
end

-- Every ability is applied by the script; the technology only shows it.
local function tech(name, prerequisites, unit, extra_effects)
  local effects = extra_effects or {}
  effects[#effects + 1] = {type = "nothing", effect_description = {"modifier-description." .. name}, icon = shared.mod .. "/graphics/icons/nan-e.png", icon_size = 64}
  return
  {
    type = "technology",
    name = name,
    localised_description = {"technology-description." .. name},
    icons = {{icon = icons .. name .. ".png", icon_size = 256}},
    effects = effects,
    prerequisites = existing(prerequisites),
    unit = unit
  }
end

-- Early, like Д-ОК: the Axiom-6 lies near the crash site. A new one is a refurbished unit in a BnL box.
local list =
{
  tech(T.base, {"electronics", "automation"}, packs(30, red), {{type = "unlock-recipe", recipe = shared.item}}),
  -- Her branch: a part of a reject robot of the Repair Ward each, as she was patched together.
  tech(T.lamp, {T.base, "lamp"}, packs(40, red)),
  tech(T.trail, {T.lamp}, packs(60, red)),
  tech(T.vacuum, {T.trail, green}, packs(75, red, green)),
  tech(T.defib, {T.vacuum, "military-2"}, packs(120, red, green)),
  -- Her memory: every step lets her read the cards of one more chapter.
  tech(T.memory[1], {T.base}, packs(40, red)),
  tech(T.memory[2], {T.memory[1], green}, packs(60, red, green)),
  tech(T.memory[3], {T.memory[2]}, packs(120, red, green)),
  tech(T.memory[4], {T.memory[3], blue}, packs(100, red, green, blue))
}
-- The umbrella only means something where it rains.
if mods["paranoidal-rain"] then
  list[#list + 1] = tech(T.umbrella, {T.vacuum}, packs(100, red, green))
end
data:extend(list)

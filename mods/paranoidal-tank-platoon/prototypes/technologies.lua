local shared = require("prototypes.shared")

local A, L, C, M = "automation-science-pack", "logistic-science-pack", "chemical-science-pack", "military-science-pack"
local U, P = "utility-science-pack", "production-science-pack"

local base_tank_icon = {icon = "__base__/graphics/technology/tank.png", icon_size = 256}

local function tank_icons(class)
  if not class then return {base_tank_icon} end
  return {base_tank_icon, {icon = shared.technology_icons .. "tank-" .. class .. ".png", icon_size = 256}}
end

local function technology(spec)
  local effects = {}
  for _, recipe in pairs(spec.unlocks) do
    table.insert(effects, {type = "unlock-recipe", recipe = recipe})
  end
  local ingredients = {}
  for _, pack in pairs(spec.packs) do
    table.insert(ingredients, {pack, 1})
  end
  return {
    type = "technology",
    name = spec.name,
    icons = spec.icons,
    effects = effects,
    prerequisites = spec.prerequisites,
    unit = {count = spec.count, ingredients = ingredients, time = spec.time or 30},
    upgrade = spec.upgrade,
    order = spec.order
  }
end

local list = {
  {name = "Schall-sniper-rifle", icons = {{icon = shared.technology_icons .. "sniper-rifle.png", icon_size = 256}},
   prerequisites = {"military-2"}, count = 20, time = 15, packs = {A, L}, order = "m-g-b",
   unlocks = {"Schall-sniper-rifle", "Schall-sniper-firearm-magazine", "Schall-sniper-piercing-rounds-magazine"}},

  {name = "Schall-tank-H-0", icons = tank_icons("H"), prerequisites = {"tank"}, count = 150, packs = {A, L, C, M},
   upgrade = true, order = "e-c-d", unlocks = {"Schall-tank-H", "cannon-H1-shell", "explosive-cannon-H1-shell"}},
  {name = "Schall-tank-SH-0", icons = tank_icons("SH"), prerequisites = {"Schall-tank-H-0", "modular-armor"}, count = 300, packs = {A, L, C, M},
   upgrade = true, order = "e-c-e", unlocks = {"Schall-tank-SH", "cannon-H2-shell", "explosive-cannon-H2-shell"}},
  {name = "Schall-tank-F-0", icons = tank_icons("F"), prerequisites = {"tank", "flamethrower"}, count = 50, packs = {A, L, M},
   upgrade = true, order = "e-c-f", unlocks = {"Schall-tank-F", "incendiary-autocannon-shell"}},
}

if shared.tier_enabled(1) then
  table.insert(list, {name = "Schall-tank-1", icons = tank_icons(), prerequisites = {"tank", "power-armor"}, count = 150, packs = {A, L, C, M},
    upgrade = true, order = "e-c-c-1", unlocks = {"Schall-tank-L-mk1", "Schall-tank-M-mk1"}})
  table.insert(list, {name = "Schall-tank-H-1", icons = tank_icons("H"), prerequisites = {"Schall-tank-H-0", "Schall-tank-1"}, count = 300, packs = {A, L, C, M},
    upgrade = true, order = "e-c-d-1", unlocks = {"Schall-tank-H-mk1"}})
  table.insert(list, {name = "Schall-tank-SH-1", icons = tank_icons("SH"), prerequisites = {"Schall-tank-SH-0", "Schall-tank-H-1"}, count = 600, packs = {A, L, C, M, U},
    upgrade = true, order = "e-c-e-1", unlocks = {"Schall-tank-SH-mk1"}})
  table.insert(list, {name = "Schall-tank-F-1", icons = tank_icons("F"), prerequisites = {"Schall-tank-F-0", "Schall-tank-1"}, count = 75, packs = {A, L, C, M},
    upgrade = true, order = "e-c-f-1", unlocks = {"Schall-tank-F-mk1"}})
end

if shared.tier_enabled(2) then
  table.insert(list, {name = "Schall-tank-2", icons = tank_icons(), prerequisites = {"Schall-tank-1", "power-armor-mk2"}, count = 300, packs = {A, L, C, M, U},
    upgrade = true, order = "e-c-c-2", unlocks = {"Schall-tank-L-mk2", "Schall-tank-M-mk2"}})
  table.insert(list, {name = "Schall-tank-H-2", icons = tank_icons("H"), prerequisites = {"Schall-tank-H-1", "Schall-tank-2"}, count = 600, packs = {A, L, C, M, U},
    upgrade = true, order = "e-c-d-2", unlocks = {"Schall-tank-H-mk2"}})
  table.insert(list, {name = "Schall-tank-SH-2", icons = tank_icons("SH"), prerequisites = {"Schall-tank-SH-1", "Schall-tank-H-2"}, count = 1200, packs = {A, L, C, M, P, U},
    upgrade = true, order = "e-c-e-2", unlocks = {"Schall-tank-SH-mk2"}})
  table.insert(list, {name = "Schall-tank-F-2", icons = tank_icons("F"), prerequisites = {"Schall-tank-F-1", "Schall-tank-2"}, count = 150, packs = {A, L, C, M, U},
    upgrade = true, order = "e-c-f-2", unlocks = {"Schall-tank-F-mk2"}})
end

local technologies = {}
for _, spec in pairs(list) do
  table.insert(technologies, technology(spec))
end
data:extend(technologies)

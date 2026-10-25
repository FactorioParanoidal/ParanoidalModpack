-- Technologies (loaded from data-updates.lua). The tree starts in the chemical (blue) science
-- era and uses military science packs throughout:
--
--   Army robotics ─┬─ Riflebot ── Battle droid ─┬─ Rocket droid ─┬─ Terminator
--                  │                            └─ Flamebot ──────┘
--                  └─ Defender unit ── Distractor unit ── Destroyer unit
--
-- External prerequisites that do not exist (other mod set) are skipped. The science packs of a
-- technology are its own packs plus the packs of its external prerequisites, so a tech never
-- asks for less science than the technologies it builds on.
local shared = require("lib.shared")

local TECH = shared.mod_path .. "/graphics/technology/"
local B = shared.buildings

local PACK_ORDER = {
  "automation-science-pack", "logistic-science-pack", "chemical-science-pack", "military-science-pack",
  "production-science-pack", "utility-science-pack", "bob-advanced-logistic-science-pack", "space-science-pack",
}
local BASE_PACKS = {"automation-science-pack", "logistic-science-pack", "chemical-science-pack", "military-science-pack"}

-- Existence only (see recipes.lua: hidden flags may still change in later stages).
local function usable_tech(name)
  return data.raw.technology[name] ~= nil
end

local function science(own, prerequisites)
  local wanted = {}
  for _, pack in pairs(own) do wanted[pack] = true end
  for _, name in pairs(prerequisites) do
    local unit = data.raw.technology[name] and data.raw.technology[name].unit
    for _, ingredient in pairs(unit and unit.ingredients or {}) do
      wanted[ingredient[1] or ingredient.name] = true
    end
  end
  local packs = {}
  for _, pack in pairs(PACK_ORDER) do
    if wanted[pack] and data.raw.tool[pack] then
      packs[#packs + 1] = {pack, 1}
      wanted[pack] = nil
    end
  end
  for pack in pairs(wanted) do
    if data.raw.tool[pack] then packs[#packs + 1] = {pack, 1} end
  end
  return packs
end

local prototypes = {}

local function technology(name, icon, own_prerequisites, external, count, time, extra_packs, recipes, order)
  local prerequisites, present = {}, {}
  for _, p in pairs(own_prerequisites) do prerequisites[#prerequisites + 1] = p end
  for _, p in pairs(external) do
    if usable_tech(p) then
      prerequisites[#prerequisites + 1] = p
      present[#present + 1] = p
    end
  end
  local own_packs = {}
  for _, p in pairs(BASE_PACKS) do own_packs[#own_packs + 1] = p end
  for _, p in pairs(extra_packs) do own_packs[#own_packs + 1] = p end
  local effects = {}
  for i, recipe in pairs(recipes) do
    effects[i] = {type = "unlock-recipe", recipe = recipe}
  end
  prototypes[#prototypes + 1] = {
    type = "technology",
    name = name,
    icon = TECH .. icon .. ".png",
    icon_size = 256,
    prerequisites = prerequisites,
    unit = {count = count, ingredients = science(own_packs, present), time = time},
    effects = effects,
    order = order,
  }
end

local function droid(name) return {name, name .. "-deploy"} end

local ROBOTICS = "robotarmy-tech-robotics"
local RIFLE = "robotarmy-tech-droid-rifle"
local SMG = "robotarmy-tech-droid-smg"
local ROCKET = "robotarmy-tech-droid-rocket"
local FLAME = "robotarmy-tech-droid-flame"
local DEFENDER = "robotarmy-tech-defender-unit"
local DISTRACTOR = "robotarmy-tech-distractor-unit"

local base_recipes = {B.assembler, B.station, B.counter}
if settings.startup[shared.setting.loot_chest].value then
  base_recipes[#base_recipes + 1] = B.loot
end

technology(ROBOTICS, ROBOTICS, {},
  {"chemical-science-pack", "military-3", "automation-3", "circuit-network", "electric-engine",
   "concrete", "angels-metallurgy-2", "angels-invar-smelting-1", "bob-cobalt-processing"},
  250, 30, {}, base_recipes, "c-c-a")
technology(RIFLE, RIFLE, {ROBOTICS}, {"military-3"},
  200, 30, {}, droid("droid-rifle"), "c-c-b")
technology(SMG, "robotarmy-tech-droid-smg", {RIFLE}, {"modular-armor", "angels-cobalt-steel-smelting-1"},
  300, 30, {}, droid("droid-smg"), "c-c-c")
technology(ROCKET, ROCKET, {SMG}, {"rocketry"},
  400, 30, {}, droid("droid-rocket"), "c-c-d")
technology(FLAME, FLAME, {SMG}, {"flamethrower", "bob-titanium-processing", "angels-titanium-smelting-1"},
  400, 30, {}, droid("droid-flame"), "c-c-e")
technology("robotarmy-tech-droid-terminator", "robotarmy-tech-droid-terminator", {ROCKET, FLAME},
  {"military-4", "power-armor", "laser-turret", "bob-laser-turrets-2", "low-density-structure", "bob-battery-2"},
  600, 45, {}, droid("terminator"), "c-c-f")
technology(DEFENDER, DEFENDER, {ROBOTICS}, {"defender"},
  300, 30, {}, droid("defender-unit"), "c-c-g")
technology(DISTRACTOR, DISTRACTOR, {DEFENDER}, {"distractor"},
  500, 30, {}, droid("distractor-unit"), "c-c-h")
technology("robotarmy-tech-destroyer-unit", "robotarmy-tech-destroyer-unit", {DISTRACTOR}, {"destroyer"},
  600, 30, {}, droid("destroyer-unit"), "c-c-i")

data:extend(prototypes)

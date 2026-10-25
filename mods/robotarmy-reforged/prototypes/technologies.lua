-- Technologies (loaded from data-updates.lua). The tree starts in the chemical (blue) science
-- era and uses military science packs throughout:
--
--   Army robotics ─┬─ Riflebot ─┬─ Battle droid ─┬─ Rocket droid ─┬─ Terminator ── Plasma terminator
--                  │            ├─ Scout         │  └─ Chemical   │
--                  │            ├─ Sniper        ├─ Flamebot ─────┤
--                  │            └─ Miner         │  └─ Heavy assault droid
--                  │                             ├─ Repair droid
--                  │                             ├─ Laser rifleman ── Tesla droid
--                  │                             └─ Drop pod
--                  ├─ Defender unit ── Distractor unit ── Destroyer unit
--                  └─ Bob's drones in the army
--
-- Droid weapon research (own ammo categories): bullets, rockets, energy weapons — damage and
-- rate of fire; flame and electric weapons — rate of fire. Levels 4+ also need utility science.
--
-- External prerequisites that do not exist (other mod set) are skipped. The science packs of a
-- technology are its own packs plus the packs of all its prerequisites, so a tech never asks for
-- less science than the technologies it builds on.
local util = require("util")
local shared = require("lib.shared")

local TECH = shared.mod_path .. "/graphics/technology/"
local B = shared.buildings
local A = shared.ammo

local PACK_ORDER = {
  "automation-science-pack", "logistic-science-pack", "chemical-science-pack", "military-science-pack",
  "production-science-pack", "utility-science-pack", "bob-advanced-logistic-science-pack", "space-science-pack",
}
local BASE_PACKS = {"automation-science-pack", "logistic-science-pack", "chemical-science-pack", "military-science-pack"}

-- Existence only (see recipes.lua: hidden flags may still change in later stages).
local function usable_tech(name)
  return data.raw.technology[name] ~= nil
end

local prototypes = {}
local defined = {} -- technologies of this file: name -> prototype

local function science(own, prerequisites)
  local wanted = {}
  for _, pack in pairs(own) do wanted[pack] = true end
  for _, name in pairs(prerequisites) do
    local tech = defined[name] or data.raw.technology[name]
    for _, ingredient in pairs(tech and tech.unit and tech.unit.ingredients or {}) do
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
  local rest = {}
  for pack in pairs(wanted) do rest[#rest + 1] = pack end
  table.sort(rest)
  for _, pack in pairs(rest) do
    if data.raw.tool[pack] then packs[#packs + 1] = {pack, 1} end
  end
  return packs
end

--- Icon: a file name in graphics/technology, {file, tint} for a recoloured icon, or an icons table.
local function tech_icons(icon)
  if type(icon) == "table" and icon[1] and type(icon[1]) == "table" then return icon end
  return {{
    icon = TECH .. (type(icon) == "table" and icon[1] or icon) .. ".png",
    icon_size = 256,
    tint = type(icon) == "table" and icon[2] or nil,
  }}
end

--- t = {name, icon, own = {own prerequisites}, external = {prerequisites of other mods}, count, time,
---      packs = {science packs besides the base ones}, recipes = {...} or effects = {...}, order, upgrade}
local function technology(t)
  local prerequisites = {}
  for _, p in pairs(t.own or {}) do prerequisites[#prerequisites + 1] = p end
  for _, p in pairs(t.external or {}) do
    if usable_tech(p) then prerequisites[#prerequisites + 1] = p end
  end
  local own_packs = {}
  for _, pack in pairs(BASE_PACKS) do own_packs[#own_packs + 1] = pack end
  for _, pack in pairs(t.packs or {}) do own_packs[#own_packs + 1] = pack end
  local effects = t.effects or {}
  for _, recipe in pairs(t.recipes or {}) do
    effects[#effects + 1] = {type = "unlock-recipe", recipe = recipe}
  end
  local tech = {
    type = "technology",
    name = t.name,
    icons = tech_icons(t.icon),
    prerequisites = prerequisites,
    unit = {count = t.count, ingredients = science(own_packs, prerequisites), time = t.time or 30},
    effects = effects,
    upgrade = t.upgrade,
    order = t.order,
  }
  prototypes[#prototypes + 1] = tech
  defined[t.name] = tech
end

local function droid(name) return {name, name .. "-deploy"} end
local function tinted(file, unit) return {file, shared.droid_by_name[unit].tint} end

local ROBOTICS = "robotarmy-tech-robotics"
local RIFLE = "robotarmy-tech-droid-rifle"
local SMG = "robotarmy-tech-droid-smg"
local ROCKET = "robotarmy-tech-droid-rocket"
local FLAME = "robotarmy-tech-droid-flame"
local LASER = "robotarmy-tech-droid-laser"
local TESLA = "robotarmy-tech-droid-tesla"
local TERMINATOR = "robotarmy-tech-droid-terminator"
local DEFENDER = "robotarmy-tech-defender-unit"
local DISTRACTOR = "robotarmy-tech-distractor-unit"
local DESTROYER = "robotarmy-tech-destroyer-unit"

local base_recipes = {B.assembler, B.station, B.counter}
if settings.startup[shared.setting.loot_chest].value then
  base_recipes[#base_recipes + 1] = B.loot
end

technology({name = ROBOTICS, icon = ROBOTICS, count = 250, recipes = base_recipes, order = "c-c-a",
  external = {"chemical-science-pack", "military-3", "automation-3", "circuit-network", "electric-engine",
    "concrete", "angels-metallurgy-2", "angels-invar-smelting-1", "bob-cobalt-processing"}})

-- Light infantry
technology({name = RIFLE, icon = RIFLE, own = {ROBOTICS}, external = {"military-3"},
  count = 200, recipes = droid("droid-rifle"), order = "c-c-b"})
technology({name = "robotarmy-tech-droid-scout", icon = tinted(RIFLE, "droid-scout"), own = {RIFLE},
  external = {"bob-radar-2", "bob-brass-processing", "angels-aluminium-smelting-1"},
  count = 250, recipes = droid("droid-scout"), order = "c-c-b-a"})
technology({name = "robotarmy-tech-droid-sniper", icon = tinted(RIFLE, "droid-sniper"), own = {RIFLE},
  external = {"Schall-sniper-rifle", "bob-brass-processing"},
  count = 300, recipes = droid("droid-sniper"), order = "c-c-b-b"})
technology({name = "robotarmy-tech-droid-miner", icon = tinted(RIFLE, "droid-miner"), own = {RIFLE},
  external = {"land-mine"},
  count = 300, recipes = droid("droid-miner"), order = "c-c-b-c"})

-- Armoured infantry
technology({name = SMG, icon = SMG, own = {RIFLE}, external = {"modular-armor", "angels-cobalt-steel-smelting-1"},
  count = 300, recipes = droid("droid-smg"), order = "c-c-c"})
technology({name = "robotarmy-tech-droid-repair", icon = tinted(SMG, "droid-repair"), own = {SMG},
  external = {"bob-repair-pack-3", "bob-brass-processing"},
  count = 350, recipes = droid("droid-repair"), order = "c-c-c-a"})
technology({name = LASER, icon = tinted(SMG, "droid-laser"), own = {SMG},
  external = {"bob-laser-rifle", "laser", "battery", "angels-aluminium-smelting-1"},
  count = 400, recipes = droid("droid-laser"), order = "c-c-c-b"})
technology({name = TESLA, icon = tinted(SMG, "droid-tesla"), own = {LASER},
  external = {"bob-battery-2", "angels-rubbers"},
  count = 450, recipes = droid("droid-tesla"), order = "c-c-c-c"})
technology({name = "robotarmy-tech-drop-pod", icon = {ROBOTICS, {r = 0.6, g = 0.75, b = 0.45}}, own = {SMG},
  count = 300, recipes = {shared.pod.item}, order = "c-c-c-d"})

-- Heavy weapons and assault
technology({name = ROCKET, icon = ROCKET, own = {SMG}, external = {"rocketry"},
  count = 400, recipes = droid("droid-rocket"), order = "c-c-d"})
technology({name = "robotarmy-tech-droid-poison", icon = tinted(ROCKET, "droid-poison"), own = {ROCKET},
  external = {"military-3"},
  count = 450, recipes = droid("droid-poison"), order = "c-c-d-a"})
technology({name = FLAME, icon = FLAME, own = {SMG},
  external = {"flamethrower", "bob-titanium-processing", "angels-titanium-smelting-1"},
  count = 400, recipes = droid("droid-flame"), order = "c-c-e"})
technology({name = "robotarmy-tech-droid-heavy", icon = tinted(TERMINATOR, "droid-heavy"), own = {FLAME},
  external = {"gun-turret", "bob-titanium-processing"},
  count = 500, recipes = droid("droid-heavy"), order = "c-c-e-a"})
technology({name = TERMINATOR, icon = TERMINATOR, own = {ROCKET, FLAME},
  external = {"military-4", "power-armor", "laser-turret", "bob-laser-turrets-2", "low-density-structure", "bob-battery-2"},
  count = 600, time = 45, recipes = droid("terminator"), order = "c-c-f"})
technology({name = "robotarmy-tech-droid-terminator-plasma", icon = tinted(TERMINATOR, "terminator-plasma"), own = {TERMINATOR},
  external = {"bob-plasma-turrets-1", "angels-nitinol-smelting-1"},
  count = 800, time = 45, recipes = droid("terminator-plasma"), order = "c-c-f-a"})

-- Flying units
technology({name = DEFENDER, icon = DEFENDER, own = {ROBOTICS}, external = {"defender"},
  count = 300, recipes = droid("defender-unit"), order = "c-c-g"})
technology({name = DISTRACTOR, icon = DISTRACTOR, own = {DEFENDER}, external = {"distractor"},
  count = 500, recipes = droid("distractor-unit"), order = "c-c-h"})
technology({name = DESTROYER, icon = DESTROYER, own = {DISTRACTOR}, external = {"destroyer"},
  count = 600, recipes = droid("destroyer-unit"), order = "c-c-i"})

-- Bob's drones join the army: deploy recipes; drones placed by hand join squads after this research.
do
  local recipes, external = {}, {}
  local BOB_TECH = {
    ["bob-robot-gun-drone"] = "bob-robot-gun-drones",
    ["bob-robot-laser-drone"] = "bob-robot-laser-drones",
    ["bob-robot-flamethrower-drone"] = "bob-robot-flamethrower-drones",
  }
  for _, d in pairs(shared.droids) do
    if d.external and data.raw.recipe[d.deploy] then
      recipes[#recipes + 1] = d.deploy
      external[#external + 1] = BOB_TECH[d.unit]
    end
  end
  if #recipes > 0 then
    technology({name = "robotarmy-tech-bob-drones", icon = {DEFENDER, {r = 0.9, g = 0.8, b = 0.6}}, own = {ROBOTICS},
      external = external, count = 300, recipes = recipes, order = "c-c-j"})
  end
end

-- Droid weapon research. Damage works for bullets, rockets and energy projectiles; the fire
-- of flamebots and the beams / chain lightning are not changed by a damage bonus (measured),
-- so their branches only research the rate of fire.
local BRANCHES = {
  {key = "bullet", category = A.bullet, icon = RIFLE, after = RIFLE, damage = {5, 0.2}, speed = {4, 0.1}},
  {key = "rocket", category = A.rocket, icon = ROCKET, after = ROCKET, damage = {4, 0.2}, speed = {3, 0.15}},
  {key = "energy", category = A.energy, icon = TERMINATOR, after = LASER, damage = {4, 0.2}, speed = {3, 0.15}},
  {key = "flame", category = A.flame, icon = FLAME, after = FLAME, speed = {3, 0.15}},
  {key = "electric", category = A.electric, icon = DESTROYER, after = TESLA, speed = {3, 0.15}},
}
local UTILITY_FROM = 4

local function branch(b, kind, spec, effect_type, icon_function)
  local levels, step = spec[1], spec[2]
  local icons = icon_function(TECH .. b.icon .. ".png")
  for level = 1, levels do
    local name = string.format("robotarmy-droid-%s-%s-%d", b.key, kind, level)
    technology({
      name = name,
      icon = util.table.deepcopy(icons),
      own = {level == 1 and b.after or string.format("robotarmy-droid-%s-%s-%d", b.key, kind, level - 1)},
      external = level >= UTILITY_FROM and {"utility-science-pack"} or nil,
      packs = level >= UTILITY_FROM and {"utility-science-pack"} or nil,
      count = 200 + 150 * (level - 1),
      effects = {{type = effect_type, ammo_category = b.category, modifier = step}},
      upgrade = level > 1,
      order = string.format("c-c-z-%s-%s-%02d", b.key, kind, level),
    })
  end
end

for _, b in pairs(BRANCHES) do
  if b.damage then branch(b, "damage", b.damage, "ammo-damage", util.technology_icon_constant_damage) end
  if b.speed then branch(b, "speed", b.speed, "gun-speed", util.technology_icon_constant_speed) end
end

data:extend(prototypes)

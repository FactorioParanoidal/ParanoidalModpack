-- Names and constants shared by the settings, data and control stages. Pure data: no game API.
local S = {}

S.mod = "robotarmy-citadel"
S.path = "__robotarmy-citadel__"
S.force = "replicators"
S.prefix = "replicator-"

---------------------------------------------------------------------------------------------------
-- Droids of the citadel: copies of the Robot Army Reforged droids ("replicator-<droid>"), recoloured,
-- not minable, with loot. Armour marks 1..S.marks are separate prototypes per resistance focus
-- ("replicator-<droid>-mk<mark>-<focus>"); the armoury modules raise the mark, the focus follows the
-- damage that kills the droids (adaptive armour). Damage and rate of fire are force bonuses.
---------------------------------------------------------------------------------------------------
S.kinds = {
  "droid-rifle", "droid-scout", "droid-smg", "droid-sniper", "droid-laser", "droid-tesla",
  "droid-rocket", "droid-poison", "droid-flame", "droid-heavy", "terminator", "terminator-plasma",
  "defender-unit", "distractor-unit", "destroyer-unit",
}

--- Loot class of every kind (prototypes/loot.lua).
S.loot_class = {
  ["droid-rifle"] = "light", ["droid-scout"] = "light", ["droid-sniper"] = "light",
  ["droid-smg"] = "assault", ["droid-heavy"] = "assault", ["droid-flame"] = "assault",
  ["droid-rocket"] = "assault", ["droid-poison"] = "assault",
  ["droid-laser"] = "energy", ["droid-tesla"] = "energy",
  ["terminator"] = "heavy", ["terminator-plasma"] = "heavy",
  ["defender-unit"] = "air", ["distractor-unit"] = "air", ["destroyer-unit"] = "air",
}

S.marks = 3
S.focuses = {"balanced", "kinetic", "energy", "chemical"}
--- Damage types of every focus (the killing blows are counted per group).
S.focus_types = {
  kinetic = {"physical", "explosion"},
  energy = {"laser", "electric", "fire"},
  chemical = {"acid", "poison"},
}
--- Damage type -> focus group (others count for none).
S.focus_of_damage = {}
for focus, types in pairs(S.focus_types) do
  for _, t in pairs(types) do S.focus_of_damage[t] = focus end
end
S.focus_of_damage["bob-plasma"] = "energy"
S.focus_of_damage["bob-pierce"] = "kinetic"

--- Health share and resistance (percent points) added by an armour mark; the focus group gets
--- `focus_resist` more per mark.
S.mark_health = 0.2
S.mark_resist = 6
S.focus_resist = 8

function S.unit_name(kind, mark, focus)
  if not mark or mark <= 0 then return S.prefix .. kind end
  return S.prefix .. kind .. "-mk" .. mark .. "-" .. (focus or "balanced")
end

--- Every replicator unit name (the base droid and all marks).
function S.all_unit_names()
  local list = {}
  for _, kind in pairs(S.kinds) do
    list[#list + 1] = S.unit_name(kind, 0)
    for mark = 1, S.marks do
      for _, focus in pairs(S.focuses) do list[#list + 1] = S.unit_name(kind, mark, focus) end
    end
  end
  return list
end

---------------------------------------------------------------------------------------------------
-- Buildings. size = tiles {w, h}; key = the building a module stands on (its loss ruins the module).
---------------------------------------------------------------------------------------------------
local P = S.prefix
S.entity = {
  core = P .. "core",
  wall = P .. "wall",
  gate = P .. "gate",
  pylon = P .. "pylon",
  lamp = P .. "lamp",
  crate = P .. "crate",
  assembler = P .. "assembler",
  turbine = P .. "turbine",
  reactor = P .. "reactor",
  accumulator = P .. "accumulator",
  radar = P .. "radar",
  depot = P .. "depot",
  repair_bay = P .. "repair-bay",
  recycler = P .. "recycler",
  armory = P .. "armory",
  arsenal = P .. "arsenal",
  targeting = P .. "targeting-array",
  ai_core = P .. "ai-core",
  jammer = P .. "jammer",
  relay = P .. "relay",
  shield_node = P .. "shield-node",
  mine_control = P .. "mine-control",
  gun_tower = P .. "gun-tower",
  laser_tower = P .. "laser-tower",
  mortar_tower = P .. "mortar-tower",
  tesla_tower = P .. "tesla-tower",
  land_mine = "land-mine",
  shield_tower = "repair-turret", -- the defence tower of Defence Tower Reforged
}

--- Droid foundries: one per production module type.
S.foundries = {"light", "assault", "fire", "sniper", "energy", "air", "terminator"}
for _, f in pairs(S.foundries) do S.entity["foundry_" .. f] = P .. "foundry-" .. f end

S.size = {
  [S.entity.core] = {7, 7},
  [S.entity.wall] = {1, 1},
  [S.entity.gate] = {1, 1},
  [S.entity.pylon] = {2, 2},
  [S.entity.lamp] = {1, 1},
  [S.entity.crate] = {1, 1},
  [S.entity.assembler] = {3, 3},
  [S.entity.turbine] = {5, 3},
  [S.entity.reactor] = {4, 4},
  [S.entity.accumulator] = {2, 2},
  [S.entity.radar] = {3, 3},
  [S.entity.depot] = {5, 5},
  [S.entity.repair_bay] = {3, 3},
  [S.entity.recycler] = {3, 3},
  [S.entity.armory] = {4, 4},
  [S.entity.arsenal] = {3, 3},
  [S.entity.targeting] = {3, 3},
  [S.entity.ai_core] = {5, 5},
  [S.entity.jammer] = {4, 4},
  [S.entity.relay] = {2, 2},
  [S.entity.shield_node] = {2, 2},
  [S.entity.mine_control] = {2, 2},
  [S.entity.gun_tower] = {2, 2},
  [S.entity.laser_tower] = {2, 2},
  [S.entity.mortar_tower] = {2, 2},
  [S.entity.tesla_tower] = {2, 2},
  [S.entity.land_mine] = {1, 1},
  [S.entity.shield_tower] = {2, 2},
}
for _, f in pairs(S.foundries) do S.size[S.entity["foundry_" .. f]] = {5, 5} end

S.turrets = {S.entity.gun_tower, S.entity.laser_tower, S.entity.mortar_tower, S.entity.tesla_tower}

--- Floor tiles of the citadel (not minable).
S.tile_floor = P .. "plating"
S.tile_road = P .. "road"

--- Item dropped by the key buildings, and the recipe that takes it apart.
S.core_item = P .. "core-item"
S.decrypt_recipe = P .. "core-decryption"

--- Ammo categories of Robot Army Reforged: the citadel force gets its damage / rate bonuses on them.
S.ammo_categories = {"droid-bullet", "droid-rocket", "droid-energy", "droid-flame", "droid-electric"}
--- Categories whose damage bonus works (measured by Robot Army Reforged: not flame and electric).
S.damage_categories = {"droid-bullet", "droid-rocket", "droid-energy"}

---------------------------------------------------------------------------------------------------
-- Map settings.
---------------------------------------------------------------------------------------------------
S.setting = {
  enabled = "robotarmy-citadel-enabled",
  evolution = "robotarmy-citadel-evolution",
  warning = "robotarmy-citadel-warning",
  base_radius = "robotarmy-citadel-base-radius",
  distance = "robotarmy-citadel-distance",
  growth = "robotarmy-citadel-growth-minutes",
  stun = "robotarmy-citadel-stun-minutes",
  accel_modules = "robotarmy-citadel-acceleration-modules",
  accel_percent = "robotarmy-citadel-acceleration-percent",
  shield_modules = "robotarmy-citadel-shield-modules",
  unit_limit = "robotarmy-citadel-unit-limit",
  attack_groups = "robotarmy-citadel-attack-groups",
  squad_base = "robotarmy-citadel-squad-base",
  squad_max = "robotarmy-citadel-squad-max",
  clear_radius = "robotarmy-citadel-clear-radius",
  messages = "robotarmy-citadel-messages",
}

return S

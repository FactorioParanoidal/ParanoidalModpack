-- Names shared by the settings, data and control stages.
-- Pure data: no game API access here.

local shared = {}

shared.mod_name = "robotarmy-reforged"
shared.mod_path = "__robotarmy-reforged__"

--- Ammo categories of the droid weapons: they have their own research branches (the force
--- bonuses of the vanilla categories do not apply to droids). Measured on a test stand: a force
--- ammo damage modifier changes bullet, rocket and laser projectile attacks of units, but not
--- flamethrower fire or beams; a gun speed modifier changes all of them. So the flame and
--- electric branches only research the rate of fire.
shared.ammo = {
  bullet   = "droid-bullet",
  rocket   = "droid-rocket",
  energy   = "droid-energy",
  flame    = "droid-flame",
  electric = "droid-electric",
}

--- Every droid kind, in display order.
---   unit      entity name (also the item name)
---   icon      item icon file in graphics/icons; `tint` recolours a droid that reuses the model
---             and icon of another one
---   yuoki     model of Yuoki Industries (used when that mod is active): "cb4" or "robo1"
---   external  the unit and its item belong to another mod (Bob's drones): the mod only adds a
---             deploy recipe, ranks and squad AI (after its technology)
---   role      special ability handled by the control script: "repair", "miner"
---   growth    per rank: health / damage / speed share, range in tiles, cooldown share
---             (reduction), regen in health per second, resist in percent points, repair share
shared.droids = {
  {unit = "droid-rifle", icon = "droid_rifle_undep.png",
   growth = {health = 0.1, damage = 0.15, range = 1}},
  {unit = "droid-scout", icon = "droid_rifle_undep.png", tint = {r = 1.0, g = 0.85, b = 0.25},
   growth = {health = 0.15, speed = 0.06, damage = 0.1}},
  {unit = "droid-sniper", icon = "droid_rifle_undep.png", tint = {r = 0.55, g = 0.75, b = 0.35}, yuoki = "cb4",
   growth = {damage = 0.15, range = 0.5, cooldown = 0.05}},
  {unit = "droid-miner", icon = "droid_rifle_undep.png", tint = {r = 0.75, g = 0.5, b = 0.3}, role = "miner",
   growth = {health = 0.15, damage = 0.1, speed = 0.04}},
  {unit = "droid-smg", icon = "droid_smg_undep.png",
   growth = {health = 0.15, damage = 0.1, cooldown = 0.05}},
  {unit = "droid-repair", icon = "droid_smg_undep.png", tint = {r = 0.45, g = 0.8, b = 1.0}, role = "repair",
   growth = {health = 0.15, regen = 0.3, repair = 0.2}},
  {unit = "droid-laser", icon = "droid_smg_undep.png", tint = {r = 0.35, g = 0.5, b = 1.0}, yuoki = "robo1",
   growth = {health = 0.1, damage = 0.12, range = 1}},
  {unit = "droid-tesla", icon = "droid_smg_undep.png", tint = {r = 0.4, g = 1.0, b = 1.0},
   growth = {health = 0.12, damage = 0.12, cooldown = 0.05}},
  {unit = "droid-rocket", icon = "droid_rocket_undep.png",
   growth = {health = 0.1, damage = 0.15, range = 1}},
  {unit = "droid-poison", icon = "droid_rocket_undep.png", tint = {r = 0.55, g = 1.0, b = 0.3},
   growth = {health = 0.1, range = 1, cooldown = 0.1}},
  {unit = "droid-flame", icon = "droid_flame_undep.png",
   growth = {health = 0.15, range = 0.5, resist = 3}},
  {unit = "droid-heavy", icon = "terminator_undep.png", tint = {r = 1.0, g = 0.55, b = 0.2},
   growth = {health = 0.15, damage = 0.1, resist = 2}},
  {unit = "terminator", icon = "terminator_undep.png",
   growth = {health = 0.1, damage = 0.1, speed = 0.04}},
  {unit = "terminator-plasma", icon = "terminator_undep.png", tint = {r = 0.8, g = 0.4, b = 1.0},
   growth = {health = 0.1, damage = 0.1, regen = 0.3}},
  {unit = "defender-unit", icon = "defender_unit_undep.png",
   growth = {health = 0.15, damage = 0.1}},
  {unit = "distractor-unit", icon = "distractor_unit_undep.png",
   growth = {health = 0.15, damage = 0.1}},
  {unit = "destroyer-unit", icon = "destroyer_unit_undep.png",
   growth = {health = 0.1, damage = 0.12}},
  {unit = "bob-robot-gun-drone", external = true, growth = {health = 0.1, damage = 0.1}},
  {unit = "bob-robot-laser-drone", external = true, growth = {health = 0.1, damage = 0.1}},
  {unit = "bob-robot-flamethrower-drone", external = true, growth = {health = 0.1, range = 1}},
}

shared.deploy_to_unit = {}   -- deploy recipe name -> droid entity name
shared.droid_by_name = {}    -- droid kind name -> entry of shared.droids
for _, d in pairs(shared.droids) do
  d.deploy = d.unit .. "-deploy"
  shared.deploy_to_unit[d.deploy] = d.unit
  shared.droid_by_name[d.unit] = d
end

--- Ranks: ten ranks with the names and insignia of HeroTurrets (names as set by Paranoidal for
--- turrets). Kills for each rank: the default HeroTurrets reference values (50 ... 5000 for turrets)
--- x 0.2, spread linearly. A promoted droid is replaced by the rank prototype "<droid>-rank-<n>"
--- (more health, damage, range ... by its growth, which adds up with every rank).
shared.rank_kills = {10, 120, 230, 340, 450, 560, 670, 780, 890, 1000}

--- Kill thresholds per droid kind: droids that hit many enemies at once or have a high rate of
--- fire need more kills, support droids that rarely kill need fewer (default 1).
shared.kill_factor = {
  ["droid-rocket"] = 1.5, ["droid-tesla"] = 1.5, ["terminator-plasma"] = 1.5, ["droid-flame"] = 1.5,
  ["bob-robot-flamethrower-drone"] = 1.5,
  ["droid-heavy"] = 1.25, ["terminator"] = 1.25, ["destroyer-unit"] = 1.25, ["defender-unit"] = 1.25,
  ["bob-robot-gun-drone"] = 1.25, ["bob-robot-laser-drone"] = 1.25,
  ["droid-repair"] = 0.5, ["droid-scout"] = 0.5, ["droid-miner"] = 0.5, ["droid-poison"] = 0.5,
}

--- Kills a droid of `kind` needs for `rank` (nil above the last rank).
function shared.rank_threshold(kind, rank)
  local base = shared.rank_kills[rank]
  if not base then return nil end
  return math.max(1, math.floor(base * (shared.kill_factor[kind] or 1) + 0.5))
end

--- Insignia of HeroTurrets (used from that mod when it is active): sprite per rank.
shared.rank_sprite_prefix = "robotarmy-rank-"

function shared.rank_name(unit, rank)
  if rank <= 0 then return unit end
  return unit .. "-rank-" .. rank
end

--- Repair droid: health a repair droid restores to its squad per second (x health setting).
shared.repair_hp = 15
--- Miner: land mines it carries after being deployed (the deploy recipe consumes them).
shared.miner_mine = "land-mine"
shared.miner_mines = 10

--- Icon layers of a droid item / deploy recipe (tinted for the new droid kinds). Data stage only.
function shared.droid_icons(unit)
  local d = shared.droid_by_name[unit]
  if d.yuoki == "cb4" and mods and mods["Yuoki"] then
    return {{icon = "__Yuoki__/graphics/armor/cb4_icon.png", icon_size = 64}}
  end
  return {{icon = shared.mod_path .. "/graphics/icons/" .. d.icon, icon_size = 64, tint = d.tint}}
end

shared.alive_signal = "signal-droid-alive-count"

--- Virtual signals of the droid counter besides the droid item signals: name, base icon
--- overlay (__base__/graphics/icons/signal/<overlay>.png).
shared.signals = {
  {name = shared.alive_signal},
  {name = "signal-droid-squads-hunting", overlay = "signal-weapon"},
  {name = "signal-droid-squads-fighting", overlay = "signal-explosion"},
  {name = "signal-droid-squads-gathering", overlay = "signal-map-marker"},
  {name = "signal-droid-squads-recalled", overlay = "signal-white-flag"},
  {name = "signal-droid-squads-patrolling", overlay = "signal-recycle"},
  {name = "signal-droid-pending", overlay = "signal-hourglass"},
  {name = "signal-droid-alarm", overlay = "signal-alarm"},
}

shared.buildings = {
  assembler = "droid-assembling-machine",
  station   = "droid-guard-station",
  counter   = "droid-counter",
  loot      = "loot-chest",
}

--- Drop pod: an item that carries a squad (up to `capacity` droids with their rank, kills,
--- quality and health); placed on the ground it opens after `open_ticks` and lands the squad.
shared.pod = {
  item = "robotarmy-drop-pod",
  entity = "robotarmy-drop-pod",
  tag = "robotarmy-squad",
  capacity = 32,
  load_range = 30,
  open_ticks = 180,
}

--- Rally point of a droid assembler: at most this many tiles from it.
shared.rally_range = 50

--- The squad command tool: select = pick a squad, alt-select = send it,
--- reverse-select = pick up droids, alt-reverse-select = merge squads.
shared.tool = "droid-selection-tool"
shared.army_shortcut = "robotarmy-army"

shared.selection_sprite = "robotarmy-unit-selection"

--- Mod setting names.
shared.setting = {
  qrf_distance    = "robotarmy-qrf-distance",
  qrf_vehicles    = "robotarmy-qrf-vehicles",
  qrf_walls       = "robotarmy-qrf-walls",
  qrf_alerts      = "robotarmy-qrf-alerts",
  targeting       = "robotarmy-targeting-mode",
  squad_messages  = "robotarmy-squad-messages",
  teleport        = "robotarmy-teleport-stuck",
  debug           = "robotarmy-debug",
  repair_at_base  = "robotarmy-repair-at-base",
  loot_chest      = "robotarmy-loot-chest",
  acid_splash     = "robotarmy-disable-acid-splash-damage",
  health_scale    = "robotarmy-health-scale",
  damage_scale    = "robotarmy-damage-scale",
}

shared.targeting_modes = {"nearest", "defend-assembler", "keep-radius-clear"}

--- Squad thresholds set in the army window: default, minimum, maximum, slider step.
shared.thresholds = {
  hunt_size    = {default = 10,   min = 1, max = 100,   step = 1},
  retreat_size = {default = 2,    min = 1, max = 99,    step = 1},
  hunt_range   = {default = 5000, min = 0, max = 10000, step = 100},
}
shared.threshold_order = {"hunt_size", "retreat_size", "hunt_range"}

--- Garrison size of a guard station (set in the station window).
shared.garrison = {default = 10, min = 1, max = 50}

return shared

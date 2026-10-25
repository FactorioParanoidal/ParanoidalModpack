-- Names shared by the settings, data and control stages.
-- Pure data: no game API access here.

local shared = {}

shared.mod_name = "robotarmy-reforged"
shared.mod_path = "__robotarmy-reforged__"

--- Every droid the mod can deploy, in display order. `signal` is the droid counter signal
--- (flying units are only included in the "alive" total). `deploy` is the deploy recipe:
--- it consumes the droid item in a droid assembler / guard station, has no product, and the
--- control script turns every finished craft into a unit.
shared.droids = {
  {unit = "droid-rifle",     signal = "signal-droid-rifle-count"},
  {unit = "droid-smg",       signal = "signal-droid-smg-count"},
  {unit = "droid-rocket",    signal = "signal-droid-rocket-count"},
  {unit = "droid-flame",     signal = "signal-droid-flame-count"},
  {unit = "terminator",      signal = "signal-droid-terminator-count"},
  {unit = "defender-unit"},
  {unit = "distractor-unit"},
  {unit = "destroyer-unit"},
}

shared.unit_names = {}       -- array of droid entity names
shared.is_droid = {}         -- set: entity name -> true
shared.deploy_to_unit = {}   -- deploy recipe name -> droid entity name
for _, d in pairs(shared.droids) do
  d.deploy = d.unit .. "-deploy"
  shared.unit_names[#shared.unit_names + 1] = d.unit
  shared.is_droid[d.unit] = true
  shared.deploy_to_unit[d.deploy] = d.unit
end

--- Droid item icon file (graphics/icons), by droid name: items, deploy recipes.
shared.droid_icons = {
  ["droid-rifle"]     = "droid_rifle_undep.png",
  ["droid-smg"]       = "droid_smg_undep.png",
  ["droid-rocket"]    = "droid_rocket_undep.png",
  ["droid-flame"]     = "droid_flame_undep.png",
  ["terminator"]      = "terminator_undep.png",
  ["defender-unit"]   = "defender_unit_undep.png",
  ["distractor-unit"] = "distractor_unit_undep.png",
  ["destroyer-unit"]  = "destroyer_unit_undep.png",
}

shared.alive_signal = "signal-droid-alive-count"

shared.buildings = {
  assembler = "droid-assembling-machine",
  station   = "droid-guard-station",
  counter   = "droid-counter",
  loot      = "loot-chest",
}

--- The squad command tool: select = pick a squad, alt-select = send it,
--- reverse-select = pick up droids.
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

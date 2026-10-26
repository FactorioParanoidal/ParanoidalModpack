local S = require("lib.shared").setting

local function bool(name, default, order)
  return {type = "bool-setting", name = name, setting_type = "runtime-global", default_value = default, order = order}
end
local function int(name, default, min, max, order)
  return {type = "int-setting", name = name, setting_type = "runtime-global",
    default_value = default, minimum_value = min, maximum_value = max, order = order}
end
local function double(name, default, min, max, order)
  return {type = "double-setting", name = name, setting_type = "runtime-global",
    default_value = default, minimum_value = min, maximum_value = max, order = order}
end

data:extend({
  bool(S.enabled, true, "a-a"),
  double(S.warning, 0.45, 0, 1, "a-b"),
  double(S.evolution, 0.5, 0, 1, "a-c"),
  int(S.base_radius, 10, 0, 500, "b-a"),
  int(S.distance, 50, 3, 500, "b-b"),
  double(S.growth, 10, 0.5, 600, "c-a"),
  double(S.stun, 60, 1, 6000, "c-b"),
  int(S.accel_modules, 100, 1, 10000, "c-c"),
  double(S.accel_percent, 10, 0, 1000, "c-d"),
  int(S.shield_modules, 25, 1, 10000, "c-e"),
  int(S.unit_limit, 400, 10, 5000, "d-a"),
  int(S.attack_groups, 6, 1, 50, "d-b"),
  int(S.squad_base, 8, 1, 200, "d-c"),
  int(S.squad_max, 40, 1, 200, "d-d"),
  int(S.clear_radius, 5, 0, 50, "e-a"),
  bool(S.messages, true, "e-b"),
})

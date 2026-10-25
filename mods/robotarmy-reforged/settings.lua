local shared = require("lib.shared")
local S = shared.setting

data:extend({
  -- startup
  {
    type = "bool-setting", name = S.loot_chest, setting_type = "startup",
    default_value = false, order = "a[startup]-a",
  },
  {
    type = "bool-setting", name = S.acid_splash, setting_type = "startup",
    default_value = false, order = "a[startup]-b",
  },
  {
    type = "double-setting", name = S.health_scale, setting_type = "startup",
    default_value = 1, minimum_value = 0.1, maximum_value = 10, order = "a[startup]-c",
  },
  {
    type = "double-setting", name = S.damage_scale, setting_type = "startup",
    default_value = 1, minimum_value = 0.1, maximum_value = 10, order = "a[startup]-d",
  },

  -- map
  {
    type = "int-setting", name = S.qrf_distance, setting_type = "runtime-global",
    default_value = 500, minimum_value = 0, maximum_value = 500, order = "b[qrf]-a",
  },
  {
    type = "bool-setting", name = S.qrf_vehicles, setting_type = "runtime-global",
    default_value = true, order = "b[qrf]-b",
  },
  {
    type = "bool-setting", name = S.qrf_walls, setting_type = "runtime-global",
    default_value = true, order = "b[qrf]-c",
  },
  {
    type = "bool-setting", name = S.qrf_alerts, setting_type = "runtime-global",
    default_value = true, order = "b[qrf]-d",
  },
  {
    type = "string-setting", name = S.targeting, setting_type = "runtime-global",
    default_value = "nearest", allowed_values = shared.targeting_modes, order = "c[ai]-a",
  },
  {
    type = "bool-setting", name = S.teleport, setting_type = "runtime-global",
    default_value = true, order = "c[ai]-b",
  },
  {
    type = "int-setting", name = S.repair_at_base, setting_type = "runtime-global",
    default_value = 2, minimum_value = 0, maximum_value = 20, order = "c[ai]-c",
  },
  {
    type = "bool-setting", name = S.squad_messages, setting_type = "runtime-global",
    default_value = true, order = "d[messages]-a",
  },
  {
    type = "bool-setting", name = S.debug, setting_type = "runtime-global",
    default_value = false, order = "d[messages]-b",
  },
})

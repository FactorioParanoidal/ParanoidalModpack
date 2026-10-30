local shared = require("shared")

data:extend({
  {
    type = "double-setting",
    name = shared.setting,
    setting_type = "runtime-global",
    default_value = 1,
    minimum_value = 0,
    maximum_value = 1000,
    order = "a",
  },
  {
    type = "bool-setting",
    name = shared.setting_cargo,
    setting_type = "runtime-global",
    default_value = true,
    order = "b",
  },
  {
    type = "bool-setting",
    name = shared.setting_alerts,
    setting_type = "runtime-per-user",
    default_value = true,
    order = "a",
  },
  {
    type = "bool-setting",
    name = shared.setting_panel,
    setting_type = "runtime-per-user",
    default_value = true,
    order = "b",
  },
})

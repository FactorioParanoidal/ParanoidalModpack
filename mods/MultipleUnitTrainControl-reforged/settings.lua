local shared = require("shared")

data:extend({
  {
    type = "string-setting",
    name = shared.setting_mode,
    setting_type = "runtime-global",
    order = "a",
    default_value = "research",
    allowed_values = {"research", "always", "off"},
  },
  {
    type = "bool-setting",
    name = shared.setting_fuel,
    setting_type = "runtime-global",
    order = "b",
    default_value = true,
  },
  {
    type = "bool-setting",
    name = shared.setting_labels,
    setting_type = "runtime-per-user",
    order = "c",
    default_value = true,
  },
})

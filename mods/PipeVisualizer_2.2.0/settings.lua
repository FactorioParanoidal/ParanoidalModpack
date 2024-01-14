data:extend({
  {
    type = "double-setting",
    name = "pv-overlay-opacity",
    setting_type = "runtime-per-user",
    default_value = 0.4,
    minimum_value = 0,
    maximum_value = 1,
  },
  {
    type = "int-setting",
    name = "pv-entities-per-tick",
    setting_type = "runtime-global",
    default_value = 30,
    minimum_value = 1,
  },
})

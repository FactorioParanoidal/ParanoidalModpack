data:extend({
  {
    type = "double-setting",
    name = "train-overhaul-weight-multiplicator",
    order = "aa",
    setting_type = "startup",
    default_value = 1.0,
    minimum_value = 0.1,
    maximum_value = 100
  },
  {
    type = "double-setting",
    name = "train-overhaul-power-multiplicator",
    order = "ab",
    setting_type = "startup",
    default_value = 1.0,
    minimum_value = 0.1,
    maximum_value = 100
  },
  {
    type = "bool-setting",
    name = "train-overhaul-nuclear-loco-explosion",
    order = "ba",
    setting_type = "runtime-global",
    default_value = true
  },
})
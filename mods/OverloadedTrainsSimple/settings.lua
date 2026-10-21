data:extend({
  {
    type = "int-setting",
    name = "ots-slots-for-minimum-acceleration",
    setting_type = "runtime-global",
    default_value = 80,
    minimum_value = 1,
    maximum_value = 10000,
    order = "a",
  },
  {
    type = "int-setting",
    name = "ots-fluid-for-minimum-acceleration",
    setting_type = "runtime-global",
    default_value = 200000,
    minimum_value = 1,
    maximum_value = 1000000000,
    order = "b",
  },
  {
    type = "double-setting",
    name = "ots-minimum-acceleration",
    setting_type = "runtime-global",
    default_value = 0.1,
    minimum_value = 0.01,
    maximum_value = 1,
    order = "c",
  },
})

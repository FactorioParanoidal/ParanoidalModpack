data:extend({
  {
    type = "double-setting",
    name = "BPT-base",
    setting_type = "startup",
    default_value = 1,
    minimum_value = 0.1,
    maximum_value = 10,
    admin = true,
    order = "1",
  },
  {
    type = "double-setting",
    name = "BPT-per-tier",
    setting_type = "startup",
    default_value = 0.25,
    minimum_value = 0,
    maximum_value = 2,
    admin = true,
    order = "2",
  },
})

data:extend({
  {
    name = "number_of_units_to_check_per_update",
    setting_type = "runtime-global",
    type = "int-setting",
    default_value = 50,
    minimum_value = 1
  },
  {
    name = "update_every_x_tick",
    setting_type = "runtime-global",
    type = "int-setting",
    default_value = 10
  },
  {
    type = "string-setting",
    name = "font-picker",
    setting_type = "startup",
    default_value = "sprite",
    allowed_values = {"seven", "default", "sprite"},
    order = "d-e"
  }
})

local constants = require("constants")

data:extend({
  {
    type = "bool-setting",
    name = "statsgui-single-line",
    setting_type = "runtime-per-user",
    default_value = true,
    order = "aa",
  },
  {
    type = "bool-setting",
    name = "statsgui-adjust-for-fps-ups",
    setting_type = "runtime-per-user",
    default_value = true,
    order = "ab",
  },
  {
    type = "bool-setting",
    name = "statsgui-adjust-for-clock",
    setting_type = "runtime-per-user",
    default_value = false,
    order = "ac",
  },
})

for _, sensor_data in pairs(constants.builtin_sensors) do
  data:extend({
    {
      type = "bool-setting",
      name = "statsgui-show-sensor-" .. sensor_data.name,
      setting_type = "runtime-per-user",
      default_value = sensor_data.enabled,
      order = sensor_data.order,
    },
  })
end

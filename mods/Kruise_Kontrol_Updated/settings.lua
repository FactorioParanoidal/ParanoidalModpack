local Constants = require("constants")

local vehicle_brake_on_cancel =
{
  type = "bool-setting",
  name = Constants.settings.brake_on_cancel,
  setting_type = "runtime-per-user",
  default_value = true,
  order = "a"
}

data:extend
{
  vehicle_brake_on_cancel
}

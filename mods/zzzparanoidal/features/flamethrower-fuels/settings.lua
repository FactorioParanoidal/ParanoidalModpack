local config = require("features.flamethrower-fuels.config")
data:extend{{type = "bool-setting", name = config.setting, setting_type = "startup",
  default_value = true, order = "turret-fuels-a"}}

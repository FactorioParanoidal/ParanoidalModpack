local constants = require("lua/constants")

data:extend({
  {
    type = "bool-setting",
    name = "ruins-enemy-not-cease-fire",
    setting_type = "runtime-global",
    default_value = true,
    order = "a",
  },{
    type = "bool-setting",
    name = constants.ENABLE_DEBUG_LOG_KEY,
    setting_type = "runtime-global",
    default_value = false,
    order = "aa",
  },{
    type = "bool-setting",
    name = constants.ENABLE_DEBUG_UTILS_KEY,
    setting_type = "runtime-global",
    default_value = false,
    order = "ab",
  },{
    type = "bool-setting",
    name = constants.ENABLE_DEBUG_ON_TICK_KEY,
    setting_type = "runtime-global",
    default_value = false,
    order = "ac",
  },{
    type = "string-setting",
    name = constants.CURRENT_RUIN_SET_KEY,
    setting_type = "runtime-global",
    allowed_values = {constants.NONE},
    default_value = constants.NONE,
    order = "b",
  },{
    type = "int-setting",
    name = "ruins-min-distance-from-spawn",
    setting_type = "runtime-global",
    default_value = 200,
    minimum_value = 50,
    maximum_value = 1000000,
    order = "ba",
  },{
    type = "int-setting",
    name = constants.SPAWN_TICK_SECONDS_KEY,
    setting_type = "runtime-global",
    default_value = 10,
    minimum_value = 1,
    maximum_value = 20,
    order = "bb",
  },{
    type = "double-setting",
    name = "ruins-small-ruin-chance",
    setting_type = "runtime-global",
    default_value = 0.04,
    minimum_value = 0.0,
    maximum_value = 1.0,
    order = "c",
  },{
    type = "double-setting",
    name = "ruins-medium-ruin-chance",
    setting_type = "runtime-global",
    default_value = 0.02,
    minimum_value = 0.0,
    maximum_value = 1.0,
    order = "ca",
  },{
    type = "double-setting",
    name = "ruins-large-ruin-chance",
    setting_type = "runtime-global",
    default_value = 0.005,
    minimum_value = 0.0,
    maximum_value = 1.0,
    order = "cb",
  }
})

-- Load constants
local constants = require("lua/constants")

data:extend({
  {
    type = "bool-setting",
    name = constants.ENABLE_SPAWN_RUINS_ALL_PLANETS_KEY,
    setting_type = "startup",
    default_value = true,
    order = "a"
  }, {
    type = "bool-setting",
    name = constants.ENABLE_EXPENSIVE_SANITY_CHECKS_KEY,
    setting_type = "startup",
    default_value = true,
    order = "aa"
  }, {
    type = "bool-setting",
    name = constants.ENABLE_ENEMY_NOT_CEASE_FIRE_KEY,
    setting_type = "runtime-global",
    default_value = true,
    order = "ab"
  }, {
    type = "bool-setting",
    name = constants.ENABLE_DEBUG_LOG_KEY,
    setting_type = "runtime-global",
    default_value = false,
    order = "b"
  }, {
    type = "bool-setting",
    name = constants.ENABLE_DEBUG_UTILS_KEY,
    setting_type = "runtime-global",
    default_value = false,
    order = "ba"
  }, {
    type = "bool-setting",
    name = constants.ENABLE_DEBUG_ON_TICK_KEY,
    setting_type = "runtime-global",
    default_value = false,
    order = "bb"
  }, {
    type = "string-setting",
    name = constants.CURRENT_RUIN_SET_KEY,
    setting_type = "runtime-global",
    allowed_values = {constants.NONE},
    default_value = constants.NONE,
    order = "c",
  }, {
    type = "int-setting",
    name = constants.MIN_DISTANCE_FROM_SPAWN_KEY,
    setting_type = "runtime-global",
    default_value = 200,
    minimum_value = 50,
    maximum_value = 1000000,
    order = "ca"
  }, {
    type = "int-setting",
    name = constants.SPAWN_TICK_SECONDS_KEY,
    setting_type = "runtime-global",
    default_value = 10,
    minimum_value = 1,
    maximum_value = 20,
    order = "cb"
  }, {
    type = "double-setting",
    name = "ruins-small-ruin-chance",
    setting_type = "runtime-global",
    default_value = 0.04,
    minimum_value = 0.0,
    maximum_value = 1.0,
    order = "d"
  }, {
    type = "double-setting",
    name = "ruins-medium-ruin-chance",
    setting_type = "runtime-global",
    default_value = 0.02,
    minimum_value = 0.0,
    maximum_value = 1.0,
    order = "da"
  }, {
    type = "double-setting",
    name = "ruins-large-ruin-chance",
    setting_type = "runtime-global",
    default_value = 0.005,
    minimum_value = 0.0,
    maximum_value = 1.0,
    order = "db"
  }
})

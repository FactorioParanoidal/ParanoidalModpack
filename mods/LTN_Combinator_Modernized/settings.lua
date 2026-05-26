local math = require("__flib__.math")

data:extend({
  -- STARTUP SETTINGS
  {
    type = "int-setting",
    name = "ltnc-misc-signal-rows",
    order = "sa",
    setting_type = "startup",
    default_value = 2,
    allowed_values = {1,2,3,4,5,6,7,8,9,10}
  },
  {
    type = "int-setting",
    name = "ltnc-high-threshold",
    order = "sb",
    setting_type = "startup",
    default_value = math.max_int,
    minimum_value = 0,
    maximum_value = math.max_int
  },
  -- MAP SETTINGS
  {
    type = "bool-setting",
    name = "ltnc-emit-explicit-default",
    order = "ma",
    setting_type = "runtime-global",
    default_value = false
  },
  {
    type = "bool-setting",
    name = "ltnc-emit-default-network-id",
    order = "mb",
    setting_type = "runtime-global",
    default_value = false
  },
  {
    type = "string-setting",
    name = "ltnc-disable-built-combinators",
    order = "mc",
    setting_type = "runtime-global",
    default_value = "requester",
    allowed_values = {"none", "requester", "provider", "all", "off"}
  },
  {
    type = "bool-setting",
    name = "ltnc-alert-build-disable",
    order = "md",
    setting_type = "runtime-global",
    default_value = true
  },
  -- USER SETTINGS
  {
    type = "bool-setting",
    name = "ltnc-negative-signals",
    setting_type = "runtime-per-user",
    order = "ua",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "ltnc-use-stacks",
    setting_type = "runtime-per-user",
    order = "ub",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "ltnc-show-net-panel",
    setting_type = "runtime-per-user",
    order = "uc",
    default_value = false
  },
})

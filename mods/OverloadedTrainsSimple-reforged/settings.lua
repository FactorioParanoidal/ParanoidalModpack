-- Weights are in the units of rolling stock prototype weight (base cargo wagon 1000, locomotive 2000).
-- Defaults make a full base cargo wagon (20 slots) and a full base fluid wagon (25 000 units) four
-- times as heavy as when empty, close to the gross/tare ratio of real freight and tank wagons.
data:extend({
  {
    type = "double-setting",
    name = "otsr-slot-weight",
    setting_type = "runtime-global",
    default_value = 150,
    minimum_value = 0,
    maximum_value = 100000,
    order = "a",
  },
  {
    type = "double-setting",
    name = "otsr-fluid-weight",
    setting_type = "runtime-global",
    default_value = 0.12,
    minimum_value = 0,
    maximum_value = 1000,
    order = "b",
  },
  {
    type = "double-setting",
    name = "otsr-minimum-acceleration",
    setting_type = "runtime-global",
    default_value = 0.1,
    minimum_value = 0.01,
    maximum_value = 1,
    order = "c",
  },
  {
    -- Share of a train's own current top speed allowed on curved rails; 1 disables curve limits.
    type = "double-setting",
    name = "otsr-curve-speed",
    setting_type = "runtime-global",
    default_value = 0.5,
    minimum_value = 0.1,
    maximum_value = 1,
    order = "d",
  },
  {
    type = "bool-setting",
    name = "otsr-overload-alert",
    setting_type = "runtime-per-user",
    default_value = true,
    order = "e",
  },
})

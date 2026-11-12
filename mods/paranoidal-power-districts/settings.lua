data:extend({
  { type = "double-setting", name = "ppd-bonus-multiplier", setting_type = "startup",
    default_value = 1, minimum_value = 0, maximum_value = 3, order = "a" },
  { type = "int-setting", name = "ppd-zone-half-width", setting_type = "startup",
    default_value = 10, minimum_value = 5, maximum_value = 30, order = "b" },

  { type = "int-setting", name = "ppd-update-period", setting_type = "runtime-global",
    default_value = 60, minimum_value = 10, maximum_value = 300, order = "a" },
  { type = "string-setting", name = "ppd-default-messages", setting_type = "runtime-global",
    default_value = "alarms", allowed_values = { "all", "alarms", "none" }, order = "b" },
  { type = "int-setting", name = "ppd-shed-threshold", setting_type = "runtime-global",
    default_value = 95, minimum_value = 50, maximum_value = 99, order = "c" },

  -- 0.2.1: the alt-mode labels are gone (the status lamp shows the state); the setting stays hidden so saved
  -- values and the name are kept
  { type = "bool-setting", name = "ppd-alt-labels", setting_type = "runtime-per-user",
    default_value = true, order = "a", hidden = true },
  { type = "bool-setting", name = "ppd-zone-sound", setting_type = "runtime-per-user",
    default_value = false, order = "b" },
})

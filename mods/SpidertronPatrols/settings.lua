data:extend({
  {
    type = "bool-setting",
    name = "sp-enable-dock",
    setting_type = "startup",
    default_value = true,
    order = "ab"
  },
  {
    type = "bool-setting",
    name = "sp-enable-spiderling",
    setting_type = "startup",
    default_value = true,
    order = "ac"
  },
  {
    type = "string-setting",
    name = "sp-spiderling-requires-fuel",
    setting_type = "startup",
    default_value = "No",
    allowed_values = {"Yes", "No"},
    order = "ad",
  },
  {
    type = "bool-setting",
    name = "sp-remove-military-requirement",
    setting_type = "startup",
    default_value = false,
    order = "c"
  },
  {
    type = "bool-setting",
    name = "sp-show-waypoint-numbers-in-alt-mode",
    setting_type = "runtime-per-user",
    default_value = true,
    order = "a"
  },
  {
    type = "bool-setting",
    name = "sp-prevent-docking-when-driving",
    setting_type = "runtime-per-user",
    default_value = false,
    order = "b"
  },
  {
    type = "bool-setting",
    name = "sp-show-schedule-pane-by-default",
    setting_type = "runtime-per-user",
    default_value = true,
    order = "c"
  },
})

if mods["nullius"] then
  data.raw["bool-setting"]["sp-remove-military-requirement"].hidden = true
  data.raw["bool-setting"]["sp-remove-military-requirement"].forced_value = false
  data.raw["bool-setting"]["sp-remove-military-requirement"].default_value = false
end

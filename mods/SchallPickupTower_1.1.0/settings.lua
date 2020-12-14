data:extend{
  -- Pickup Tower
  {
    type = "int-setting",
    name = "pickuptower-tier-max",
    order = "pt-t",
    setting_type = "startup",
    allowed_values = { 1, 2, 3, 4 },
    default_value = 2
  },
  {
    type = "bool-setting",
    name = "pickuptower-range-force-disable",
    order = "pt-b-a",
    setting_type = "runtime-global",
    default_value = false
  },
  {
    type = "bool-setting",
    name = "pickuptower-range-show",
    order = "pt-b-b",
    setting_type = "runtime-per-user",
    default_value = true
  },
  {
    type = "string-setting",
    name = "pickuptower-range-color",
    order = "pt-b-c",
    setting_type = "startup",
    allowed_values = { "red", "yellow", "green", "cyan", "blue", "magenta", "white" },
    default_value = "red"
  },
}

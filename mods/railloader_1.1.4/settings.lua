data:extend{
  {
    type = "string-setting",
    name = "railloader-allowed-items",
    default_value = "any",
    allowed_values = { "ore", "ore, plates", "any" },
    setting_type = "runtime-global",
  },
  {
    type = "bool-setting",
    name = "railloader-show-configuration-messages",
    default_value = false,
    setting_type = "runtime-global",
  },
  {
    type = "int-setting",
    name = "railloader-capacity",
    default_value = 320,
    minimum_value = 1,
    setting_type = "startup",
  },
}
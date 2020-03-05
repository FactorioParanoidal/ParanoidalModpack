data:extend{
  {
    type = "string-setting",
    name = "railloader-allowed-items",
    default_value = "ore",
    allowed_values = { "ore", "ore, plates", "any" },
    setting_type = "runtime-global",
  },
  {
    type = "bool-setting",
    name = "railloader-show-configuration-messages",
    default_value = true,
    setting_type = "runtime-global",
  },
}
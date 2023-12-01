data:extend{
  {
    type = "bool-setting",
    name = "nixie-tube-slashed-zero",
    setting_type = "startup",
    default_value = true,
    order = "nixie-slashed-zero",
  },
  {
    type = "int-setting",
    name = "nixie-tube-update-speed-alpha",
    setting_type = "runtime-global",
    minimum_value = 1,
    default_value = 10,
    order = "nixie-speed-alpha",
  },
  {
    type = "int-setting",
    name = "nixie-tube-update-speed-numeric",
    setting_type = "runtime-global",
    minimum_value = 1,
    default_value = 5,
    order = "nixie-speed-numeric",
  },
}

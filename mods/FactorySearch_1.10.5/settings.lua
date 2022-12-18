data:extend{
  {
    type = "string-setting",
    name = "fs-non-blocking-search",
    setting_type = "runtime-global",
    allowed_values = {"on", "multiplayer", "off"},
    default_value = "multiplayer",
    order = "a"
  },
  {
    type = "int-setting",
    name = "fs-chunks-per-tick",
    setting_type = "runtime-global",
    default_value = 50,
    minimum_value = 0,
    maximum_value = 1000,
    order = "b"
  },
  {
    type = "double-setting",
    name = "fs-initial-zoom",
    setting_type = "runtime-per-user",
    default_value = 0.5,
    minimum_value = 0.05,
    maximum_value = 10,
    order = "a",
  },
  {
    type = "bool-setting",
    name = "fs-clear-highlights-with-gui",
    setting_type = "runtime-per-user",
    default_value = false,
    order = "ba"
  },
  {
    type = "int-setting",
    name = "fs-highlight-duration",
    setting_type = "runtime-per-user",
    default_value = 12,
    minimum_value = 0,
    maximum_value = 1000,
    order = "bb"
  },
}
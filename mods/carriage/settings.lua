-- Carriage Mod - Settings

data:extend({
  {
    type = "double-setting",
    name = "carriage-max-speed",
    setting_type = "runtime-global",
    default_value = 0.4,
    minimum_value = 0.1,
    maximum_value = 1.0,
    order = "a"
  },
  {
    type = "int-setting",
    name = "carriage-cargo-size",
    setting_type = "runtime-global",
    default_value = 40,
    minimum_value = 10,
    maximum_value = 200,
    order = "b"
  },
  {
    type = "int-setting",
    name = "carriage-station-storage-size",
    setting_type = "runtime-global",
    default_value = 200,
    minimum_value = 50,
    maximum_value = 500,
    order = "c"
  }
})


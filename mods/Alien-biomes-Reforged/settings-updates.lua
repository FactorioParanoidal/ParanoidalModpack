-- Alien-biomes-Reforged settings (upstream Alien Biomes has only settings.lua).
data:extend({
  {
    type = "string-setting",
    name = "alien-biomes-reforged-atlas",
    setting_type = "startup",
    default_value = "normal",
    allowed_values = {"normal", "economy"},
    order = "zz-a",
  },
  {
    type = "bool-setting",
    name = "alien-biomes-reforged-geology",
    setting_type = "startup",
    default_value = true,
    order = "zz-b",
  },
})

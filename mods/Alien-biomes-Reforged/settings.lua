local allowed_values = function() return {"Enabled", "Disabled"} end
data:extend{
    {
        type = "string-setting",
        name = "alien-biomes-disable-vegetation",
        setting_type = "startup",
        default_value = "Disabled",
        allowed_values = allowed_values(),
        order = "h"
    },
    {
        type = "int-setting",
        name = "tile-speed-reduction",
        setting_type = "startup",
        default_value = 100,
        minimum_value = 0,
        maximum_value = 100,
        order = "z-a"
    },

}
local biome_settings = {
  "dirt-aubergine",
  "dirt-beige",
  "dirt-black",
  "dirt-brown",
  "dirt-cream",
  "dirt-dustyrose",
  "dirt-grey",
  "dirt-purple",
  "dirt-red",
  "dirt-tan",
  "dirt-violet",
  "dirt-white",
  "frozen",
  "grass-blue",
  "grass-green",
  "grass-mauve",
  "grass-olive",
  "grass-orange",
  "grass-purple",
  "grass-red",
  "grass-turquoise",
  "grass-violet",
  "grass-yellow",
  "sand-aubergine",
  "sand-beige",
  "sand-black",
  "sand-brown",
  "sand-cream",
  "sand-dustyrose",
  "sand-grey",
  "sand-purple",
  "sand-red",
  "sand-tan",
  "sand-violet",
  "sand-white",
  "volcanic-blue",
  "volcanic-green",
  "volcanic-orange",
  "volcanic-purple",
}
for _, setting in pairs(biome_settings) do
  data:extend({{
      type = "string-setting",
      name = "alien-biomes-include-"..setting,
      setting_type = "startup",
      default_value = "Enabled",
      allowed_values = allowed_values(),
      order = "t-" .. setting
  }})
end
data:extend({{
    type = "string-setting",
    name = "alien-biomes-include-inland-shallows",
    setting_type = "startup",
    default_value = "Enabled",
    allowed_values = allowed_values(),
    order = "t-z-a-wetland"
}})
data:extend({{
    type = "string-setting",
    name = "alien-biomes-include-coastal-shallows",
    setting_type = "startup",
    default_value = "Enabled",
    allowed_values = allowed_values(),
    order = "t-z-b-shallows"
}})

data:extend({{
    type = "string-setting",
    name = "alien-biomes-include-rivers",
    setting_type = "startup",
    default_value = "Disabled",
    allowed_values = allowed_values(),
    order = "t-z-b-shallows"
}})

local mode = settings.startup.nb_black_night_darkness.value
if mode == "normal-night" then return end

local suffix = ({
  ["dark-night"] = "dark_127_night.png",
  ["very-dark-night"] = "dark_191_night.png",
  ["black-night"] = "black_night.png",
})[mode]
local lut = "__NightBrightness__/graphics/lut_" .. suffix
local night = "__NightBrightness__/graphics/" .. suffix
local constants = data.raw["utility-constants"].default

-- Preserve Beta 8 LUT resources and transition times, including map zoom.
constants.daytime_color_lookup = {
  {0, "identity"}, {0.15, "identity"}, {0.2, "identity"},
  {0.45, lut}, {0.55, lut}, {0.8, "identity"}, {0.85, "identity"},
}
constants.zoom_to_world_daytime_color_lookup = {
  {0.25, "identity"}, {0.45, night}, {0.55, night}, {0.75, "identity"},
}

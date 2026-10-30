local mode = settings.startup.nb_black_night_darkness.value

local suffix = ({
  ["dark-night"] = "dark_127_night.png",
  ["very-dark-night"] = "dark_191_night.png",
  ["black-night"] = "black_night.png",
})[mode]
local lut, night
if suffix then
  lut = "__NightBrightness__/graphics/lut_" .. suffix
  night = "__NightBrightness__/graphics/" .. suffix
else
  -- Normal night: the vanilla tables, only the timing below changes.
  lut = "__core__/graphics/color_luts/lut-night.png"
  night = "__core__/graphics/color_luts/night.png"
end
local constants = data.raw["utility-constants"].default

-- The night LUT follows the time of day only, while the seasons move dusk and dawn by up to 0.15.
-- It is placed in the shortest (summer) night: dusk 0.35, evening 0.45, morning 0.55, dawn 0.65.
-- Longer nights are darkened by surface brightness (brightness_visual_weights, see control.lua),
-- so a summer evening is no longer tinted while the sun is still up. Beta 8 used 0.2-0.45/0.55-0.8.
constants.daytime_color_lookup = {
  {0, "identity"}, {0.35, "identity"},
  {0.45, lut}, {0.55, lut}, {0.65, "identity"}, {0.85, "identity"},
}
constants.zoom_to_world_daytime_color_lookup = {
  {0.35, "identity"}, {0.45, night}, {0.55, night}, {0.65, "identity"},
}

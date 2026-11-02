-- "Weather forecast" technology (scripts/forecast.lua): after it the radar network of a force forecasts the weather.
-- No effects of its own; prerequisites are set in data-updates.lua (bob-radar-2 of bobwarfare, or radar).
data:extend({
  {
    type = "technology",
    name = "prain-weather-forecast",
    icon = "__paranoidal-rain__/graphics/technology/weather-forecast.png",
    icon_size = 256,
    effects = { { type = "nothing", effect_description = { "prain-forecast.technology-effect" } } },
    prerequisites = {},
    unit = {
      count = 50,
      ingredients = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 } },
      time = 30,
    },
    order = "d-e-z[prain-weather-forecast]",
  },
})

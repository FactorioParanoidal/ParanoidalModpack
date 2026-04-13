Settings = require("scripts.settings")
Pollution = require("scripts.pollution")

if settings.startup[Settings.UpdateChartColors].value then
  for _, pollutant in pairs(data.raw["airborne-pollutant"]) do
    if pollutant.name == "spores" then
      pollutant.chart_color = {
        r = Pollution.SporeColor.r * 0.6,
        g = Pollution.SporeColor.g * 0.5,
        b = Pollution.SporeColor.b * 0.5,
        a = 0.5,
      }
    else
      pollutant.chart_color = {
        r = Pollution.DefaultColor.r * 0.6,
        g = Pollution.DefaultColor.g * 0.5,
        b = Pollution.DefaultColor.b * 0.5,
        a = 0.5,
      }
    end
  end
end
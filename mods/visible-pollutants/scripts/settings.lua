local Settings = {}

Settings.PollutionLayer = "visible-pollutants-layer"
Settings.PollutionOpacity = "visible-pollutants-opacity"
Settings.PollutionSeeThroughMaxOpacity = "visible-pollutants-see-through-max-opacity"
Settings.MinConsideredPollution = "visible-pollutants-min"
Settings.MaxConsideredPollution = "visible-pollutants-max"
Settings.PollutionRangeExponent = "visible-pollutants-exponent"
Settings.BlendInAmount = "visible-pollutants-blend-in"
Settings.MaxLifetimeMinutes = "visible-pollutants-ttl-minutes"
Settings.MaxSpriteUpdatesPerTick = "visible-pollutants-update-limit"
Settings.UpdateChartColors = "visible-pollutants-update-chart-colors"
Settings.AddToPlanets = "visible-pollutants-add-to-planets"
Settings.EnableSolarOcclusion = "visible-pollutants-enable-solar-occlusion"
Settings.SolarEfficiencyReduction = "visible-pollutants-solar-occlusion-reduction"
Settings.MaxSolarUpdatesPerTick = "visible-pollutants-solar-occlusion-update-limit"

function Settings.update_caches()
  Sprite.RenderLayer = settings.global[Settings.PollutionLayer].value
  Sprite.Opacity = settings.global[Settings.PollutionOpacity].value
  Sprite.MaxImportantOpacity = settings.global[Settings.PollutionSeeThroughMaxOpacity].value
  Sprite.MaxNearbyOpacity = math.pow(Sprite.MaxImportantOpacity, 0.6)
  Pollution.MinPollutionShown = settings.global[Settings.MinConsideredPollution].value
  Pollution.MaxPollutionShown = settings.global[Settings.MaxConsideredPollution].value
  Pollution.Exponent = settings.global[Settings.PollutionRangeExponent].value
  Sprite.BlendIn = settings.global[Settings.BlendInAmount].value
  Sprite.OutOfBoundsSpriteTTL = settings.global[Settings.MaxLifetimeMinutes].value * 60 * 60
  Sprite.MaxUpdatesPerTick = settings.global[Settings.MaxSpriteUpdatesPerTick].value
  Solar.OcclusionEnabled = settings.global[Settings.EnableSolarOcclusion].value
  Solar.MaxEfficiencyReduction = settings.global[Settings.SolarEfficiencyReduction].value
  Solar.MaxUpdatesPerTick = settings.global[Settings.MaxSolarUpdatesPerTick].value
end

function Settings.startup_settings_changed()
  for _, force in pairs(game.forces) do
    force.rechart()
  end
end

return Settings

local Pollution = {}

Pollution.MinPollutionShown = 2
Pollution.MaxPollutionShown = 900
Pollution.Exponent = 0.4

---@type Color
Pollution.DefaultColor = { r = 0.81, g = 0.75, b = 0.72 }
---@type Color
Pollution.SporeColor = { r = 0.85, g = 0.95, b = 0.5 }

function Pollution.init_storage()
  storage.pollutant_color_by_surface = {}
end

---@param surface LuaSurface
---@param position MapPosition
---@return number pollution_ratio between 0 and 1
function Pollution.thickness(surface, position)
  local pollution = surface.get_pollution(position)
  if pollution == nil or pollution <= Pollution.MinPollutionShown then
    return 0
  end
  if pollution >= Pollution.MaxPollutionShown then
    return 1
  end
  local rescaled = (pollution - Pollution.MinPollutionShown) / (Pollution.MaxPollutionShown - Pollution.MinPollutionShown)
  local limited = rescaled
  if limited < 0 then limited = 0 end
  if limited > 1 then limited = 1 end
  local compressed = math.pow(limited, Pollution.Exponent)
  return compressed
end

---@param surface LuaSurface
---@param thickness number
---@return Color
function Pollution.color(surface, thickness)
  local color = storage.pollutant_color_by_surface[surface.index]
  if color == nil then
    color = Pollution.DefaultColor
    if surface.pollutant_type and surface.pollutant_type.name == "spores" then
      color = Pollution.SporeColor
    end
    storage.pollutant_color_by_surface[surface.index] = color
  end
  return {
    r = color.r * thickness,
    g = color.g * thickness,
    b = color.b * thickness,
    a = thickness,
  }
end

return Pollution

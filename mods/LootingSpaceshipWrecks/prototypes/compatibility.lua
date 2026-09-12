-- Keep the Beta 8 sprite definitions; 2.0 uses their HR layers directly.
local function high_resolution(value)
  if type(value) ~= "table" then return value end
  local result = {}
  for key, child in pairs(value.hr_version or value) do
    if key ~= "hr_version" then result[key] = high_resolution(child) end
  end
  return result
end

return function(entities)
  entities = high_resolution(entities)
  for _, entity in ipairs(entities) do
    if entity.type == "assembling-machine" then
      entity.graphics_set = {
        animation = entity.animation,
        working_visualisations = entity.working_visualisations
      }
      entity.animation = nil
      entity.working_visualisations = nil
      entity.energy_source.emissions_per_minute = {pollution = 4}
    end
  end
  data:extend(entities)
end

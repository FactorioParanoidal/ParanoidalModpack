Settings = require("scripts.settings")

local function split_csv(input)
  local result = {}
  local delimiter = ","
  if input ~= "" then
    for match in (input .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
  end
  return result
end

local add_pollution_to_planets = split_csv(settings.startup[Settings.AddToPlanets].value)
local pollution = data.raw["airborne-pollutant"]["pollution"]
for _, planet_name in pairs(add_pollution_to_planets) do
  local planet = data.raw["planet"][planet_name]
  if planet then
    if not planet.pollutant_type then
      if pollution then
        planet.pollutant_type = pollution.name
        log(planet_name .. " has been assigned the pollutant type: " .. pollution.name)
      else
        log("Pollution type not found, cannot assign it to planet " .. planet_name)
      end
    else
      log(planet_name .. " already has a pollutant type, not adding pollution to it")
    end
  else
    log(planet_name .. " not found, cannot add pollution to it")
  end
end
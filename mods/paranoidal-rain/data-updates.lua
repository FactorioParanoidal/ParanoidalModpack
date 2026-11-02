-- The forecast needs a radar network: after bob-radar-2 (bobwarfare), otherwise after the radar technology.
local tech = data.raw.technology["prain-weather-forecast"]
if tech then
  local techs = data.raw.technology
  if techs["bob-radar-2"] then
    tech.prerequisites = { "bob-radar-2" }
  elseif techs["radar"] then
    tech.prerequisites = { "radar" }
  end
end

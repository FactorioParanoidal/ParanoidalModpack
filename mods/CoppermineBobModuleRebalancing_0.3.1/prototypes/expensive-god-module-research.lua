-- Increase cost of god module research
local multiplier = settings.startup["coppermine-bob-module-god-module-research-multiplier"].value
if data.raw.technology["god-module-1"] then
  for level=1,5 do
    local tech_name = "god-module-"..level
    local tech = data.raw.technology[tech_name]
    tech.unit.count = math.floor(tech.unit.count * multiplier)
  end
end

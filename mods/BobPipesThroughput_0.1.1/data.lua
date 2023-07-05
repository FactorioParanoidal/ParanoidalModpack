local throughputBase = settings.startup["BPT-base"].value
if throughputBase == nil then
  throughputBase = 1
end
local throughputPerTier = settings.startup["BPT-per-tier"].value
if throughputPerTier == nil then
  throughputPerTier = 0.25
end

local material_map = {
    ["copper"] = 1,
    ["iron"] = 1,
    ["stone"] = 1,
    ["bronze"] = 2,
    ["steel"] = 2,
    ["plastic"] = 3,
    ["brass"] = 3,
    ["titanium"] = 4,
    ["ceramic"] = 4,
    ["tungsten"] = 4,
    ["nitinol"] = 5,
    ["copper-tungsten"] = 5,
}

  local pipe_entity = data.raw["pipe"]["pipe"]
  local underground_pipe_entity =  data.raw["pipe-to-ground"]["pipe-to-ground"]
  if pipe_entity then
    pipe_entity["fluid_box"].height = throughputBase
    underground_pipe_entity["fluid_box"].height = throughputBase
  end

for material, map in pairs(material_map) do
  -- Fetch entities
  local pipe_entity = data.raw["pipe"][material.."-pipe"]
  local underground_pipe_entity =  data.raw["pipe-to-ground"][material.."-pipe-to-ground"]

  -- Check if entity exists, if not, skip this iteration; assume if we have one we have both
  if pipe_entity then
    pipe_entity["fluid_box"].height = throughputBase + (map - 1) * throughputPerTier
    underground_pipe_entity["fluid_box"].height = throughputBase + (map - 1) * throughputPerTier
  end

end

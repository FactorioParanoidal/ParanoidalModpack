require("add-basic-uranium-nukes")

if (data.raw.technology["tritium-processing"]) then
  data.raw.technology["tritium-processing"].prerequisites[1] = "nuclear-breeding"
end
data.raw.technology["plutonium-atomic-bomb"] = nil

if (data.raw.technology["expanded-atomics"]) then
  table.insert(data.raw.technology["expanded-atomics"].prerequisites, "nuclear-breeding")
end
if (data.raw.technology["californium-processing"]) then
  table.insert(data.raw.technology["californium-processing"].prerequisites, "nuclear-breeding")
end

if (data.raw.technology["tritium-breeder-fuel-cell"]) then
  data.raw.item["tritium-breeder-fuel-cell"].fuel_category = "nuclear-breeder"
end
if (data.raw.technology["advanced-tritium-breeder-fuel-cell"]) then
  data.raw.item["advanced-tritium-breeder-fuel-cell"].fuel_category = "nuclear-breeder"
end

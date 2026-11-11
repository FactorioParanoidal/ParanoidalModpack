local aircraft = require("shared.aircraft")
local helper = require("lib.data-util")

-- Compatibility executes once, after every mod has defined its data-stage prototypes.
require("prototypes.recipe-updates")
require("prototypes.technologies-updates")
require("compat.planet-muluna")

for _, spec in ipairs(aircraft.aircraft) do
  if spec.grid then
    local categories = data.raw["equipment-grid"][spec.grid].equipment_categories
    for _, category in ipairs({"vehicle", "electric-vehicles-equipment"}) do
      if data.raw["equipment-category"][category] then helper.insert_unique(categories, category) end
    end
    if spec.name ~= "jet" and data.raw["equipment-category"]["armoured-vehicle"] then
      helper.insert_unique(categories, "armoured-vehicle")
    end
  end
  -- Copy fuel categories, not the vanilla car's mutable table, including categories introduced in data.
  for _, suffix in ipairs({"", "-flying", "-carbon-fiber", "-carbon-fiber-flying"}) do
    local plane = data.raw.car[spec.name .. suffix]
    if plane then plane.energy_source.fuel_categories = table.deepcopy(data.raw.car.car.energy_source.fuel_categories or {"chemical"}) end
  end
end

if mods["HelicopterRevival"] then
  if settings.startup["helicopter-tech"].value and data.raw.technology["heli-technology"] then
    helper.prerequisite("heli-technology", "advanced-aerodynamics")
  end
  local grid = data.raw["equipment-grid"]["heli-equipment-grid"]
  if settings.startup["heli-equipment-grid"].value and grid then
    helper.insert_unique(grid.equipment_categories, "aircraft")
  end
end

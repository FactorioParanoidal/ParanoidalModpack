-- Done in data-final-fixes.lua because several mods make changes to equipment categories
-- Let me know if you need this moved to a different data stage

if not settings.startup["sp-enable-spiderling"].value then
  return
end

local base_equipment_grid = data.raw["equipment-grid"][data.raw["spider-vehicle"]["spidertron"].equipment_grid]

data:extend{
  util.merge{
    base_equipment_grid,
    {
      name = "sp-spiderling-equipment-grid",
      width = 10,
      height = 4,
    }
  }
}

--[[ Copyright (c) 2022 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: data-final-fixes.lua
 * Description: Update fuel categories and grids for MU locomotives to match the originals
--]]

for name,loco in pairs(data.raw["locomotive"]) do
  -- Check if this is a MU or if it already has a MU
  if string.find(name, "%-mu$") ~= nil then
    -- ends in MU, make sure regular loco exists (without the last -mu).
    local basename = string.sub(name, 1, -4)
    if data.raw["locomotive"][basename] then
    
      -- Update fuel category
      if data.raw.locomotive[basename].burner then
        -- This MU has a regular loco with burner, copy fuel categories to MU version
        data.raw.locomotive[name].burner.fuel_category = data.raw.locomotive[basename].burner.fuel_category
        -- Link the fuel_categories table so it gets updated here even if the base changes later, no dependencies required!
        data.raw.locomotive[name].burner.fuel_categories = data.raw.locomotive[basename].burner.fuel_categories
      end
    
      -- Update grid assignment (or set to nil)
      data.raw.locomotive[name].equipment_grid = data.raw.locomotive[basename].equipment_grid
    end
    
  end
end

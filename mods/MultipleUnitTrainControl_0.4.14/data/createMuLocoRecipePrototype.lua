--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: createMuLocoRecipePrototype.lua
 * Description: Creates a new dummy recipe for the "-mu" version with:
 *   - Recipe is hidden from player.
 *   - name and ingredient[1].name are the MU version.
 *   - result is the standard version.
 *   - ingredient[2] is nil for burner locomotives. 
 *       For RET locomotives, it contains the ret-dummy fuel item to use for this MU locomotive.
--]]


function createMuLocoRecipePrototype(name, newName, newFuel)
  -- Check that source exists
  if not data.raw["locomotive"][name] then
    error("locomotive " .. name .. " doesn't exist")
  end
  
  -- Don't copy anything, make it directly convertible
  local newRecipe = 
  {
    type = "recipe",
    name = newName,
    ingredients = {{newName, 1}},
    result = name,
    hidden = true,
    allow_as_intermediate = false
  }
  
  -- Add dummy fuel item if needed
  if newFuel then 
    table.insert(newRecipe.ingredients, {newFuel,1})
  end
  
  return newRecipe
end

return createMuLocoRecipePrototype
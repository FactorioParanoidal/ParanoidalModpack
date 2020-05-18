-- renaming

local amount = 0

function deep_rename (tabl, old_name, new_name)
  for i, v in pairs (tabl) do
    if type (v) == "table" then
      deep_rename (v, old_name, new_name)
    elseif type (v) == "string" then
      if v == old_name then
        tabl[i] = new_name
        amount = amount + 1
      end
    end
  end
end


for recipe_name, recipe in pairs (data.raw.recipe) do
  if not (recipe_name == 'offshore-pump') then
    deep_rename (recipe, 'offshore-pump', 'burner-offshore-pump')
  end
end

log ('replaced: '..amount)

-- data.raw.recipe["burner-offshore-pump"].ingredients[1].name = "electronic-circuit" 
-- data.raw.recipe["burner-offshore-pump"].ingredients[1].type = "item" 
-- data.raw.recipe["burner-offshore-pump"].ingredients[1].amount = 2 


--[[
if data.raw.recipe["burner-offshore-pump"] and data.raw.recipe["burner-offshore-pump"].ingredients then
  local ingredients = data.raw.recipe["burner-offshore-pump"].ingredients
  for i, ing in pairs (ingredients) do
    local name = ing.name or ing[1]
    if name == "electronic-circuit" then
      ingredients[i] = nil
       log ('deleted ingredient: ["' .. name .. '"] by ' .. 'data.raw.recipe["burner-offshore-pump"]')
    end
  end
end
]]
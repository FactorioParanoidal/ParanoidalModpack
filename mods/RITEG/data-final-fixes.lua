-- I have a lot of mods, but sometimes I get errors like:

-- ===================================== --
-- 33.126 Error ModManager.cpp:1024: Error in assignID, item with name 'clowns-plate-osmium' does not exist.
-- Source: alt2-production-science-pack (recipe).

-- 33.295 Mods to disable:Failed to load mods: Error in assignID, item with name 'clowns-plate-osmium' does not exist.
-- Source: alt2-production-science-pack (recipe).
-- Mods to be disabled:
-- • Clowns-Science
-- • angelsrefining
-- ===================================== --

-- let's fix it!

log ('adding lost items and fluids')
local mod_name = "__RITEG__"

function is_wrong_item (item_name)
  if not item_name then return end
  local item_type_list = {"ammo", "armor", "gun", "item", "capsule", "repair-tool", "mining-tool", "item-with-entity-data", "rail-planner", "tool", "blueprint", "deconstruction-item", "blueprint-book", "selection-tool", "item-with-tags", "item-with-label", "item-with-inventory", "module"}
  local item_prot 
  for _,typ in pairs(item_type_list) do
    local prot = data.raw[typ][item_name]
    if prot then item_prot = prot end
  end
  
  if not item_prot then
    -- new_item = 
      -- {
      -- type = "item",
      -- name = item_name,
      -- -- flags = {"goes-to-main-inventory"},
      -- icons = {{icon = mod_name.."/graphics/icons/no-icon.png"}}, icon_size = 32,
      -- -- order = "e[electric-energy-interface]-b[electric-energy-interface]",
      -- stack_size = 50,
      -- -- subgroup = "energy",
    -- }
    log ('Deleted wrong item: '.. item_name)
    return true
  end
  return false
end

for recipe_name, recipe in pairs (data.raw.recipe) do
  local handlers = {recipe}
  if recipe.normal and recipe.expensive then handlers = {recipe.normal, recipe.expensive} end
  for i, handler in pairs (handlers) do
    if handler.ingredients then
      for j, ingredient in pairs (handler.ingredients) do
        local item_name, fluid_name
        if ingredient.type and ingredient.type == "item" or ingredient[1] then
          item_name = ingredient.name or ingredient[1]
        elseif ingredient.type and ingredient.type == "fluid" then
          fluid_name = ingredient.name
        end
        if is_wrong_item (item_name) then
          handler.ingredients[j] = nil
        end
      end
    end
    
  end
end
--[[ Copyright (c) 2018 Optera
 * Part of Re-Stack
 *
 * See LICENSE.md in the project directory for license information.
--]]

function add_from_item_array(items, stack_size, category)
  for _, item in pairs(items) do
    if item.name and ( not item.type or item.type == "item") then
      ReStack_Items[item.name] = {stack_size = stack_size, type = category}
    elseif item[1] then
      ReStack_Items[item[1]] = {stack_size = stack_size, type = category}
    end
  end
end

-- sets stacks for items associated with an entity or resource
function SelectItemByEntity(ent_type, stack_size, category)
  category = category or ent_type
  for _, entity in pairs(data.raw[ent_type]) do
    -- log(serpent.dump(entity))
    if entity.minable then
      if entity.minable.result then
        ReStack_Items[entity.minable.result] = {stack_size = stack_size, type = category}
      elseif entity.minable.results then
        add_from_item_array(entity.minable.results, stack_size, category)
      end
    end
  end
end

-- set stacks for recipe results (used only by smelting)
function SelectItemsByRecipeResult(recipe, stack_size, category)
  local item
  if recipe.result then
    ReStack_Items[recipe.result] = {stack_size = stack_size, type = category}
  end
  if recipe.normal and recipe.normal.result then
    ReStack_Items[recipe.normal.result] = {stack_size = stack_size, type = category}
  end
  if recipe.expensive and recipe.expensive.result then
    ReStack_Items[recipe.expensive.result] = {stack_size = stack_size, type = category}
  end

  if recipe.results then
    add_from_item_array(recipe.results, stack_size, category)
  end
  if recipe.normal and recipe.normal.results then
    add_from_item_array(recipe.normal.results, stack_size, category)
  end
  if recipe.expensive and recipe.expensive.results then
    add_from_item_array(recipe.expensive.results, stack_size, category)
  end
end

-- set stack for all recipe input items (used only by rocket parts)
function SelectItemsByRecipeInput(recipe, stack_size, category)
  if recipe.ingredients then
    add_from_item_array(recipe.ingredients, stack_size, category)
  end
  if recipe.normal and recipe.normal.ingredients then
    add_from_item_array(recipe.normal.ingredients, stack_size, category)
  end
  if recipe.expensive and recipe.expensive.ingredients then
    add_from_item_array(recipe.expensive.ingredients, stack_size, category)
  end
end

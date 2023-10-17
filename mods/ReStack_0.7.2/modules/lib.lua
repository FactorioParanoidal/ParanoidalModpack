  --[[ Copyright (c) 2018 Optera
 * Part of Re-Stack
 *
 * See LICENSE.md in the project directory for license information.
--]]

function add_from_item_array(items, stack_size, category, placed_entity)
  for _, item in pairs(items) do
    if item.name and (item.type == nil or item.type == "item") then -- fully defined item table
      if placed_entity == nil or (placed_entity and placed_entity == item.place_result) then
        ReStack_Items[item.name] = {stack_size = stack_size, type = category}
      end
    elseif item[1] and placed_entity == nil then -- lazy definition {name, count}
      ReStack_Items[item[1]] = {stack_size = stack_size, type = category}
    end
  end
end

-- sets stacks for items associated with an entity or resource
function SelectItemByEntity(ent_type, stack_size, category, reverse_check)
  category = category or ent_type
  if reverse_check == nil then
    reverse_check = true
  end
  for name, entity in pairs(data.raw[ent_type]) do
    if entity.minable then
      if entity.minable.result then
        ReStack_Items[entity.minable.result] = {stack_size = stack_size, type = category}
      elseif entity.minable.results then
        if reverse_check then
        add_from_item_array(entity.minable.results, stack_size, category, name)
        else
          add_from_item_array(entity.minable.results, stack_size, category)
        end
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

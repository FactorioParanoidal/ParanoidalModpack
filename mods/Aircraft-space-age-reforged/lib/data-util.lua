local M = {}

function M.insert_unique(list, value)
  for _, entry in ipairs(list) do if entry == value then return end end
  list[#list + 1] = value
end

function M.prerequisite(technology, prerequisite)
  local target = assert(data.raw.technology[technology], "Missing aircraft technology: " .. technology)
  assert(data.raw.technology[prerequisite], "Missing prerequisite: " .. prerequisite)
  target.prerequisites = target.prerequisites or {}
  M.insert_unique(target.prerequisites, prerequisite)
end

function M.remove_prerequisite(technology, prerequisite)
  local list = data.raw.technology[technology].prerequisites or {}
  for i = #list, 1, -1 do if list[i] == prerequisite then table.remove(list, i) end end
end

function M.material_gate(technology, candidates)
  for _, name in ipairs(candidates) do
    if data.raw.technology[name] then M.prerequisite(technology, name); return end
  end
  log("Aircraft: no known technology gate for material used by " .. technology)
end

function M.replace_ingredient(recipe, old, replacement)
  for _, ingredient in ipairs(recipe.ingredients) do
    if ingredient.type == "item" and ingredient.name == old then
      ingredient.name = replacement
      return
    end
  end
  error("Aircraft: missing ingredient " .. old .. " in " .. recipe.name)
end

function M.split_ingredient(recipe, old, replacement, amount)
  for _, ingredient in ipairs(recipe.ingredients) do
    if ingredient.type == "item" and ingredient.name == old then
      assert(ingredient.amount > amount, "Aircraft: invalid material split in " .. recipe.name)
      ingredient.amount = ingredient.amount - amount
      recipe.ingredients[#recipe.ingredients + 1] = {type = "item", name = replacement, amount = amount}
      return
    end
  end
  error("Aircraft: missing material " .. old .. " in " .. recipe.name)
end

function M.science(technology, name)
  for _, pack in ipairs(technology.unit.ingredients) do
    if (pack.name or pack[1]) == name then return end
  end
  technology.unit.ingredients[#technology.unit.ingredients + 1] = {name, 1}
end

return M

local M = {}

local item_types = {
  "item",
  "item-with-entity-data",
  "item-with-label",
  "item-with-inventory",
  "rail-planner",
  "selection-tool",
}

function M.select_ingredients(sets)
  for _, set in ipairs(sets) do
    local found_all = true
    for _, ingredient in ipairs(set) do
      local found = false
      for _, type in ipairs(item_types) do
        if data.raw[type][ingredient[1]] then
          found = true
          break
        end
      end
      if not found then
        found_all = false
      end
    end
    if found_all then
      return set
    end
  end
end

return M
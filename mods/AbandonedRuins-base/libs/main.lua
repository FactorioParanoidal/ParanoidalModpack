function replace_item_name_in_all_ruins(ruin_set, value, replacement)
  for size, ruins in pairs(ruin_set) do
    for _, ruin in pairs(ruins) do
      replace_item_name(ruin, value, replacement)
    end
  end
end

function replace_item_name(ruin, name, replacement)
  if not (ruin.entities and next(ruin.entities) ~= nil) then return end

  for _, entity in pairs(ruin.entities) do
    if entity[3] and entity[3].items then
      local items = base_util.copy(entity[3].items)
      for item, count in pairs(items) do
        if item == name then
          entity[3].items[replacement] = count
          entity[3].items[name] = nil
        end
      end
    end
  end
end

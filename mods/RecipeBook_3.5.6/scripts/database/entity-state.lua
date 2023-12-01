return function(database)
  for _, entity_data in pairs(database.entity) do
    -- Hidden / disabled for entities
    if not entity_data.is_character then
      local placed_by_len = #(entity_data.placed_by or {})
      if placed_by_len == 0 and not entity_data.expected_resources then
        entity_data.enabled = false
      elseif placed_by_len == 1 then
        local item_ident = entity_data.placed_by[1]
        local item_data = database.item[item_ident.name]
        if item_data.hidden then
          entity_data.hidden = true
        end
      end
    end
  end
end

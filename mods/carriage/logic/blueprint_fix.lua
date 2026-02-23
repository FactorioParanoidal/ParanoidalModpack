function FixPipette(event)
  -- Pipetting engine, rail boat, or route doesn't work
  local player = game.players[event.player_index]
  local selected = player.selected
  local item = event.item
  --game.print("pipetted "..item.name)

  if storage.carriage_engines[item.name] then
    --cursor.clear()
    if selected then
      local otherstock = selected.get_connected_rolling_stock(defines.rail_direction.front) or 
                         selected.get_connected_rolling_stock(defines.rail_direction.back)
      if otherstock then
        -- Pipette the carriage body instead
        player.pipette(otherstock.prototype, otherstock.quality, true)
      end
    end
  elseif is_route[item.name] then
    -- When the setting "Pick Ghost if no items are available" is not enabled then
    -- it's never possible to pipette a route. There's no way to check if this
    -- setting already put the correct item in the cursor though
    -- so instead we will set the cursor everytime.
    if player.clear_cursor() then
      -- The cursor is always clear when this event is fired due to the
      -- nature of the pipette function. But make sure it's clear anyway.
      player.cursor_ghost = {name="route"}
    end
  end
end

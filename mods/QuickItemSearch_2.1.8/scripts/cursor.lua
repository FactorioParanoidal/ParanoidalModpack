local cursor = {}

function cursor.set_stack(player, cursor_stack, player_table, item_name)
  local is_cheating = player.cheat_mode or (player.controller_type == defines.controllers.editor)
  local spawn_item = player_table.settings.spawn_items_when_cheating

  -- space exploration - don't spawn items when in the satellite view
  if script.active_mods["space-exploration"] and player.controller_type == defines.controllers.god then
    spawn_item = false
  end

  -- don't bother if they don't have an inventory
  local main_inventory = player.get_main_inventory()
  if main_inventory then
    -- set cursor stack
    local item_stack, item_stack_index, inventory_index
    for _, inventory in pairs({
      main_inventory,
      player.get_inventory(defines.inventory.character_ammo),
      player.get_inventory(defines.inventory.character_guns),
    }) do
      item_stack, item_stack_index = inventory.find_item_stack(item_name)
      if item_stack and item_stack.valid then
        inventory_index = inventory.index
        break
      end
    end
    if item_stack and item_stack.valid then
      if player.clear_cursor() then
        -- actually transfer from the source inventory, then set the hand location
        cursor_stack.transfer_stack(item_stack)
        player.hand_location = { inventory = inventory_index, slot = item_stack_index }
      end
      return true
    elseif spawn_item and is_cheating then
      local stack_spec = { name = item_name, count = game.item_prototypes[item_name].stack_size }
      -- insert into main inventory first, then transfer and set the hand location
      if main_inventory.can_insert(stack_spec) and player.clear_cursor() then
        main_inventory.insert(stack_spec)
        local new_stack, new_stack_index = main_inventory.find_item_stack(item_name)
        cursor_stack.transfer_stack(new_stack)
        player.hand_location = { inventory = main_inventory.index, slot = new_stack_index }
      else
        player.create_local_flying_text({
          text = { "message.qis-main-inventory-full" },
          create_at_cursor = true,
        })
        player.play_sound({
          path = "utility/cannot_build",
        })
      end
      return true
    elseif player.clear_cursor() then
      player_table.last_item = item_name
      player.cursor_ghost = item_name
      return true
    end
  end
end

return cursor

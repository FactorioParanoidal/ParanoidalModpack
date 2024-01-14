--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Robot256Library
 * File: blueprint.lua
 * Description: Handlers for on_player_pipette, on_player_setup_blueprint, on_player_configured_blueprint.
 *    When player creates or edits a blueprint containing, or uses pipette on a non-craftable entity,
 *    these functions will replace it with the craftable entity if possible.
 *  event: Event parameter object.
 *  map:   Dictionary mapping non-craftable entity names to craftable entity names.

 Examples:

 --== ON_PLAYER_CONFIGURED_BLUEPRINT EVENT ==--
-- ID 70, fires when you select a blueprint to place
--== ON_PLAYER_SETUP_BLUEPRINT EVENT ==--
-- ID 68, fires when you select an area to make a blueprint or copy
local function OnPlayerSetupBlueprint(event)
  mapBlueprint(event,map)
end


--== ON_PLAYER_PIPETTE ==--
-- Fires when player presses 'Q'.  We need to sneakily grab the correct item from inventory if it exists,
--  sneakily give the correct item in cheat mode, and fix the cursor ghost if any.
local function OnPlayerPipette(event)
  mapPipette(event,map)
end

 --]]


local function purgeBlueprint(bp,map)
  -- Get Entity table from blueprint
  local entities = bp.get_blueprint_entities()
  -- Find any downgradable items and downgrade them
  if entities and next(entities) then
    for _,e in pairs(entities) do
      if map[e.name] then
        e.name = map[e.name]
      end
    end
    -- Write tables back to the blueprint
    bp.set_blueprint_entities(entities)
  end
  -- Find icons too
  local icons = bp.blueprint_icons
  if icons and next(icons) then
    for _,i in pairs(icons) do
      if i.signal.type == "item" then
        if map[i.signal.name] then
          i.signal.name = map[i.signal.name]
        end
      end
    end
    -- Write tables back to the blueprint
    bp.blueprint_icons = icons
  end
end


local function mapBlueprint(event,map)
  -- Get Blueprint from player (LuaItemStack object)
  -- If this is a Copy operation, BP is in cursor_stack
  -- If this is a Blueprint operation, BP is in blueprint_to_setup
  -- Need to use "valid_for_read" because "valid" returns true for empty LuaItemStack in cursor

  local item1 = game.get_player(event.player_index).blueprint_to_setup
  local item2 = game.get_player(event.player_index).cursor_stack
  if item1 and item1.valid_for_read==true then
    purgeBlueprint(item1,map)
  elseif item2 and item2.valid_for_read==true and item2.is_blueprint==true then
    purgeBlueprint(item2,map)
  end

end


local function mapPipette(event,map)
  local item = event.item
  if map[item.name] then
    -- Originally pipetted on an item of interest
    -- Check current contents of cursor
    local player = game.players[event.player_index]
    local cursor = player.cursor_stack
    if cursor.valid_for_read then
      if map[cursor.name] then
        local inventory = player.get_main_inventory()
        local newName = map[cursor.name]
        if event.used_cheat_mode then
          local newItemStack = inventory.find_item_stack(newName)
          if newItemStack then
            -- Delete cheat-gotten wrong items, load correct items from inventory
            cursor.set_stack(newItemStack)
            inventory.remove(newItemStack)
          else
            -- Delete cheat-gotten wrong items, cheat-give correct items
            cursor.set_stack({name=newName, count=game.item_prototypes[newName].stack_size})
          end
        else
          -- Transform fairly-gotten wrong items into correct items
          cursor.set_stack({name=newName, count=cursor.count})
        end
      end
    else
      if not event.used_cheat_mode then
        local inventory = player.get_main_inventory()
        local newName = map[item.name]
        local newItemStack = inventory.find_item_stack(newName)
        if newItemStack then
          -- Load empty cursor with correct items from inventory
          cursor.set_stack(newItemStack)
          inventory.remove(newItemStack)
        end
      end
    end
    
    -- Check contents of cursor_ghost as well (can coexist with cursor_stack)
    if player.cursor_ghost and map[player.cursor_ghost.name] then
      player.cursor_ghost = map[player.cursor_ghost.name]
    end
  end
end


return {
  purgeBlueprint = purgeBlueprint,
  mapBlueprint = mapBlueprint,
  mapPipette = mapPipette
}

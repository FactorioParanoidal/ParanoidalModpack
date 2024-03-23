local RecipeChange = {}

local function add_contents(contents1, contents2)
  for name, count in pairs(contents2) do
    if contents1[name] then
      contents1[name] = contents1[name] + count
    else
      contents1[name] = count
    end
  end
end

local function get_inventory_contents(entity, inventory_defines)
  local inventory = entity.get_inventory(inventory_defines)
  if inventory then
    return inventory.get_contents()
  else
    return {}
  end
end

local function get_machine_contents(entity)
  local contents = {}
  add_contents(contents, get_inventory_contents(entity, defines.inventory.assembling_machine_input))
  add_contents(contents, get_inventory_contents(entity, defines.inventory.assembling_machine_output))
  add_contents(contents, get_inventory_contents(entity, defines.inventory.assembling_machine_modules))

  -- Also add internal items currently being used to craft
  if entity.crafting_progress > 0 then
    local recipe = entity.get_recipe()
    if recipe then
      for _, ingredient in pairs(recipe.ingredients) do
        if ingredient.type == "item" then
          add_contents(contents, {[ingredient.name] = ingredient.amount})
        end
      end
    end
  end
  return contents
end

local function get_player_contents(entity)
  local contents = {}
  add_contents(contents, get_inventory_contents(entity, defines.inventory.character_main))
  add_contents(contents, get_inventory_contents(entity, defines.inventory.character_guns))
  add_contents(contents, get_inventory_contents(entity, defines.inventory.character_ammo))
  add_contents(contents, get_inventory_contents(entity, defines.inventory.character_armor))
  add_contents(contents, get_inventory_contents(entity, defines.inventory.character_trash))
  return contents
end

local function diff_contents(old_contents, new_contents)
  local diff = {}
  for name, count in pairs(old_contents) do
    if new_contents[name] then
      if new_contents[name] ~= count and (new_contents[name] - count ~= 0) then
        diff[name] = new_contents[name] - count
      end
    else
      diff[name] = -count
    end
  end
  for name, count in pairs(new_contents) do
    if not old_contents[name] then
      diff[name] = count
    end
  end
  return diff
end

local function ensure_positive(diff)
  for name, count in pairs(diff) do
    if count <= 0 then
      diff[name] = nil
    end
  end
  return diff
end

function RecipeChange.on_remote_gui_opened(player)
  local entity = player.opened
  if entity.type == "assembling-machine" then
    local recipe = entity.get_recipe() or {name = "rc-no-recipe"}
    if recipe then
      global[player.index] = {
        player = player,
        recipe = recipe.name,
        entity = entity,
        player_contents = get_player_contents(player),
        entity_contents = get_machine_contents(entity),
      }
    end
  end
end

function RecipeChange.on_gui_closed(player)
  global[player.index] = nil
end

local function on_recipe_changed(player_data)
  local entity = player_data.entity
  local entity_diff = ensure_positive(diff_contents(get_machine_contents(entity), player_data.entity_contents))
  if table_size(entity_diff) == 0 then return end

  -- Entity contents changed
  local player_diff = diff_contents(player_data.player_contents, get_player_contents(player_data.player))

  -- Positive count in entity_diff means items were lost
  -- Positive count in player_diff means items were gained
  -- We need to find the subset of items lost in entity_diff that were gained in player_diff

  local surface = entity.surface
  local position = entity.position
  local player = player_data.player
  local force = player.force
  for name, count in pairs(entity_diff) do
    if player_diff[name] then
      local to_spill = math.min(count, player_diff[name])
      --game.print(game.tick .. " Trying to spill " .. to_spill .. " " .. name)
      local removed = player.remove_item({name = name, count = to_spill})  -- Handles main, ammo, cursor
      to_spill = to_spill - removed
      if to_spill > 0 then
        -- Handle guns, armor, trash
        removed = player.get_inventory(defines.inventory.character_trash).remove({name = name, count = to_spill})
        to_spill = to_spill - removed
        if to_spill > 0 then
          removed = player.get_inventory(defines.inventory.character_armor).remove({name = name, count = to_spill})
          to_spill = to_spill - removed
          if to_spill > 0 then
            removed = player.get_inventory(defines.inventory.character_guns).remove({name = name, count = to_spill})
            to_spill = to_spill - removed
          end
        end
      end
      if removed > 0 then
        --game.print(game.tick .. " Spilling " .. removed .. " " .. name)
        surface.spill_item_stack(
          position,
          {name = name, count = removed},
          true,  -- enabled_looted
          force,  -- force for deconstruction
          false  -- allow_on_belts
        )
      end
    end
  end
end

local function process_player(player_data)
  local entity = player_data.entity
  if not entity.valid then return end
  local recipe = entity.get_recipe() or {name = "rc-no-recipe"}
  if recipe.name ~= player_data.recipe then
    on_recipe_changed(player_data)
    player_data.recipe = recipe.name
    --game.print(game.tick .. " Recipe changed to " .. recipe.name)
  end
  -- Update stored info
  player_data.player_contents = get_player_contents(player_data.player)
  player_data.entity_contents = get_machine_contents(player_data.entity)
end

script.on_event(defines.events.on_tick,
  function(event)
    global.my_data = true
    for _, player_data in pairs(global) do
      if type(player_data) == "table" and player_data.player then
        process_player(player_data)
      end
    end
  end
)

return RecipeChange
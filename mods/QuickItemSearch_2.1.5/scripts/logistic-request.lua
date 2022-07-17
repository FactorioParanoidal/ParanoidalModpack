local math = require("__flib__.math")
local table = require("__flib__.table")

local constants = require("constants")

local search = require("scripts.search")

local logistic_request = {}

function logistic_request.set(player, player_table, name, counts, is_temporary)
  local requests = player_table.logistic_requests
  local request_data = requests.by_name[name]
  local request_index
  if request_data then
    request_index = request_data.index
  else
    request_data = { min = 0, max = math.max_uint }
    -- search for first empty slot
    local i = 1
    while true do
      local existing_request = player.get_personal_logistic_slot(i)
      if existing_request.name then
        i = i + 1
      else
        request_index = i
        break
      end
    end
  end

  -- save previous request if this one is temporary
  if is_temporary then
    -- Do not overwrite previously stored request.
    if not requests.temporary[name] then
      requests.temporary[name] = table.deep_copy(request_data)
      -- Store age of temporary request in order to allow player to
      -- persist changes after temporary requests have been fulfilled.
      requests.temporary[name].age = game.tick
    end
  else
    -- delete temporary request for this item if there is one
    requests.temporary[name] = nil
  end

  -- set on player
  -- this will create or update the data in the requests table automatically
  player.set_personal_logistic_slot(request_index, {
    name = name,
    min = counts.min,
    max = counts.max,
  })
end

function logistic_request.clear(player, player_table, name)
  local requests = player_table.logistic_requests
  if not requests then
    return
  end
  local request_data = requests.by_name[name]
  if request_data then
    player.clear_personal_logistic_slot(request_data.index)
  end
end

function logistic_request.update(player, player_table, slot_index)
  local requests = player_table.logistic_requests
  if not requests then
    return
  end
  local existing_request = player.get_personal_logistic_slot(slot_index)
  if existing_request then
    local request_data = requests.by_index[slot_index]
    if request_data then
      if request_data.name == existing_request.name then
        -- update counts
        request_data.min = existing_request.min
        request_data.max = existing_request.max
      else
        requests.by_name[request_data.name] = nil
        if existing_request.name then
          existing_request.index = slot_index
          requests.by_index[slot_index] = existing_request
          requests.by_name[existing_request.name] = existing_request
        else
          -- delete this request's data entirely
          requests.by_index[slot_index] = nil
        end
      end
    elseif existing_request.name then
      existing_request.index = slot_index
      requests.by_index[slot_index] = existing_request
      requests.by_name[existing_request.name] = existing_request
    end

    -- Update previous request's quantities if affected. Allows player
    -- to make changes to logistic requests that are affected by
    -- temporary requests or quick-trashing, and still preserve those
    -- (manual) changes after temporary requests are fullfilled.
    if existing_request.name then
      local temporary_request = requests.temporary[existing_request.name]
      local current_age = game.tick

      if temporary_request and temporary_request.age < current_age then
        temporary_request.age = current_age
        temporary_request.min = existing_request.min
        temporary_request.max = existing_request.max
      end
    end

  end
end

function logistic_request.refresh(player, player_table)
  local requests = {
    by_index = {},
    by_name = {},
    temporary = {},
  }
  local character = player.character
  if character then
    for i = 1, character.request_slot_count do
      local filter = player.get_personal_logistic_slot(i)
      if filter and filter.name then
        filter.index = i
        requests.by_index[i] = filter
        requests.by_name[filter.name] = filter
      end
    end
  end
  -- preserve valid temporary requests
  local item_prototypes = game.item_prototypes
  for item_name, request in pairs(player_table.logistic_requests.temporary) do
    if item_prototypes[item_name] then
      requests.temporary[item_name] = request
    end
  end
  player_table.logistic_requests = requests
end

function logistic_request.update_temporaries(player, player_table, combined_contents)
  local requests = player_table.logistic_requests
  if not requests then
    return
  end
  local temporary_requests = requests.temporary

  for name, old_request_data in pairs(temporary_requests) do
    local existing_request_data = requests.by_name[name]
    if existing_request_data then
      local has_count = combined_contents[name] or 0
      -- if the request has been satisfied
      if has_count >= existing_request_data.min and has_count <= existing_request_data.max then
        -- clear the temporary request data first to avoid setting the slot twice
        temporary_requests[name] = nil
        -- set the former request
        player.set_personal_logistic_slot(existing_request_data.index, old_request_data)
      end
    else
      temporary_requests[name] = nil
    end
  end
end

function logistic_request.quick_trash_all(player, player_table)
  local main_inventory = player.get_main_inventory()
  if not main_inventory or not main_inventory.valid then
    return
  end
  local requests = player_table.logistic_requests
  if not requests then
    return
  end
  local prototypes = game.item_prototypes
  for name, count in pairs(search.get_combined_inventory_contents(player, main_inventory)) do
    if not constants.ignored_item_types[prototypes[name].type] then
      local existing_request = requests.by_name[name]
      if existing_request then
        if count > existing_request.min then
          logistic_request.set(
            player,
            player_table,
            name,
            { min = existing_request.min, max = existing_request.min },
            true
          )
        end
      else
        logistic_request.set(player, player_table, name, { min = 0, max = 0 }, true)
      end
    end
  end
end

return logistic_request

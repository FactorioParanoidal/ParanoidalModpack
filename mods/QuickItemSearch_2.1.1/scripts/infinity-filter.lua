local table = require("__flib__.table")

local search = require("scripts.search")

local infinity_filter = {}

function infinity_filter.set(player, player_table, filter, is_temporary)
  local infinity_filters = player_table.infinity_filters
  local filter_data = infinity_filters.by_name[filter.name]
  local filter_index
  if filter_data then
    filter_index = filter_data.index
  else
    filter_index = #infinity_filters.by_index + 1
  end

  -- save previous request if this one is temporary
  if is_temporary then
    -- set to `false` if it needs to be cleared
    infinity_filters.temporary[filter.name] = filter_data and table.deep_copy(filter_data) or false
  else
    -- delete temporary request for this item if there is one
    infinity_filters.temporary[filter.name] = nil
  end

  -- set on player
  player.set_infinity_inventory_filter(
    filter_index,
    { name = filter.name, mode = filter.mode, count = filter.count, index = filter_index }
  )

  -- update stored requests
  infinity_filter.update(player, player_table)
end

function infinity_filter.clear(player, player_table, name)
  local infinity_filters = player_table.infinity_filters
  local filter_data = infinity_filters.by_name[name]
  if filter_data then
    player.set_infinity_inventory_filter(filter_data.index, nil)
    infinity_filter.update(player, player_table)
  end
end

-- updates by_index and by_name without replacing everything
function infinity_filter.update(player, player_table)
  local by_index = {}
  local by_name = {}
  for i, existing_filter in pairs(player.infinity_inventory_filters) do
    by_index[i] = existing_filter
    by_name[existing_filter.name] = existing_filter
  end
  player_table.infinity_filters.by_index = by_index
  player_table.infinity_filters.by_name = by_name
end

function infinity_filter.refresh(player, player_table)
  local infinity_filters = {
    by_index = {},
    by_name = {},
    temporary = {},
  }
  for i, existing_filter in pairs(player.infinity_inventory_filters) do
    infinity_filters.by_index[i] = existing_filter
    infinity_filters.by_name[existing_filter.name] = existing_filter
  end
  -- preserve valid temporary filters
  -- this shouldn't be needed in 99% of cases, as infinity filters are immediately satisfied
  local item_prototypes = game.item_prototypes
  for item_name, request in pairs(player_table.infinity_filters.temporary) do
    if item_prototypes[item_name] then
      infinity_filters.temporary[item_name] = request
    end
  end
  player_table.infinity_filters = infinity_filters
end

function infinity_filter.update_temporaries(player, player_table)
  local main_inventory = player.get_main_inventory()
  if main_inventory and main_inventory.valid then
    local infinity_filters = player_table.infinity_filters
    for name, old_filter_data in pairs(infinity_filters.temporary) do
      -- infinity filters are guaranteed to be fulfilled, so we can safely remove temporaries immediately
      if old_filter_data then
        infinity_filter.set(player, player_table, old_filter_data)
      else
        infinity_filter.clear(player, player_table, name)
      end
    end
    infinity_filters.temporary = {}
  end
end

function infinity_filter.quick_trash_all(player, player_table)
  local main_inventory = player.get_main_inventory()
  if main_inventory and main_inventory.valid then
    local infinity_filters = player_table.infinity_filters
    for name, count in pairs(search.get_combined_inventory_contents(player, main_inventory)) do
      local existing_filter = infinity_filters.by_name[name] or { mode = "at-least", count = 0 }
      if existing_filter.mode == "at-least" and count > existing_filter.count then
        infinity_filter.set(player, player_table, { name = name, mode = "exactly", count = 0 }, true)
      end
    end
  end
end

return infinity_filter

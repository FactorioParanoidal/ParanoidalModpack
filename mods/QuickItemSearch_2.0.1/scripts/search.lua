local constants = require("constants")

local search = {}

function search.run(player, player_table, query, combined_contents)
  -- don't bother if they don't have a main inventory
  local main_inventory = player.get_main_inventory()
  if main_inventory and main_inventory.valid then
    local requests = player_table.logistic_requests
    local requests_by_name = requests.by_name
    local filters = player_table.infinity_filters
    local filters_by_name = filters.by_name
    local settings = player_table.settings
    local translations = player_table.translations

    local item_prototypes = game.item_prototypes
    local character = player.character

    -- settings
    local show_hidden = settings.show_hidden

    local connected_to_network = false
    local logistic_requests_available = false
    local results = {}

    -- get contents of all player inventories and cursor stack
    -- in some cases, this is passed in externally to save performance
    combined_contents = combined_contents or search.get_combined_inventory_contents(player, main_inventory)
    -- don't bother doing anything if they don't have an inventory
    local contents = {
      inbound = {},
      inventory = combined_contents,
      logistic = {},
      outbound = {}
    }

    local controller_type = player.controller_type

    -- get logistic network and related contents
    if character and character.valid then
      logistic_requests_available = player.force.character_logistic_requests
      for _, data in ipairs(constants.logistic_point_data) do
        local point = character.get_logistic_point(data.logistic_point)
        if point and point.valid then
          contents[data.deliveries_table] = point[data.source_table]
          if data.point_name == "requester" then
            local logistic_network = point.logistic_network
            if logistic_network.valid then
              connected_to_network = true
              contents.logistic = logistic_network.get_contents()
            end
          end
        end
      end
    end

    -- perform search
    local i = 0
    for name, translation in pairs(translations) do
      if string.find(string.lower(translation), query) then
        local hidden = item_prototypes[name].has_flag("hidden")
        if show_hidden or not hidden then
          local inventory_count = contents.inventory[name]
          local logistic_count = contents.logistic[name]

          local result = {
            hidden = hidden,
            inventory = inventory_count,
            logistic = logistic_count and math.max(logistic_count, 0) or nil,
            name = name,
            translation = translation,
          }

          if controller_type == defines.controllers.character then
            -- add logistic request, if one exists
            local request = requests_by_name[name]
            if request then
              result.request = {min = request.min, max = request.max}
              if requests.temporary[name] then
                result.request.is_temporary = true
              end
            end
            -- determine logistic request color
            local color
            if contents.inbound[name] then
              color = "inbound"
            elseif contents.outbound[name] then
              color = "outbound"
            elseif request and (inventory_count or 0) < request.min then
              color = "unsatisfied"
            else
              color = "normal"
            end
            result.request_color = color
          elseif controller_type == defines.controllers.editor then
            -- add infinity filter, if one exists
            local filter = filters_by_name[name]
            if filter then
              result.infinity_filter = {mode = filter.mode, count = filter.count}
            end
          end

          i = i + 1
          results[i] = result
        end
      end
      if i > constants.results_limit then break end
    end

    return results, connected_to_network, logistic_requests_available
  end
  return {}, false, false
end

function search.get_combined_inventory_contents(player, main_inventory)
  -- main inventory contents
  local combined_contents = main_inventory.get_contents()
  -- cursor stack
  local cursor_stack = player.cursor_stack
  if cursor_stack and cursor_stack.valid_for_read then
    combined_contents[cursor_stack.name] = (combined_contents[cursor_stack.name] or 0) + cursor_stack.count
  end
  -- other
  for _, inventory_def in ipairs{
    -- for some reason, the character_ammo and character_guns inventories work in the editor as well
    defines.inventory.character_ammo,
    defines.inventory.character_guns,
    -- defines.inventory.character_trash
  } do
    local inventory = player.get_inventory(inventory_def)
    if inventory and inventory.valid then
      for name, count in pairs(inventory.get_contents() or {}) do
        combined_contents[name] = (combined_contents[name] or 0) + count
      end
    end
  end

  return combined_contents, true
end

return search

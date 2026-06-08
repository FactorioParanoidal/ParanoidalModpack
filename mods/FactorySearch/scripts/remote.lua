local remote_interface = {}

local on_item_selected = script.generate_event_name()

local on_external_item_callback = nil

--- Open the search GUI for a player with the given item pre-selected.
---@param player LuaPlayer
---@param search_value SignalID
function remote_interface.search(player, search_value)
  SearchGui.open(player, storage.players[player.index])
  local player_data = storage.players[player.index]
  player_data.refs.item_select.elem_value = search_value
  SearchGui.start_search(player, player_data)
end

function remote_interface.get_on_item_selected()
  return on_item_selected
end

function remote_interface.interop_version()
  return 1
end

remote.add_interface("factory-search", remote_interface)

local function raise_item_selected(player_index, item_name)
  script.raise_event(on_item_selected, {
    player_index = player_index,
    item_name = item_name,
  })
end

local function subscribe_to_events()
  for iface, functions in pairs(remote.interfaces) do
    if iface == "factory-search" then goto continue end

    if functions["get_on_item_selected"] then
      local event_id = remote.call(iface, "get_on_item_selected")
      if event_id then
        local source_iface = iface
        script.on_event(event_id, function(e)
          local player = game.get_player(e.player_index)
          if not player then return end
          local item_name = e.item_name
          if item_name and (prototypes.item[item_name] or prototypes.fluid[item_name]) then
            if on_external_item_callback then
              on_external_item_callback(e.player_index, item_name, source_iface)
            end
          end
        end)
        log("FactorySearch: subscribed to " .. iface .. ".get_on_item_selected")
      end
    end

    ::continue::
  end
end

local function add_recent_item(player_index, item_name, source)
  if not storage.recent_external_items then
    storage.recent_external_items = {}
  end
  local list = storage.recent_external_items[player_index]
  if not list then
    list = {}
    storage.recent_external_items[player_index] = list
  end

  -- Deduplicate: remove existing entry for this item
  for i = #list, 1, -1 do
    if list[i].item_name == item_name then
      table.remove(list, i)
    end
  end

  table.insert(list, 1, { item_name = item_name, source = source })
  if #list > 5 then
    list[6] = nil
  end
end

local function set_on_external_item_callback(cb)
  on_external_item_callback = cb
end

return {
  raise_item_selected = raise_item_selected,
  subscribe_to_events = subscribe_to_events,
  add_recent_item = add_recent_item,
  set_on_external_item_callback = set_on_external_item_callback,
}

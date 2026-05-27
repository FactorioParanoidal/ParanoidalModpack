remote.add_interface("factory-search", {
  ---@param player LuaPlayer
  ---@param search_value SignalID
  search = function(player, search_value)
    SearchGui.open(player, storage.players[player.index])
    local player_data = storage.players[player.index]
    player_data.refs.item_select.elem_value = search_value
    SearchGui.start_search(player, player_data)
  end
})

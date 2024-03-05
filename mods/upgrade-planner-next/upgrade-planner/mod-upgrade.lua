local UPGui = require("upgrade-planner/gui")

return {
  ["1.7.0"] = function()
    game.print("Upgrade to version 1.7.0 of Upgrade Planner")
    global.current_config = {}
    for player_name, config in pairs(global.config) do
      global.current_config[game.players[player_name].index] = config
    end
    global.config = nil

    local temp_storage_index = global.storage_index
    global.storage_index = {}

    for player_name, index in pairs(temp_storage_index) do
      global.storage_index[game.players[player_name].index] = index
    end

    local temp_storage = global.storage
    global.storage = {}

    for player_name, storage in pairs(temp_storage) do
      global.storage[game.players[player_name].index] = storage
    end

    global.default_bot = {}
    for index, player in pairs(game.players) do
      global.default_bot[index] = global.default_bot[index] or false
      UPGui.open_frame(player)
      UPGui.open_frame(player)
    end
  end,
}

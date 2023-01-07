local global_data = require("__QuickItemSearch__/scripts/global-data")
local player_data = require("__QuickItemSearch__/scripts/player-data")

return {
  ["2.0.0"] = function()
    -- NUKE EVERYTHING
    global = {}
    -- re-init
    global_data.init()
    for i in pairs(game.players) do
      player_data.init(i)
    end
  end,
  ["2.1.5"] = function()
    local current_age = game.tick
    for player_index in pairs(game.players) do
      for _, request in pairs(global.players[player_index].logistic_requests.temporary) do
        if not request.age then
          request.age = current_age
        end
      end
    end
  end,
  ["2.1.6"] = function()
    if global.__flib then
      global.__flib.translation = nil
    end
  end
}

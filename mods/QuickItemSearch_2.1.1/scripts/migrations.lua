local global_data = require("scripts.global-data")
local player_data = require("scripts.player-data")

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
}

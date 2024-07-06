require("__automated-utility-protocol__.util.main")
local technology_handler = require("technology-handler")

local GameModeUtil = {}

local function handle_game_mode_data(mode)
    technology_handler.handle_technologies(mode)
end

GameModeUtil.handle_game_mode_datas = function()
    _table.each(GAME_MODES, handle_game_mode_data)
end

return GameModeUtil

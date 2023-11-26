require("util.main")
local TechnologyLeafFinder = require("prototypes.final-fixes.leaf.finder.technology-leaf-finder")
local TechnologyLeafHandler = require("prototypes.final-fixes.leaf.handler.technology-leaf-handler")

local GameModeUtil = {}

local function handle_game_mode_data(mode)
	TechnologyTreeCacheUtil.initTechnologyTreeCache(mode)
	local leafTechologies = TechnologyLeafFinder.getLeafTechnologiesForResettingDependenies(mode)
	TechnologyLeafHandler.handleLeafTechonologies(leafTechologies, mode)
	TechnologyTreeCacheUtil.clearTechnologyTreeCache(mode)
end

GameModeUtil.handle_game_mode_datas = function()
	_table.each(GAME_MODES, handle_game_mode_data)
end

return GameModeUtil

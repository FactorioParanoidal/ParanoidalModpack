require("__automated-utility-protocol__.util.main")
require("__automated-utility-protocol__.util.technology-tree-cache-util")
require("__automated-utility-protocol__.util.technology-tree-util")
local TechnologyLeafFinder = require("prototypes.final-fixes.leaf.finder.technology-leaf-finder")
local TechnologyLeafHandler = require("prototypes.final-fixes.leaf.handler.technology-leaf-handler")

local GameModeUtil = {}

local function handle_game_mode_data(mode)
	TechnologyTreeCacheUtil.init_technology_tree_cache(mode)
	local leafTechologies = TechnologyLeafFinder.get_leaf_technologies_for_resetting_dependenies(mode)
	TechnologyLeafHandler.handle_leaf_techonologies(leafTechologies, mode)
	TechnologyTreeCacheUtil.cleanup_technology_tree_cache(mode)
end

GameModeUtil.handle_game_mode_datas = function()
	_table.each(GAME_MODES, handle_game_mode_data)
end

return GameModeUtil

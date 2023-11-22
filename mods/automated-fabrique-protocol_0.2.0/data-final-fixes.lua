flib = require("__flib__.data-util")
require("prototypes.final-fixes.tree.technology-tree-cache-util")
techUtil = require("prototypes.final-fixes.technology-util")
recipeUtil = require("prototypes.final-fixes.recipe-util")
require("prototypes.final-fixes.tree.technology-tree-util")
require("prototypes.final-fixes.before-apply-final-fixes")
local GameModeUtil = require("prototypes.final-fixes.game-mode-util")
GameModeUtil.handle_game_mode_datas()
GameModeUtil = nil
TechnologyTreeUtil = nil
recipeUtil = nil
techUtil = nil
flib = nil

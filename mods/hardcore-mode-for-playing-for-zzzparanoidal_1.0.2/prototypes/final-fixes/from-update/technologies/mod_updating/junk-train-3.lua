local techUtil = require("__automated-utility-protocol__.util.technology-util")

local function updateJunkTrain3Mod(mode)
	-- железнодорожные сигналы теперь зависят от простейшей автоматики, так же, как и железные дороги.
	if not mods["JunkTrain3"] then
		return
	end
	local technologies = data.raw["technology"]
	techUtil.resetTechnologyPrerequisites(technologies["fluid-wagon"], { "JunkTrain_tech", "fluid-handling" }, mode)
	techUtil.addPrerequisitesToTechnology(technologies["rail-signals"], { "automated-scrap-rail-transportation" }, mode)
	techUtil.addPrerequisitesToTechnology(technologies["railway"], { "automated-scrap-rail-transportation" }, mode)
end
_table.each(GAME_MODES, function(mode)
	updateJunkTrain3Mod(mode)
end)

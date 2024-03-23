local techUtil = require("__automated-utility-protocol__.util.technology-util")

local function update_junk_train3_mod(mode)
	-- железнодорожные сигналы теперь зависят от простейшей автоматики, так же, как и железные дороги.
	if not mods["JunkTrain3"] then
		return
	end
	local technologies = data.raw["technology"]
	techUtil.reset_prerequisites_for_technology(
		technologies["fluid-wagon"],
		{ "JunkTrain_tech", "fluid-handling" },
		mode
	)
	techUtil.add_prerequisites_to_technology(
		technologies["rail-signals"],
		{ "automated-scrap-rail-transportation" },
		mode
	)
	techUtil.add_prerequisites_to_technology(technologies["railway"], { "automated-scrap-rail-transportation" }, mode)
end
_table.each(GAME_MODES, function(mode)
	update_junk_train3_mod(mode)
end)

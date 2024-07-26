local tech_util = require("__automated-utility-protocol__.util.technology-util")

local function update_junk_train3_mod(mode)
    -- железнодорожные сигналы теперь зависят от простейшей автоматики, так же, как и железные дороги.
    if not mods["JunkTrain3"] then
        return
    end

    tech_util.reset_prerequisites_for_technology(
        "fluid-wagon",
        { "JunkTrain_tech", "fluid-handling" },
        mode
    )
    tech_util.add_prerequisites_to_technology(
        "rail-signals",
        { "automated-scrap-rail-transportation" },
        mode
    )
    tech_util.add_prerequisites_to_technology("railway", { "automated-scrap-rail-transportation" }, mode)
end
_table.each(GAME_MODES, function(mode)
    update_junk_train3_mod(mode)
end)

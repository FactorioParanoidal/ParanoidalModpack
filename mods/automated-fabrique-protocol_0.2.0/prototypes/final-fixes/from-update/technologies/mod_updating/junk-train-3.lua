local function updateJunkTrain3Mod(technologies, mode)
    -- железнодорожные сигналы теперь зависят от простейшей автоматики, так же, как и железные дороги.
    if not mods["JunkTrain3"] then return end
    techUtil.resetTechnologyPrerequisites(technologies["fluid-wagon"], { "JunkTrain_tech", "fluid-handling" }, mode)
    techUtil.addPrerequisitesToTechnology(technologies["rail-signals"], { "automated-scrap-rail-transportation" },
        mode)
    techUtil.addPrerequisitesToTechnology(technologies["railway"], { "automated-scrap-rail-transportation" }, mode)
end

local technologies = data.raw["technology"]
updateJunkTrain3Mod(technologies, "normal")
updateJunkTrain3Mod(technologies, "expensive")

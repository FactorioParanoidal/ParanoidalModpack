local ROBO_RECIPES = {"equipment-bot-chip-launcher"}
for _, force in pairs(game.forces) do
    if force.technologies["personal-roboport-equipment"] and force.technologies["personal-roboport-equipment"].researched then
        for _, recipe in pairs(ROBO_RECIPES) do
            if force.recipes[recipe] then force.recipes[recipe].enabled=true end
        end
    end
end

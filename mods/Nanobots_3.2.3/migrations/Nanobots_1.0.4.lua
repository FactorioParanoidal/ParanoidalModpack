local AC_RECIPES = {"ammo-nano-deconstructors", "ammo-nano-scrappers", "ammo-nano-termites"}
for _, force in pairs(game.forces) do
    if force.technologies["automated-construction"] and force.technologies["automated-construction"].researched then
        for _, recipe in pairs(AC_RECIPES) do
            if force.recipes[recipe] then force.recipes[recipe].enabled=true end
        end
    end
end

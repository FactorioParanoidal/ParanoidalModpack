-- Открыть восстановленные рецепты, если соответствующие исследования уже выполнены.
-- Новые платиновые исследования не выдаются; исследовательская очередь и другие рецепты не меняются.
local restored = {
    { "advanced-magnesium-smelting", "clowns-molten-magnesium-smelting" },
    { "advanced-magnesium-smelting", "clowns-plate-magnesium" },
    { "bi-tech-coal-processing-2", "bi-pellet-coke-2" },
}
for _, force in pairs(game.forces) do
    for _, entry in ipairs(restored) do
        local technology, recipe = force.technologies[entry[1]], force.recipes[entry[2]]
        if technology and technology.researched and recipe then recipe.enabled = true end
    end
end

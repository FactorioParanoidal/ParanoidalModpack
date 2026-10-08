-- Сохраняем ранее полученный доступ к шести перенесённым рецептам химии.
-- Исторический список этой версии; исследования и уже включённые рецепты не сбрасываем.
local moves = {
    { "bi-mineralized-sulfuric-waste", "angels-water-treatment", "angels-advanced-chemistry-5" },
    { "bob-zinc-electrolysis-x", "angels-basic-chemistry-2", "angels-ore-floatation" },
    { "angels-solid-tetrasodium-pyrophosphate", "phosphorus-processing-1", "phosphorus-processing-2" },
    { "clowns-diammonium-phosphate-fertilizer", "phosphorus-processing-1", "angels-bio-farm-2" },
    { "vinyl-acetlyene-chlorination", "angels-chlorine-processing-2", "angels-advanced-chemistry-3" },
    { "vinyl-chloride-synthesis", "angels-chlorine-processing-2", "angels-advanced-chemistry-3" },
}
for _, force in pairs(game.forces) do
    for _, move in ipairs(moves) do
        local recipe = force.recipes[move[1]]
        local old, target = force.technologies[move[2]], force.technologies[move[3]]
        if recipe and ((old and old.researched) or (target and target.researched)) then
            recipe.enabled = true
        end
    end
end

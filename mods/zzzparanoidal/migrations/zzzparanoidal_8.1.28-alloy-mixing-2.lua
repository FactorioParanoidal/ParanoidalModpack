-- Issue #401, вторая партия: новые рецепты смешивания в уже изученных технологиях смесителя.
-- Фиксированный список: не зависит от будущих data-stage изменений.
local unlocks = {
    { "molten-sicu-aluminium-alloy-mixing", "remelting-alloy-mixer-3" },
    { "molten-nickel-titanium-alloy-mixing", "remelting-alloy-mixer-3" },
    { "molten-brass-alloy-mixing-4", "remelting-alloy-mixer-3" },
    { "molten-alsn-titanium-alloy-mixing", "remelting-alloy-mixer-4" },
}
for _, force in pairs(game.forces) do
    for _, entry in ipairs(unlocks) do
        local recipe = force.recipes[entry[1]]
        local technology = force.technologies[entry[2]]
        if recipe and technology and technology.researched then
            recipe.enabled = true
        end
    end
end

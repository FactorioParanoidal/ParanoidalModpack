-- Issue #401: доступ к перенесённым и новым рецептам расплавов в уже изученных технологиях.
-- Фиксированный список этой версии: не зависит от будущих data-stage изменений.
local unlocks = {
    { "molten-manganese-remelting", "angels-manganese-smelting-1" },
    { "molten-chrome-remelting", "angels-chrome-smelting-1" },
    { "molten-manganese-iron-alloy-mixing", "remelting-alloy-mixer-1" },
    { "molten-silicon-iron-alloy-mixing", "remelting-alloy-mixer-1" },
    { "molten-coni-iron-alloy-mixing", "remelting-alloy-mixer-2" },
    { "molten-manganese-aluminium-alloy-mixing", "remelting-alloy-mixer-2" },
    { "molten-cobalt-steel-alloy-mixing-1", "remelting-alloy-mixer-2" },
    { "molten-crni-iron-alloy-mixing", "remelting-alloy-mixer-3" },
    { "molten-manganese-titanium-alloy-mixing", "remelting-alloy-mixer-3" },
    { "molten-nitinol-alloy-mixing-1", "remelting-alloy-mixer-3" },
    { "molten-steel-alloy-mixing-4", "remelting-alloy-mixer-3" },
    { "molten-cocr-titanium-alloy-mixing", "remelting-alloy-mixer-4" },
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

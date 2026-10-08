-- Сохраняем прежний доступ после переноса поздних открытий; исследования не сбрасываем.
-- Список зафиксирован для этой версии и не зависит от будущего data-stage патча.
local moves = {
    { "angels-bio-puffer-2", "angels-bio-refugium-hatchery", "angels-bio-refugium-puffer-2" },
    { "angels-bio-puffer-3", "angels-bio-refugium-hatchery", "angels-bio-refugium-puffer-3" },
    { "angels-bio-puffer-4", "angels-bio-refugium-hatchery", "angels-bio-refugium-puffer-3" },
    { "angels-bio-puffer-5", "angels-bio-refugium-hatchery", "angels-bio-refugium-puffer-3" },
    { "angels-wire-coil-insulated-casting-fast", "angels-rubber", "angels-strand-casting-3" },
    { "molten-bronze-alloy-mixing-3", "angels-bronze-smelting-3", "remelting-alloy-mixer-3" },
    { "angels-nuclear-fuel-2", "angels-nuclear-fuel", "thorium-nuclear-fuel-reprocessing-2" },
    { "angels-nuclear-fuel-2", "angels-thorium-power", "thorium-nuclear-fuel-reprocessing-2" },
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

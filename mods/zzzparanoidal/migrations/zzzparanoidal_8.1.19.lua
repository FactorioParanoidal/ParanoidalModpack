-- Только сохранение доступа к перенесённым рецептам. Удалённые рецепты не восстанавливаем.
-- Фиксированный список этой версии: не зависит от будущих data-stage изменений.
local moves = {
    { "lighted-bi-wooden-pole-huge", "lamp", "electric-energy-distribution-2" },
    { "bi-large-substation", "electric-energy-distribution-2", "bob-electric-substation-3" },
    { "lighted-bi-large-substation", "electric-energy-distribution-2", "bob-electric-substation-3" },
    { "molten-bronze-alloy-mixing-1", "angels-bronze-smelting-1", "remelting-alloy-mixer-1" },
    { "molten-steel-alloy-mixing", "angels-steel-smelting-1", "remelting-alloy-mixer-1" },
    { "molten-solder-alloy-mixing-1", "angels-solder-smelting-1", "remelting-alloy-mixer-1" },
    { "molten-bronze-alloy-mixing-2", "angels-bronze-smelting-2", "remelting-alloy-mixer-2" },
    { "molten-solder-alloy-mixing-2", "angels-solder-smelting-2", "remelting-alloy-mixer-2" },
    { "molten-steel-alloy-mixing-2", "angels-steel-smelting-2", "remelting-alloy-mixer-2" },
    { "molten-brass-alloy-mixing-2", "angels-brass-smelting-2", "remelting-alloy-mixer-2" },
    { "molten-steel-alloy-mixing-cobalt-nickel", "angels-steel-smelting-3", "angels-cobalt-smelting-2" },
    { "angels-powder-steel", "angels-steel-smelting-2", "angels-powder-metallurgy-3" },
    { "angels-plate-brass", "angels-brass-smelting-1", "angels-zinc-smelting-1" },
    { "angels-brass-pipe-casting", "angels-brass-smelting-1", "angels-zinc-smelting-1" },
    { "angels-brass-pipe-to-ground-casting", "angels-brass-smelting-1", "angels-zinc-smelting-1" },
    { "angels-cobalt-steel-gear-wheel-casting", "angels-ironworks-2", "angels-cobalt-steel-smelting-1" },
    { "angels-brass-gear-wheel-casting", "angels-ironworks-2", "angels-brass-smelting-2" },
    { "ASE-sand-die", "angels-ironworks-2", "angels-powder-metallurgy-4" },
    { "ASE-iron-gear-casting-expendable", "angels-ironworks-2", "angels-powder-metallurgy-4" },
    { "ASE-steel-gear-casting-expendable", "angels-ironworks-3", "angels-powder-metallurgy-4" },
    { "ASE-brass-gear-casting-expendable", "angels-ironworks-3", "angels-ironworks-4" },
    { "ASE-cobalt-steel-gear-casting-expendable", "angels-ironworks-3", "angels-ironworks-4" },
    { "ASE-metal-die", "angels-ironworks-3", "angels-ironworks-4" },
    { "ASE-metal-die-wash", "angels-ironworks-3", "angels-ironworks-4" },
    { "ASE-iron-gear-casting-advanced", "angels-ironworks-3", "angels-ironworks-4" },
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

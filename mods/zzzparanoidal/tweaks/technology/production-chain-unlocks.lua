-- После OV.execute и всех восстановлений дерева. Меняем только открытия и предков.
-- Базовая плавка остаётся ранней; поздние альтернативы требуют своего оборудования.
local moves = {
    -- Большой освещённый столб остаётся у фонаря; гигантский следует за обычным.
    -- Фонарь уже среди предков электроснабжения; подстанции следуют за Bob III.
    { "lighted-bi-wooden-pole-huge", "lamp", "electric-energy-distribution-2" },
    { "bi-large-substation", "electric-energy-distribution-2", "bob-electric-substation-3" },
    { "lighted-bi-large-substation", "electric-energy-distribution-2", "bob-electric-substation-3" },
    -- Смешивание I/II открывается вместе со смешивателем, не задерживая обычную плавку.
    { "molten-bronze-alloy-mixing-1", "angels-bronze-smelting-1", "remelting-alloy-mixer-1" },
    { "molten-steel-alloy-mixing", "angels-steel-smelting-1", "remelting-alloy-mixer-1" },
    { "molten-solder-alloy-mixing-1", "angels-solder-smelting-1", "remelting-alloy-mixer-1" },
    { "molten-bronze-alloy-mixing-2", "angels-bronze-smelting-2", "remelting-alloy-mixer-2" },
    { "molten-solder-alloy-mixing-2", "angels-solder-smelting-2", "remelting-alloy-mixer-2" },
    { "molten-steel-alloy-mixing-2", "angels-steel-smelting-2", "remelting-alloy-mixer-2" },
    { "molten-brass-alloy-mixing-2", "angels-brass-smelting-2", "remelting-alloy-mixer-2" },
    { "molten-steel-alloy-mixing-cobalt-nickel", "angels-steel-smelting-3", "angels-cobalt-smelting-2" },
    -- Порошок и латунное литьё: действующие источники машины и расплава.
    { "angels-powder-steel", "angels-steel-smelting-2", "angels-powder-metallurgy-3" },
    { "angels-plate-brass", "angels-brass-smelting-1", "angels-zinc-smelting-1" },
    { "angels-brass-pipe-casting", "angels-brass-smelting-1", "angels-zinc-smelting-1" },
    { "angels-brass-pipe-to-ground-casting", "angels-brass-smelting-1", "angels-zinc-smelting-1" },
    { "angels-cobalt-steel-gear-wheel-casting", "angels-ironworks-2", "angels-cobalt-steel-smelting-1" },
    { "angels-brass-gear-wheel-casting", "angels-ironworks-2", "angels-brass-smelting-2" },
    -- Песчаные формы — с первой доступной печью спекания; металлические — с оксидом цинка.
    { "ASE-sand-die", "angels-ironworks-2", "angels-powder-metallurgy-4" },
    { "ASE-iron-gear-casting-expendable", "angels-ironworks-2", "angels-powder-metallurgy-4" },
    { "ASE-steel-gear-casting-expendable", "angels-ironworks-3", "angels-powder-metallurgy-4" },
    { "ASE-brass-gear-casting-expendable", "angels-ironworks-3", "angels-ironworks-4" },
    { "ASE-cobalt-steel-gear-casting-expendable", "angels-ironworks-3", "angels-ironworks-4" },
    { "ASE-metal-die", "angels-ironworks-3", "angels-ironworks-4" },
    { "ASE-metal-die-wash", "angels-ironworks-3", "angels-ironworks-4" },
    { "ASE-iron-gear-casting-advanced", "angels-ironworks-3", "angels-ironworks-4" },
}
for _, move in ipairs(moves) do
    local recipe, old, target = data.raw.recipe[move[1]], data.raw.technology[move[2]], data.raw.technology[move[3]]
    if recipe and old and target then
        for index = #(old.effects or {}), 1, -1 do
            local effect = old.effects[index]
            if effect.type == "unlock-recipe" and effect.recipe == move[1] then
                table.remove(old.effects, index)
            end
        end
        target.effects = target.effects or {}
        local found = false
        for _, effect in ipairs(target.effects) do
            if effect.type == "unlock-recipe" and effect.recipe == move[1] then found = true end
        end
        if not found then
            table.insert(target.effects, { type = "unlock-recipe", recipe = move[1] })
        end
    end
end

local prerequisites = {
    { "bob-electronics-machine-1", "angels-bronze-smelting-1" },
    { "bob-electronics-machine-1", "electronics" },
    -- Источники никеля и цинка для смешивания II; красные сплавы уже есть у смешивателя I.
    { "remelting-alloy-mixer-2", "angels-bronze-smelting-2" },
    { "remelting-alloy-mixer-2", "angels-solder-smelting-2" },
    { "remelting-alloy-mixer-2", "angels-brass-smelting-2" },
    { "angels-cobalt-smelting-2", "angels-steel-smelting-3" },
    { "angels-cobalt-smelting-2", "remelting-alloy-mixer-2" },
    { "angels-bronze-smelting-2", "angels-strand-casting-1" },
    { "angels-brass-smelting-2", "angels-zinc-smelting-2" },
    { "angels-powder-metallurgy-3", "angels-steel-smelting-2" },
    { "angels-powder-metallurgy-4", "angels-ironworks-2" },
    { "angels-ironworks-4", "angels-zinc-smelting-3" },
    { "angels-ironworks-4", "angels-cobalt-steel-smelting-1" },
    -- Обычные рулоны требуют МНЛЗ I, не IV, и каждый из трёх расплавов.
    { "angels-alloys-smelting-2", "angels-strand-casting-1" },
    { "angels-alloys-smelting-2", "angels-invar-smelting-1" },
    { "angels-alloys-smelting-2", "angels-cobalt-steel-smelting-1" },
    { "angels-alloys-smelting-2", "angels-gunmetal-smelting-1" },
}
for _, link in ipairs(prerequisites) do
    local technology, parent = data.raw.technology[link[1]], data.raw.technology[link[2]]
    if technology and parent then
        technology.prerequisites = technology.prerequisites or {}
        local found = false
        for _, name in ipairs(technology.prerequisites) do
            if name == link[2] then found = true end
        end
        if not found then table.insert(technology.prerequisites, link[2]) end
    end
end

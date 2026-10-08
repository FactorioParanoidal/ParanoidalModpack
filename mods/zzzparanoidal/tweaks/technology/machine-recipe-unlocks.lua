-- После восстановления дерева: поздние альтернативы не задерживают базовое производство.
-- Рецепты, категории, стоимости и вероятности не меняются.
local moves = {
    { "angels-bio-puffer-2", "angels-bio-refugium-hatchery", "angels-bio-refugium-puffer-2" },
    { "angels-bio-puffer-3", "angels-bio-refugium-hatchery", "angels-bio-refugium-puffer-3" },
    { "angels-bio-puffer-4", "angels-bio-refugium-hatchery", "angels-bio-refugium-puffer-3" },
    { "angels-bio-puffer-5", "angels-bio-refugium-hatchery", "angels-bio-refugium-puffer-3" },
    { "angels-wire-coil-insulated-casting-fast", "angels-rubber", "angels-strand-casting-3" },
    { "molten-bronze-alloy-mixing-3", "angels-bronze-smelting-3", "remelting-alloy-mixer-3" },
    { "angels-nuclear-fuel-2", "angels-nuclear-fuel", "thorium-nuclear-fuel-reprocessing-2" },
    -- Действующая ветка; angels-nuclear-fuel выше — отключённый дубликат.
    { "angels-nuclear-fuel-2", "angels-thorium-power", "thorium-nuclear-fuel-reprocessing-2" },
}
for _, move in ipairs(moves) do
    local recipe, old, target = move[1], data.raw.technology[move[2]], data.raw.technology[move[3]]
    if data.raw.recipe[recipe] and old and target then
        for i = #(old.effects or {}), 1, -1 do
            local effect = old.effects[i]
            if effect.type == "unlock-recipe" and effect.recipe == recipe then
                table.remove(old.effects, i)
            end
        end
        target.effects = target.effects or {}
        local found = false
        for _, effect in ipairs(target.effects) do
            if effect.type == "unlock-recipe" and effect.recipe == recipe then found = true end
        end
        if not found then
            table.insert(target.effects, { type = "unlock-recipe", recipe = recipe })
        end
    end
end

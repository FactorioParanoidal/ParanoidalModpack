-- Только согласованные повторы: ранний источник уже среди предков позднего.
-- Независимые ветки, отключённые технологии и служебный реестр MU не трогаем.
-- Столбцы: рецепт, лишнее открытие, сохраняемый источник (nil = рецепт со старта).
local removals = {
    { "angels-catalyst-metal-carrier", "angels-basic-chemistry-3", "angels-basic-chemistry-2" },
    { "angels-catalyst-metal-red", "angels-basic-chemistry-3", "angels-basic-chemistry-2" },
    { "angels-catalyst-metal-yellow", "angels-advanced-chemistry-5", "angels-advanced-chemistry-4" },
    { "angels-liquid-phenol", "angels-advanced-chemistry-5", "k-angels-advanced-chemistry-5" },
    { "bob-copper-tungsten-pipe", "bob-tungsten-processing", "angels-copper-tungsten-smelting-1" },
    { "bob-copper-tungsten-pipe-to-ground", "bob-tungsten-processing", "angels-copper-tungsten-smelting-1" },
    { "bob-copper-tungsten-pipe", "tungsten-alloy-processing", "angels-copper-tungsten-smelting-1" },
    { "bob-copper-tungsten-pipe-to-ground", "tungsten-alloy-processing", "angels-copper-tungsten-smelting-1" },
    { "bob-tungsten-carbide-x", "tungsten-alloy-processing", "bob-tungsten-processing" },
    { "hs_holo_sign", "circuit-network", "lamp" },
    { "copper-nickel-firearm-magazine", "angels-lead-smelting-1" },
    { "glass-from-ore4", "angels-ore-crushing" },
}

local function unlocks(technology, recipe)
    for _, effect in ipairs(technology and technology.effects or {}) do
        if effect.type == "unlock-recipe" and effect.recipe == recipe then return true end
    end
    return false
end

for _, entry in ipairs(removals) do
    local recipe = data.raw.recipe[entry[1]]
    local technology = data.raw.technology[entry[2]]
    -- Не удалять доступ, если в другой конфигурации сохраняемый источник отсутствует.
    local retained = entry[3] and unlocks(data.raw.technology[entry[3]], entry[1])
        or (not entry[3] and recipe and recipe.enabled ~= false)
    if recipe and technology and retained then
        for index = #(technology.effects or {}), 1, -1 do
            local effect = technology.effects[index]
            if effect.type == "unlock-recipe" and effect.recipe == entry[1] then
                table.remove(technology.effects, index)
            end
        end
    end
end

-- После OV и позднего восстановления дерева: только открытия, без изменения рецептур.
local moves = {
    -- Только химзавод III поддерживает этот рецепт; древесный уголь обеспечен предком ниже.
    { "bi-mineralized-sulfuric-waste", "angels-water-treatment", "angels-advanced-chemistry-5" },
    -- Флотация даёт руду до ранней латуни; перенос в плавку цинка I задерживал бы синюю науку.
    { "bob-zinc-electrolysis-x", "angels-basic-chemistry-2", "angels-ore-floatation" },
    -- Не задерживаем весь ранний фосфор и азот из-за отдельных альтернатив.
    { "angels-solid-tetrasodium-pyrophosphate", "phosphorus-processing-1", "phosphorus-processing-2" },
    { "clowns-diammonium-phosphate-fertilizer", "phosphorus-processing-1", "angels-bio-farm-2" },
    -- Химия II ещё не обеспечивает синий катализатор и полную цепочку винилацетилена.
    { "vinyl-acetlyene-chlorination", "angels-chlorine-processing-2", "angels-advanced-chemistry-3" },
    { "vinyl-chloride-synthesis", "angels-chlorine-processing-2", "angels-advanced-chemistry-3" },
}
for _, move in ipairs(moves) do
    local recipe = data.raw.recipe[move[1]]
    local old, target = data.raw.technology[move[2]], data.raw.technology[move[3]]
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

local chemistry = data.raw.technology["angels-advanced-chemistry-5"]
local charcoal = "bi-tech-coal-processing-1"
if data.raw.recipe["bi-mineralized-sulfuric-waste"] and chemistry and data.raw.technology[charcoal] then
    chemistry.prerequisites = chemistry.prerequisites or {}
    local found = false
    for _, name in ipairs(chemistry.prerequisites) do
        if name == charcoal then found = true end
    end
    if not found then table.insert(chemistry.prerequisites, charcoal) end
end

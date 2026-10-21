-- Паровой манипулятор больше не изготавливается. Предмет и существующие сущности сохраняются.
local name = "bob-steam-inserter"
for _, technology in pairs(data.raw.technology) do
    for index = #(technology.effects or {}), 1, -1 do
        local effect = technology.effects[index]
        if effect.type == "unlock-recipe" and effect.recipe == name then
            table.remove(technology.effects, index)
        end
    end
end
data.raw.recipe[name] = nil

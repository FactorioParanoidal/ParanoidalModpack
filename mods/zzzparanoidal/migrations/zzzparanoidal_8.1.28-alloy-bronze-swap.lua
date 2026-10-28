-- «Примитивное сплавление бронзы» переехало в «Изготовление сплавов»: сохраняем доступ.
-- Ничего не отбираем: включаем, если изучена старая или новая технология.
for _, force in pairs(game.forces) do
    local recipe = force.recipes["bronze-alloy-x"]
    local old, new = force.technologies["angels-bronze-smelting-1"], force.technologies["bob-alloy-processing"]
    if recipe and ((old and old.researched) or (new and new.researched)) then
        recipe.enabled = true
    end
end

-- Сортировка II требует стандартных каркасов, а их латунь — цинка из концентратов.
-- Только шесть концентратов доступны на I; катализация и порошки остаются на II.
-- Категория первого уровня уже поддерживается всеми тирами сортировочных комбинатов.
for tier = 1, 6 do
    local recipe = data.raw.recipe["angels-ore" .. tier .. "-chunk-processing"]
    if recipe and bobmods.lib.recipe.get_category(recipe) == "angels-ore-sorting-2" then -- Factorio 2.1: categories[1]
        bobmods.lib.recipe.set_main_category(recipe, "angels-ore-sorting")
    end
end

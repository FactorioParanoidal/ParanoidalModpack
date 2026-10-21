-- Blueprint Sandboxes: копии лоадеров только для песочницы держим на её вкладке.
-- Иначе они наследуют ряд предмета и дублируют настоящие лоадеры Bob/AAI в меню.
-- Только подгруппа рецептов; предметы и настоящие рецепты не трогаются.
if not mods["blueprint-sandboxes"] or not data.raw["item-subgroup"]["bpsb-loaders"] then
    return
end

for index, name in ipairs({"loader", "fast-loader", "express-loader", "turbo-loader"}) do
    local recipe = data.raw.recipe["bpsb-" .. name]
    if recipe then
        recipe.subgroup = "bpsb-loaders"
        recipe.order = "a-" .. string.char(string.byte("a") + index - 1)
    end
end

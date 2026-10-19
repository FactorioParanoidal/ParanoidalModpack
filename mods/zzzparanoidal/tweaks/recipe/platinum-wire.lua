-- После modules-beta8 и OV.execute: согласованные потребители платиновой проволоки.
-- Остальные ингредиенты, выход и параметры рецептов сохраняются.
local recipe = paralib.bobmods.lib.recipe

recipe.remove_ingredient("bob-module-processor-board-3", "copper-plate")
for _, name in ipairs({ "bob-module-processor-board-3", "bob-advanced-processing-unit" }) do
	recipe.set_ingredient(name, { type = "item", name = "angels-wire-platinum", amount = 8 })
end

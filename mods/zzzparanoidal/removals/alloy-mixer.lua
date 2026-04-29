require("__zzzparanoidal__.paralib")
-- Удаление мёртвой ветки alloy-mixer (МК1-МК4) из angelsextended-remelting-fixed.
-- В 1.1 эта линия была единственным способом получить сплавы (бронза/латунь/инвар/гунметал/кобальт-сталь/нитинол).
-- В 2.0 angelssmelting сам делает все эти сплавы (категории angels-induction-smelting-2/3/4)
-- через обычные angels-induction-furnace, поэтому отдельная ветка alloy-mixer стала избыточной.
-- Сохраняем рецепты molten-X-remelting (категория angels-induction-smelting) — они
-- работают в induction-furnace и нужны для переплавки bob-сплавов в жидкий вид.

-- Прячем 4 техи "Продвинутое смешивание металлов 1-4"
for i = 1, 4 do
	paralib.bobmods.lib.tech.hide("remelting-alloy-mixer-" .. i)
end

-- Прячем 4 здания "Смешиватель Металлов МК1-МК4" (рецепт + предмет)
local mixer_names = { "alloy-mixer", "alloy-mixer-2", "alloy-mixer-3", "alloy-mixer-4" }
for _, name in ipairs(mixer_names) do
	paralib.bobmods.lib.recipe.hide(name)
	if data.raw.item[name] then
		data.raw.item[name].hidden = true
	end
end

-- Прячем все рецепты категории molten-alloy-mixing (рецепты этих зданий)
for name, recipe in pairs(data.raw.recipe) do
	if recipe.category == "molten-alloy-mixing" then
		paralib.bobmods.lib.recipe.hide(name)
	end
end

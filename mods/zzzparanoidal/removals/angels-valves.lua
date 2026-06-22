require("__zzzparanoidal__.paralib")
-- angelspetrochem определяет клапаны angels-valve-one-way/overflow/top-up (тип "valve"),
-- дублирующие one-way/overflow/top-up из мода valves. Прячем их рецепты — этого хватает,
-- чтобы убрать из меню крафта (recipe.hide безопасен и при отсутствии имени: paralib и
-- boblib только пишут в лог). angels-valve-inspector НЕ трогаем — у него нет аналога в
-- valves. Построенные клапаны переезжают в valves-* через migrations/zzzparanoidal_8.1.6.json.

if mods["angelspetrochem"] and mods["valves"] then
	paralib.bobmods.lib.recipe.hide("angels-valve-one-way")
	paralib.bobmods.lib.recipe.hide("angels-valve-overflow")
	paralib.bobmods.lib.recipe.hide("angels-valve-top-up")
end

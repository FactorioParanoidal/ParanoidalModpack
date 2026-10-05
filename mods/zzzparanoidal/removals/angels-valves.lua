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

	-- Скрытый рецепт не скрывает страницы предмета и постройки в Факторипедии.
	-- Сами прототипы и их поведение сохраняем для существующих сейвов.
	for _, name in ipairs({ "angels-valve-one-way", "angels-valve-overflow", "angels-valve-top-up" }) do
		for _, prototype_type in ipairs({ "item", "valve" }) do
			local prototype = data.raw[prototype_type] and data.raw[prototype_type][name]
			if prototype then prototype.hidden_in_factoriopedia = true end
		end
	end

	-- Инспектор — в одну строку с тремя клапанами Valves, сразу после них.
	local inspector = data.raw.item["angels-valve-inspector"]
	local valves_item = data.raw.item["valves-one_way"]
	if inspector and valves_item and valves_item.subgroup then
		inspector.subgroup = valves_item.subgroup
		inspector.order = "b[pipe]-d[valves-zz-angels-inspector]"
	end
end

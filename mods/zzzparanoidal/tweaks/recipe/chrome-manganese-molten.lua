-- Расплав хрома и марганца (issue #401, решение пользователя 2026-10-20).
-- Angels скрывает их расплав: пластин хрома/марганца в сборке нет. Единственный путь —
-- переплавка из angelsextended-remelting-fixed — брал эти недоступные пластины, поэтому
-- сталь -3/-4 из смесителя была мёртвой (в Beta 8 тоже). Переплавку переводим на черновые
-- слитки в пропорции обычной плавки расплава (12 → 120 за 4 с) и открываем вместе со слитками.
-- Хром — в индукционной печи MK3, как кобальт/золото/титан на той же синей науке.
-- Цикла нет: обратного литья из этих расплавов нет (пластины/рулоны остаются отключены).
-- После OV.execute и меню литья (иконка рецепта и подгруппа задаются там).

local metals = {
	{ name = "manganese", category = "angels-induction-smelting", unlock = "angels-manganese-smelting-1", old = "angels-manganese-smelting-2" },
	{ name = "chrome", category = "angels-induction-smelting-3", unlock = "angels-chrome-smelting-1", old = "angels-chrome-smelting-2" },
}

local function remove_unlock(technology, recipe)
	local effects = technology and technology.effects
	if not effects then return end
	for index = #effects, 1, -1 do
		if effects[index].type == "unlock-recipe" and effects[index].recipe == recipe then
			table.remove(effects, index)
		end
	end
end

for _, metal in ipairs(metals) do
	local recipe_name = "molten-" .. metal.name .. "-remelting"
	local fluid_name = "angels-liquid-molten-" .. metal.name
	local recipe = data.raw.recipe[recipe_name]
	local fluid = data.raw.fluid[fluid_name]
	local technology = data.raw.technology[metal.unlock]
	if recipe and fluid and technology and data.raw.item["angels-ingot-" .. metal.name] then
		recipe.category = metal.category
		recipe.energy_required = 4
		recipe.ingredients = { { type = "item", name = "angels-ingot-" .. metal.name, amount = 12 } }
		recipe.results = { { type = "fluid", name = fluid_name, amount = 120 } }
		recipe.enabled = false
		recipe.hidden = nil

		remove_unlock(data.raw.technology[metal.old], recipe_name)
		remove_unlock(technology, recipe_name)
		technology.effects = technology.effects or {}
		table.insert(technology.effects, { type = "unlock-recipe", recipe = recipe_name })

		-- Жидкость видна и стоит рядом со своим рецептом в меню литья.
		fluid.hidden = nil
		fluid.hidden_in_factoriopedia = nil
		if recipe.subgroup and data.raw["item-subgroup"][recipe.subgroup] then
			fluid.subgroup = recipe.subgroup
			fluid.order = recipe.order
		end
	else
		log("[chrome-manganese-molten] skipped " .. metal.name)
	end
end

-- Beta 8: отдельные кобальт-стальные детали нужны для цены старших манипуляторов (ПР-033).
-- Angels 2.0 скрывает эти существующие прототипы и подменяет результаты латунью.
-- Восстанавливаем только детали/их открытие, не глобальные замены металлов и не металлургию.
if not mods["bobplates"] then return end
local technology = data.raw.technology["bob-cobalt-processing"]
if not technology or technology.max_level == "infinite"
	or not data.raw.technology["angels-cobalt-steel-smelting-1"]
	or not data.raw.item["bob-cobalt-steel-alloy"] then return end
local names = { "bob-cobalt-steel-gear-wheel", "bob-cobalt-steel-bearing-ball", "bob-cobalt-steel-bearing" }
for _, name in ipairs(names) do
	if not data.raw.recipe[name] or not data.raw.item[name] then return end
end
local amounts = { 1, 12, 2 }
for index, name in ipairs(names) do
	local recipe = data.raw.recipe[name]
	recipe.localised_name = { "item-name." .. name } -- ПР-036: нынешнее имя детали вместо служебной заглушки
	recipe.ingredients = { { type = "item", name = "bob-cobalt-steel-alloy", amount = 1 } }
	if index == 3 then
		table.insert(recipe.ingredients, { type = "item", name = "bob-cobalt-steel-bearing-ball", amount = 16 })
	end
	recipe.results = { { type = "item", name = name, amount = amounts[index] } }
	recipe.hidden = false
	recipe.enabled = false
	data.raw.item[name].hidden = false
end
technology.enabled = true
technology.hidden = false
technology.prerequisites = { "angels-cobalt-steel-smelting-1" }
technology.effects = technology.effects or {}
for _, name in ipairs(names) do
	local found = false
	for _, effect in ipairs(technology.effects) do
		if effect.type == "unlock-recipe" and effect.recipe == name then found = true end
	end
	if not found then table.insert(technology.effects, { type = "unlock-recipe", recipe = name }) end
end
-- Unit 80 x 30 с уже совпадает. Иконки и описания остаются прежними.

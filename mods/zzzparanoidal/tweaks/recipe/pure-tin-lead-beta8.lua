-- Beta 8 normal: чистая руда -> плиты, отдельно от дроблёной руды и выплавки слитков.
-- Angels_RBOS раскрывал эти два рецепта после smelting override: 4 -> 3 за 10.5 с.
-- ПР-028: вместо служебной angels-void используем названия пластин 2.0; иконки и печи не меняем.
for _, definition in ipairs({ { "tin", "i[angels-plate-tin]-b" }, { "lead", "k[angels-plate-lead]-b" } }) do
	local metal = definition[1]
	local recipe = data.raw.recipe["bob-" .. metal .. "-plate"]
	if recipe then
		recipe.ingredients = { { type = "item", name = "bob-" .. metal .. "-ore", amount = 4 } }
		recipe.results = { { type = "item", name = "bob-" .. metal .. "-plate", amount = 3 } }
		recipe.energy_required = 10.5
		recipe.enabled = false
		recipe.hidden = false
		recipe.subgroup = "angels-" .. metal .. "-casting"
		recipe.order = definition[2]
		recipe.localised_name = { "item-name.bob-" .. metal .. "-plate" }
		paralib.bobmods.lib.tech.add_recipe_unlock("angels-ore-crushing", recipe.name)
	end
end

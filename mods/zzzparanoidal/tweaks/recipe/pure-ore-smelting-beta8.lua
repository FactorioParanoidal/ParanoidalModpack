-- Beta 8 normal: Angels_RBOS раскрывал чисторудную плавку, отдельную от дроблёной руды.
-- Нынешние iron-plate/copper-plate уже заняты дроблёной цепью: используем существующие аналоги.
-- ПР-027: вместо служебной angels-void используем нынешние названия плит; иконки и печи не меняем.
for _, definition in ipairs({ { "iron", "l[angels-plate-iron]-b" }, { "copper", "j[angels-plate-copper]-b" } }) do
	local metal = definition[1]
	local recipe = data.raw.recipe["angels-" .. metal .. "-ore-smelting"]
	if recipe then
		recipe.ingredients = { { type = "item", name = metal .. "-ore", amount = 7 } }
		recipe.results = { { type = "item", name = metal .. "-plate", amount = 4 } }
		recipe.energy_required = 10.5
		recipe.enabled = true
		recipe.hidden = false
		recipe.subgroup = "angels-" .. metal .. "-casting"
		recipe.order = definition[2]
		recipe.localised_name = { "item-name." .. metal .. "-plate" }
	end
end

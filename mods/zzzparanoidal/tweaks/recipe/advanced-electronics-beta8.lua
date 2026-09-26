-- Beta 8 normal: два числовых расхождения четырёх открытий старшей электроники.
-- После OV.execute и добавок Kao: сохраняем категории/оформление/продуктивность 2.0.
local definitions = {
	["bob-processing-electronics"] = {
		{ type = "fluid", name = "sulfuric-acid", amount = 5 },
		{ type = "item", name = "bob-silicon-wafer", amount = 6 },
		{ type = "item", name = "bob-gilded-copper-cable", amount = 2 },
		{ type = "item", name = "bob-silicon-nitride", amount = 1 },
	},
	["bob-advanced-processing-unit"] = {
		{ type = "item", name = "bob-multi-layer-circuit-board", amount = 1 },
		{ type = "item", name = "bob-electronic-components", amount = 2 },
		{ type = "item", name = "bob-integrated-electronics", amount = 4 },
		{ type = "item", name = "bob-processing-electronics", amount = 1 },
		{ type = "item", name = "bob-solder", amount = 4 },
		{ type = "item", name = "advanced-io", amount = 2 },
		{ type = "item", name = "predictive-io", amount = 2 },
		{ type = "item", name = "condensator", amount = 92 },
		{ type = "item", name = "condensator2", amount = 40 },
		{ type = "item", name = "condensator3", amount = 28 },
	},
}
for name, ingredients in pairs(definitions) do
	local recipe = data.raw.recipe[name]
	local available = recipe ~= nil
	for _, ingredient in ipairs(ingredients) do
		available = available and data.raw[ingredient.type][ingredient.name] ~= nil
	end
	if available then recipe.ingredients = ingredients end
end

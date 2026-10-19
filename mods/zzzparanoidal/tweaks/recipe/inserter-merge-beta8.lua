-- ПР-033: слитые filter-манипуляторы используют обычную цену Beta 8 своего тира.
-- После OV.execute и прежних патчей. Фильтрация/характеристики/категории остаются 2.0.
if not mods["boblogistics"] then return end
local ingredients = {
	["long-handed-inserter"] = {
		{ type = "item", name = "inserter", amount = 1 },
		{ type = "item", name = "electronic-circuit", amount = 1 },
		{ type = "item", name = "bob-bronze-alloy", amount = 1 },
		{ type = "item", name = "bob-steel-gear-wheel", amount = 1 },
	},
	["fast-inserter"] = {
		{ type = "item", name = "long-handed-inserter", amount = 1 },
		{ type = "item", name = "advanced-circuit", amount = 1 },
		{ type = "item", name = "bob-aluminium-plate", amount = 1 },
		{ type = "item", name = "bob-titanium-bearing", amount = 1 },
		{ type = "item", name = "bob-titanium-gear-wheel", amount = 1 },
	},
	["bulk-inserter"] = {
		{ type = "item", name = "bob-red-bulk-inserter", amount = 1 },
		{ type = "item", name = "advanced-circuit", amount = 1 },
		{ type = "item", name = "bob-aluminium-plate", amount = 4 },
		{ type = "item", name = "bob-titanium-bearing", amount = 5 },
		{ type = "item", name = "bob-titanium-gear-wheel", amount = 6 },
	},
	["bob-turbo-inserter"] = {
		{ type = "item", name = "fast-inserter", amount = 1 },
		{ type = "item", name = "processing-unit", amount = 1 },
		{ type = "item", name = "bob-titanium-plate", amount = 1 },
		{ type = "item", name = "bob-cobalt-steel-bearing", amount = 1 },
		{ type = "item", name = "bob-cobalt-steel-gear-wheel", amount = 1 },
	},
	["bob-turbo-bulk-inserter"] = {
		{ type = "item", name = "bulk-inserter", amount = 1 },
		{ type = "item", name = "processing-unit", amount = 1 },
		{ type = "item", name = "bob-titanium-plate", amount = 4 },
		{ type = "item", name = "bob-cobalt-steel-bearing", amount = 6 },
		{ type = "item", name = "bob-cobalt-steel-gear-wheel", amount = 6 },
	},
}
for name, list in pairs(ingredients) do
	local recipe = data.raw.recipe[name]
	local available = recipe ~= nil
	for _, ingredient in ipairs(list) do available = available and data.raw.item[ingredient.name] ~= nil end
	if available then recipe.ingredients = list end
end

-- Только ингредиент-манипулятор доказанных потребителей, не остальные цены/механики.
local consumers = {
	["bob-lab-2"] = { "bob-turbo-bulk-inserter", 10 },
	["advanced-assembler"] = { "bob-express-bulk-inserter", 10 },
	["autonomous-space-mining-drone"] = { "bob-express-bulk-inserter", 100 },
	["orbital-fabricator-component"] = { "bob-express-bulk-inserter", 500 },
}
for name, replacement in pairs(consumers) do
	local recipe = data.raw.recipe[name]
	if recipe and data.raw.item[replacement[1]] then
		for _, ingredient in ipairs(recipe.ingredients or {}) do
			if (ingredient.type or "item") == "item" and (ingredient.name or ingredient[1]) == "bulk-inserter" then
				if ingredient.name then
					ingredient.name, ingredient.amount = replacement[1], replacement[2]
				else
					ingredient[1], ingredient[2] = replacement[1], replacement[2]
				end
			end
		end
	end
end

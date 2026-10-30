-- ПР-039: обычные цены и порядок ингредиентов Beta 8, без filter-наценки; варианты/свойства 2.0.
if not mods["nco-InserterCranes"] then
	return
end

local crane_ingredients = {
	["nco-crane"] = {
		{ type = "item", name = "bob-red-bulk-inserter", amount = 6 },
		{ type = "item", name = "advanced-circuit", amount = 6 },
		{ type = "item", name = "bob-aluminium-plate", amount = 22 },
		{ type = "item", name = "bob-titanium-gear-wheel", amount = 33 },
		{ type = "item", name = "bob-titanium-bearing", amount = 28 },
	},
	["nco-wide-crane"] = {
		{ type = "item", name = "bob-red-bulk-inserter", amount = 16 },
		{ type = "item", name = "advanced-circuit", amount = 16 },
		{ type = "item", name = "bob-aluminium-plate", amount = 64 },
		{ type = "item", name = "bob-titanium-gear-wheel", amount = 96 },
		{ type = "item", name = "bob-titanium-bearing", amount = 80 },
	},
	["nco-turbo-crane"] = {
		{ type = "item", name = "bulk-inserter", amount = 6 },
		{ type = "item", name = "processing-unit", amount = 6 },
		{ type = "item", name = "bob-titanium-plate", amount = 22 },
		{ type = "item", name = "bob-cobalt-steel-gear-wheel", amount = 33 },
		{ type = "item", name = "bob-cobalt-steel-bearing", amount = 33 },
	},
	["nco-wide-turbo-crane"] = {
		{ type = "item", name = "bulk-inserter", amount = 16 },
		{ type = "item", name = "processing-unit", amount = 16 },
		{ type = "item", name = "bob-titanium-plate", amount = 64 },
		{ type = "item", name = "bob-cobalt-steel-gear-wheel", amount = 96 },
		{ type = "item", name = "bob-cobalt-steel-bearing", amount = 96 },
	},
	["nco-express-crane"] = {
		-- В Beta 8 был 6x2 по цене широкого; теперь 2x2, цена широкого экспресса по шкале 5.5/16
		-- (решение пользователя 2026-10-31, как у узкого турбо).
		{ type = "item", name = "bob-turbo-bulk-inserter", amount = 6 },
		{ type = "item", name = "bob-nitinol-alloy", amount = 22 },
		{ type = "item", name = "bob-nitinol-bearing", amount = 33 },
		{ type = "item", name = "bob-nitinol-gear-wheel", amount = 33 },
		{ type = "item", name = "bob-advanced-processing-unit", amount = 6 },
	},
}

for recipe_name, ingredients in pairs(crane_ingredients) do
	local recipe = data.raw.recipe[recipe_name]
	if recipe then
		recipe.ingredients = ingredients
	end
end

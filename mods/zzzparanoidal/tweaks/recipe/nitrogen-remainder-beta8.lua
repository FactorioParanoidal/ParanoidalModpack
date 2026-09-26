-- Beta 8 normal: цены очистителей III–IV и газового НПЗ IV после OV.execute.
-- Современные категории, характеристики, оформление и способ открытия сохранены.
if not mods["angelspetrochem"] then return end
local ingredients = {
	["angels-air-filter-3"] = {
		{ type = "item", name = "angels-air-filter-2", amount = 1 },
		{ type = "item", name = "bob-aluminium-plate", amount = 16 },
		{ type = "item", name = "advanced-circuit", amount = 5 },
		{ type = "item", name = "concrete", amount = 25 },
		{ type = "item", name = "bob-brass-pipe", amount = 24 },
	},
	["angels-air-filter-4"] = {
		{ type = "item", name = "angels-air-filter-3", amount = 1 },
		{ type = "item", name = "bob-titanium-plate", amount = 16 },
		{ type = "item", name = "processing-unit", amount = 5 },
		{ type = "item", name = "refined-concrete", amount = 25 },
		{ type = "item", name = "bob-titanium-pipe", amount = 24 },
	},
	["angels-gas-refinery-4"] = {
		{ type = "item", name = "bob-copper-tungsten-alloy", amount = 40 },
		{ type = "item", name = "bob-advanced-processing-unit", amount = 5 },
		{ type = "item", name = "angels-titanium-concrete-brick", amount = 50 },
		{ type = "item", name = "bob-copper-tungsten-pipe", amount = 57 },
		{ type = "item", name = "advanced-structure-components", amount = 5 },
		{ type = "item", name = "angels-gas-refinery-3", amount = 2 },
	},
}
for name, list in pairs(ingredients) do
	local recipe = data.raw.recipe[name]
	local available = recipe ~= nil
	for _, ingredient in ipairs(list) do available = available and data.raw.item[ingredient.name] ~= nil end
	if available then recipe.ingredients = list end
end

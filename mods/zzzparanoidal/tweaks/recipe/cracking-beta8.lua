-- Beta 8 normal: крекинг-установка II требует обычный бетон, не бетонный кирпич Angels.
-- Категории, продуктивность, выходы и характеристики машин остаются 2.0.
local second = data.raw.recipe["angels-steam-cracker-2"]
if second then
	second.ingredients = {
		{ type = "item", name = "bob-aluminium-plate", amount = 8 },
		{ type = "item", name = "advanced-circuit", amount = 4 },
		{ type = "item", name = "concrete", amount = 20 },
		{ type = "item", name = "bob-brass-pipe", amount = 36 },
		{ type = "item", name = "intermediate-structure-components", amount = 2 },
		{ type = "item", name = "angels-steam-cracker", amount = 2 },
	}
end
-- Три переименованных рецепта сохраняют место старых операций в меню.
local orders = {
	["angels-gas-ethylene"] = "b[steam-cracking-ethane]",
	["angels-gas-propene"] = "e[gas-propene-synthesis]",
	["angels-gas-butadiene"] = "d[catalyst-steam-cracking-butane]",
}
for name, order in pairs(orders) do
	if data.raw.recipe[name] then data.raw.recipe[name].order = order end
end

-- Beta 8 normal: оставшиеся цены компонентов ракет и атомного артснаряда Bob.
-- Одноимённый atomic-artillery-shell из AtomicArtillery2 — другой нынешний рецепт.
if not mods["bobwarfare"] then return end
local ingredients = {
	["bob-rocket-engine"] = {
		{ type = "item", name = "tungsten-plate", amount = 1 },
		{ type = "item", name = "bob-tungsten-gear-wheel", amount = 1 },
	},
	["bob-rocket-body"] = {
		{ type = "item", name = "bob-rocket-engine", amount = 1 },
		{ type = "item", name = "processing-unit", amount = 1 },
		{ type = "fluid", name = "bob-liquid-fuel", amount = 10 },
		{ type = "item", name = "bob-aluminium-plate", amount = 1 },
	},
	["bob-atomic-artillery-shell"] = {
		{ type = "item", name = "steel-plate", amount = 6 },
		{ type = "item", name = "plastic-bar", amount = 6 },
		{ type = "item", name = "explosives", amount = 15 },
		{ type = "item", name = "uranium-235", amount = 30 },
	},
}
for name, list in pairs(ingredients) do
	local recipe = data.raw.recipe[name]
	local available = recipe ~= nil
	for _, ingredient in ipairs(list) do
		available = available and data.raw[ingredient.type][ingredient.name] ~= nil
	end
	if available then recipe.ingredients = list end
end

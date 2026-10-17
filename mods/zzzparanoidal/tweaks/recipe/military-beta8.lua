-- Beta 8 normal: рецепты открытий military I–III, без изменения оружия и категорий.
local ingredients = {
	["shotgun-shell"] = {
		{ type = "item", name = "copper-plate", amount = 10 },
		{ type = "item", name = "iron-plate", amount = 10 },
	},
	["piercing-rounds-magazine"] = {
		{ type = "item", name = "copper-plate", amount = 25 },
		{ type = "item", name = "steel-plate", amount = 1 },
	},
	["bob-rifle"] = {
		{ type = "item", name = "steel-plate", amount = 10 },
		{ type = "item", name = "bob-steel-gear-wheel", amount = 10 },
		{ type = "item", name = "bob-aluminium-plate", amount = 5 },
	},
	["bob-sniper-rifle"] = {
		{ type = "item", name = "steel-plate", amount = 10 },
		{ type = "item", name = "wood", amount = 10 },
		{ type = "item", name = "bob-glass", amount = 2 },
		{ type = "item", name = "bob-steel-gear-wheel", amount = 10 },
	},
}
for name, list in pairs(ingredients) do
	if data.raw.recipe[name] then data.raw.recipe[name].ingredients = list end
end
local piercing = data.raw.recipe["piercing-rounds-magazine"]
if piercing then
	piercing.energy_required = 3
	piercing.results = { { type = "item", name = "piercing-rounds-magazine", amount = 1 } }
end
if data.raw.recipe["light-armor"] and data.raw.technology["military"] then
	data.raw.recipe["light-armor"].enabled = false
end

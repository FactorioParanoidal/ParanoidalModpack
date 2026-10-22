-- Beta 8 normal: фиксированные урожаи, цена фермы, большой сад и две альтернативы сырья.
-- Категории, продуктивность, оформление и характеристики машин остаются 2.0.
if not mods["Bio_Industries_2"] then return end
local yields = {
	{ seed = 40, seedling = 40, wood = 40, pulp = 80 },
	{ seed = 50, seedling = 60, wood = 75, pulp = 150 },
	{ seed = 60, seedling = 90, wood = 135, pulp = 270 },
	{ seed = 80, seedling = 160, wood = 160, pulp = 320 },
}
for tier, amounts in ipairs(yields) do
	for _, kind in ipairs({ "seed", "seedling", "logs" }) do
		local recipe = data.raw.recipe["bi-" .. kind .. "-" .. tier]
		if recipe then
			if kind == "logs" then
				recipe.results = {
					{ type = "item", name = "wood", amount = amounts.wood },
					{ type = "item", name = "bi-woodpulp", amount = amounts.pulp },
				}
			else
				recipe.results = { { type = "item", name = kind == "seed" and "bi-seed" or "seedling", amount = amounts[kind] } }
			end
		end
	end
end
local ingredients = {
	["bi-bio-farm"] = {
		{ type = "item", name = "bi-bio-greenhouse", amount = 4 },
		{ type = "item", name = "stone-brick", amount = 8 },
		{ type = "item", name = "wood", amount = 12 },
		{ type = "item", name = "bob-glass", amount = 10 },
	},
	["bi-fertilizer-1"] = {
		{ type = "item", name = "sulfur", amount = 1 },
		{ type = "fluid", name = "angels-gas-nitrogen", amount = 10 },
		{ type = "item", name = "bi-ash", amount = 10 },
	},
	["bi-adv-fertilizer-1"] = {
		{ type = "item", name = "fertilizer", amount = 25 },
		{ type = "item", name = "bob-alien-artifact", amount = 5 },
	},
	["bi-bio-garden-large"] = {
		{ type = "item", name = "bi-bio-garden", amount = 10 },
		{ type = "item", name = "seedling", amount = 100 },
		{ type = "item", name = "refined-concrete", amount = 100 },
	},
	["bi-press-wood"] = {
		{ type = "item", name = "bi-woodpulp", amount = 7 },
		{ type = "item", name = "resin", amount = 1 },
	},
}
for name, list in pairs(ingredients) do
	local recipe = data.raw.recipe[name]
	if recipe then recipe.ingredients = list end
end
if data.raw.recipe["bi-press-wood"] then
	data.raw.recipe["bi-press-wood"].results = { { type = "item", name = "bob-wooden-board", amount = 2 } }
end

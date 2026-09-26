-- Beta 8 normal: стартовые дротики, кислород для биомассы и выход серы.
-- Категории, продуктивность и все характеристики машин/боеприпасов остаются 2.0.
if not mods["Bio_Industries_2"] then return end
for _, name in ipairs({ "bi-dart-turret", "bi-dart-rifle", "bi-dart-magazine-basic" }) do
	local recipe = data.raw.recipe[name]
	if recipe and data.raw.technology["bi-dart-turret"] then recipe.enabled = false end
end
if data.raw.fluid["angels-gas-oxygen"] then
	for tier = 2, 3 do
		local recipe = data.raw.recipe["bi-biomass-" .. tier]
		if recipe then
			recipe.ingredients = {
				{ type = "fluid", name = "water", amount = 90 },
				{ type = "fluid", name = "angels-gas-oxygen", amount = 10 },
				{ type = "fluid", name = "bi-biomass", amount = 10 },
			}
			if tier == 3 then table.insert(recipe.ingredients, { type = "item", name = "bi-ash", amount = 10 }) end
		end
	end
end
local sulfur = data.raw.recipe["bi-sulfur-angels"]
if sulfur then
	sulfur.energy_required = 12
	sulfur.results = { { type = "item", name = "sulfur", amount = 8 } }
end

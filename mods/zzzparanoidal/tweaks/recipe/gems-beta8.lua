-- Beta 8 normal: кристаллизация шести руд и карбид кремния для шлифовального круга.
-- Итоговые количества после старого flowfix; категории и продуктивность остаются 2.0.
if not mods["bobplates"] or not mods["angelsrefining"] then return end
for index = 1, 6 do
	local recipe = data.raw.recipe["angels-ore7-crystallization-" .. index]
	if recipe and data.raw.item["angels-catalysator-green"] then
		recipe.ingredients = {
			{ type = "fluid", name = "angels-crystal-seedling", amount = 50 },
			{ type = "item", name = "angels-catalysator-green", amount = 1 },
		}
	end
end
local carbide = data.raw.recipe["bob-silicon-carbide"]
if carbide then
	carbide.ingredients = {
		{ type = "item", name = "bob-silicon-powder", amount = 1 },
		{ type = "item", name = "angels-solid-carbon", amount = 1 },
	}
	carbide.results = { { type = "item", name = "bob-silicon-carbide", amount = 2 } }
end

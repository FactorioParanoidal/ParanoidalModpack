-- Beta 8 normal, zzz/recipes/warehousing.lua: пять улучшений большого склада Optera.
-- Storehouse после удаления Angels Bots не трогаем. Вместимость и миграции остаются 2.0.
if not mods["Warehousing"] then return end
for _, mode in ipairs({ "passive-provider", "storage", "active-provider", "requester", "buffer" }) do
	local recipe = data.raw.recipe["warehouse-" .. mode]
	if recipe and data.raw.item[mode .. "-chest"] then
		recipe.ingredients = {
			{ type = "item", name = "warehouse-basic", amount = 1 },
			{ type = "item", name = mode .. "-chest", amount = 1 },
			{ type = "item", name = "steel-plate", amount = 10 },
			{ type = "item", name = "iron-stick", amount = 15 },
		}
	end
end

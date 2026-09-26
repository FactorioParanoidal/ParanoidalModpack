-- Beta 8: 3 рыбы гарантированно + одна с вероятностью 0.85, не равномерный диапазон 3–4.
-- В 2.0 upstream потерял probability; OV.adjust_subtable схлопнул два статических выхода в один.
-- После последнего OV.execute восстанавливаем раздельные выходы с исходными метками 2.0.
local recipe = data.raw.recipe["angels-fish-keeping-3"]
if recipe and data.raw.capsule["angels-alien-fish-3-raw"] then
	recipe.results = {
		{ type = "item", name = "angels-alien-fish-3-raw", amount = 3, ignored_by_productivity = 3, ignored_by_stats = 3 },
		{
			type = "item", name = "angels-alien-fish-3-raw", amount = 1, probability = 0.85,
			ignored_by_productivity = 1, ignored_by_stats = 1, show_details_in_recipe_tooltip = false,
		},
		{ type = "fluid", name = "angels-liquid-polluted-fish-atmosphere", amount = 100 },
	}
end

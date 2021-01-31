--замена обычной рыбы на луч санты в рецепте механического паука
bobmods.lib.recipe.replace_ingredient("spidertron", "raw-fish", "alien-fish-3-raw")
--вывод из эксплуатации бесплатного насоса на воду	
data.raw.recipe["ground-water-pump"].hidden = true
data.raw.recipe["ground-water-pump"].enabled = false

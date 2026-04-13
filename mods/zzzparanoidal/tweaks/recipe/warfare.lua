require("__zzzparanoidal__.paralib")

--замена обычной рыбы на луч санты в рецепте механического паука
paralib.bobmods.lib.recipe.replace_ingredient("spidertron", "raw-fish", "angels-alien-fish-3-raw")

--добавляем к рецепту базовой артиллерии прототип.
paralib.bobmods.lib.recipe.add_ingredient("artillery-turret", { type = "item", name = "artillery-turret-prototype", amount = 2})


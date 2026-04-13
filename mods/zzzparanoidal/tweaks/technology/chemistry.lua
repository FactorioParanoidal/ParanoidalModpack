require("__zzzparanoidal__.paralib")
--включим пластик без электролизиров
paralib.bobmods.lib.tech.remove_prerequisite("plastics", "bob-electrolysis-2")

--убираем лишние рецепты
paralib.bobmods.lib.tech.remove_recipe_unlock("bob-chemical-processing-1", "bob-stone-chemical-furnace-from-stone-furnace")
paralib.bobmods.lib.tech.remove_recipe_unlock("bob-chemical-processing-1", "bob-stone-furnace-from-stone-chemical-furnace")


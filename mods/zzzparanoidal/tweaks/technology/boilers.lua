require("__zzzparanoidal__.paralib")

--убираем конвертацию между твёрдотопливными и жидкотопливными бойлерами
paralib.bobmods.lib.tech.remove_recipe_unlock("bob-boiler-2", "bob-boiler-2-from-oil-boiler")
paralib.bobmods.lib.tech.remove_recipe_unlock("bob-boiler-3", "bob-boiler-3-from-oil-boiler-2")
paralib.bobmods.lib.tech.remove_recipe_unlock("bob-boiler-4", "bob-boiler-4-from-oil-boiler-3")
paralib.bobmods.lib.tech.remove_recipe_unlock("bob-boiler-5", "bob-boiler-5-from-oil-boiler-4")

paralib.bobmods.lib.tech.remove_recipe_unlock("bob-oil-boiler-2", "bob-oil-boiler-2-from-boiler-3")
paralib.bobmods.lib.tech.remove_recipe_unlock("bob-oil-boiler-3", "bob-oil-boiler-3-from-boiler-4")
paralib.bobmods.lib.tech.remove_recipe_unlock("bob-oil-boiler-4", "bob-oil-boiler-4-from-boiler-5")



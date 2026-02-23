--включим пластик без электролизиров
bobmods.lib.tech.remove_prerequisite("plastics", "bob-electrolysis-2")

--фикс атомной бомбы
bobmods.lib.tech.remove_prerequisite("atomic-bomb", "kovarex-enrichment-process")

--фикс атомной артилерии
bobmods.lib.tech.add_prerequisite("bob-atomic-artillery-shell", "atomic-bomb")
bobmods.lib.tech.remove_prerequisite("bob-atomic-artillery-shell", "kovarex-enrichment-process")
bobmods.lib.tech.remove_recipe_unlock("atomic-bomb", "bob-atomic-artillery-shell")

--фикс плазменных ракет
bobmods.lib.tech.remove_prerequisite("bob-plasma-rocket", "rocket" )
bobmods.lib.tech.add_prerequisite("bob-plasma-rocket", "rocketry")

--убираем лишние рецепты
bobmods.lib.tech.remove_recipe_unlock("bob-chemical-processing-1", "bob-stone-chemical-furnace-from-stone-furnace")
bobmods.lib.tech.remove_recipe_unlock("bob-chemical-processing-1", "bob-stone-furnace-from-stone-chemical-furnace")
bobmods.lib.tech.remove_recipe_unlock("bob-alloy-processing", "bob-stone-mixing-furnace-from-stone-furnace")
bobmods.lib.tech.remove_recipe_unlock("bob-alloy-processing", "bob-stone-furnace-from-stone-mixing-furnace")


--разные фиксы зависимостей технологий
--bobmods.lib.tech.add_prerequisite("angels-metallurgy-1", "steel-processing")

--убираем конвертацию между твёрдотопливными и жидкотопливными бойлерами
bobmods.lib.tech.remove_recipe_unlock("bob-boiler-2", "bob-boiler-2-from-oil-boiler")
bobmods.lib.tech.remove_recipe_unlock("bob-boiler-3", "bob-boiler-3-from-oil-boiler-2")
bobmods.lib.tech.remove_recipe_unlock("bob-boiler-4", "bob-boiler-4-from-oil-boiler-3")
bobmods.lib.tech.remove_recipe_unlock("bob-boiler-5", "bob-boiler-5-from-oil-boiler-4")

bobmods.lib.tech.remove_recipe_unlock("bob-oil-boiler-2", "bob-oil-boiler-2-from-boiler-3")
bobmods.lib.tech.remove_recipe_unlock("bob-oil-boiler-3", "bob-oil-boiler-3-from-boiler-4")
bobmods.lib.tech.remove_recipe_unlock("bob-oil-boiler-4", "bob-oil-boiler-4-from-boiler-5")

--скрываем имбалансную технологию боба
data.raw.technology["bob-robot-plasma-drones"].hidden = true

--разблокируем рецепт для упрощенной плавки бронзы в печах
bobmods.lib.tech.add_recipe_unlock("angels-bronze-smelting-1", "bob-bronze-alloy")

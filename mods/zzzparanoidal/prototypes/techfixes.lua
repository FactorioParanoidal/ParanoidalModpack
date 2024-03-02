-- био пакет в гиг-лабу и гипер-лабу
table.insert(data.raw["lab"]["big-lab"].inputs, "token-bio")
table.insert(data.raw["lab"]["hyper-lab"].inputs, "token-bio")

--включим пластик без электролизиров
bobmods.lib.tech.remove_prerequisite("plastics", "electrolysis-2")

--фикс атомной бомбы
bobmods.lib.tech.remove_prerequisite("atomic-bomb", "kovarex-enrichment-process")

--фикс атомной артилерии
bobmods.lib.tech.remove_recipe_unlock("atomic-bomb", "atomic-artillery-shell")

--фикс плазменных ракет
bobmods.lib.tech.remove_prerequisite("bob-plasma-rocket", "bob-rocket")
bobmods.lib.tech.add_prerequisite("bob-plasma-rocket", "rocketry")

--убираем лишние рецепты
bobmods.lib.tech.remove_recipe_unlock("chemical-processing-1", "stone-chemical-furnace-from-stone-furnace")
bobmods.lib.tech.remove_recipe_unlock("chemical-processing-1", "stone-furnace-from-stone-chemical-furnace")
bobmods.lib.tech.remove_recipe_unlock("alloy-processing", "stone-mixing-furnace-from-stone-furnace")
bobmods.lib.tech.remove_recipe_unlock("alloy-processing", "stone-furnace-from-stone-mixing-furnace")

--разные фиксы зависимостей технологий
--bobmods.lib.tech.add_prerequisite("angels-metallurgy-1", "steel-processing")

--убираем конвертацию между твёрдотопливными и жидкотопливными бойлерами
bobmods.lib.tech.remove_recipe_unlock("bob-boiler-2", "boiler-2-from-oil-boiler")
bobmods.lib.tech.remove_recipe_unlock("bob-boiler-3", "boiler-3-from-oil-boiler-2")
bobmods.lib.tech.remove_recipe_unlock("bob-boiler-4", "boiler-4-from-oil-boiler-3")
bobmods.lib.tech.remove_recipe_unlock("bob-boiler-5", "boiler-5-from-oil-boiler-4")

bobmods.lib.tech.remove_recipe_unlock("bob-oil-boiler-2", "oil-boiler-2-from-boiler-3")
bobmods.lib.tech.remove_recipe_unlock("bob-oil-boiler-3", "oil-boiler-3-from-boiler-4")
bobmods.lib.tech.remove_recipe_unlock("bob-oil-boiler-4", "oil-boiler-4-from-boiler-5")

--скрываем неиспользуемые технологии электролиза боба, которые ничего не открывают
data.raw.technology["electrolyser-2"].hidden = true
data.raw.technology["electrolyser-3"].hidden = true
data.raw.technology["electrolyser-4"].hidden = true

--скрываем имбалансную технологию боба
data.raw.technology["bob-robot-plasma-drones"].hidden = true

--разблокируем рецепт для упрощенной плавки бронзы в печах
--bobmods.lib.tech.add_recipe_unlock("angels-bronze-smelting-1", "bronze-alloy")

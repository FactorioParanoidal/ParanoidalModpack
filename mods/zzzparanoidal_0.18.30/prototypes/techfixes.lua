-- био пакет в гигалабу
table.insert(data.raw["lab"]["big-lab"].inputs, "token-bio")

--включим пластик без электролизиров
bobmods.lib.tech.remove_prerequisite("plastics", "electrolysis-2")

--фикс атомной бомбы
bobmods.lib.tech.remove_prerequisite("atomic-bomb", "kovarex-enrichment-process")

--фикс атомной артилерии
bobmods.lib.tech.add_prerequisite("bob-atomic-artillery-shell", "atomic-bomb")
bobmods.lib.tech.remove_prerequisite("bob-atomic-artillery-shell", "kovarex-enrichment-process")
bobmods.lib.tech.remove_recipe_unlock("atomic-bomb", "atomic-artillery-shell")

--фикс плазменных рокет
bobmods.lib.tech.remove_prerequisite("bob-plasma-rocket", "bob-rocket" )
bobmods.lib.tech.add_prerequisite("bob-plasma-rocket", "rocketry")

--убираем лишние рецепты
bobmods.lib.tech.remove_recipe_unlock("chemical-processing-1", "stone-chemical-furnace-from-stone-furnace")
bobmods.lib.tech.remove_recipe_unlock("chemical-processing-1", "stone-furnace-from-stone-chemical-furnace")
bobmods.lib.tech.remove_recipe_unlock("alloy-processing-1", "stone-mixing-furnace-from-stone-furnace")
bobmods.lib.tech.remove_recipe_unlock("alloy-processing-1", "stone-furnace-from-stone-mixing-furnace")


--разные фиксы зависимостей технологий
bobmods.lib.tech.add_prerequisite("angels-metallurgy-1", "steel-processing")
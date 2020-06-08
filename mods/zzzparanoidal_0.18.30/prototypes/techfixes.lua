-- био пакет в гигалабу
table.insert(data.raw["lab"]["big-lab"].inputs, "token-bio")

--включим пластик без электролизиров
bobmods.lib.tech.remove_prerequisite("plastics", "electrolysis-2")

--фикс атомной артилерии
bobmods.lib.tech.add_prerequisite("bob-atomic-artillery-shell", "atomic-bomb")
bobmods.lib.tech.remove_prerequisite("bob-atomic-artillery-shell", "kovarex-enrichment-process")
bobmods.lib.tech.remove_recipe_unlock("atomic-bomb", "atomic-artillery-shell")

--фикс плазменных рокет
bobmods.lib.tech.remove_prerequisite("bob-plasma-rocket", "bob-rocket" )
bobmods.lib.tech.add_prerequisite("bob-plasma-rocket", "rocketry")
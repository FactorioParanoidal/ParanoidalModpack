require("__zzzparanoidal__.paralib")

--скрываем имбалансную технологию боба
paralib.bobmods.lib.tech.hide("bob-robot-plasma-drones")

--фикс атомной бомбы
paralib.bobmods.lib.tech.remove_prerequisite("atomic-bomb", "kovarex-enrichment-process")

--фикс атомной артилерии
paralib.bobmods.lib.tech.add_prerequisite("bob-atomic-artillery-shell", "atomic-bomb")
paralib.bobmods.lib.tech.remove_prerequisite("bob-atomic-artillery-shell", "kovarex-enrichment-process")
paralib.bobmods.lib.tech.remove_recipe_unlock("atomic-bomb", "bob-atomic-artillery-shell")

--фикс плазменных ракет
paralib.bobmods.lib.tech.remove_prerequisite("bob-plasma-rocket", "rocket" )
paralib.bobmods.lib.tech.add_prerequisite("bob-plasma-rocket", "rocketry")

--привязываем базовую артиллерию к новому прототипу
paralib.bobmods.lib.tech.add_prerequisite("artillery", "artillery-prototype")
--удаляем лишние зависимости
paralib.bobmods.lib.tech.remove_prerequisite("artillery", "bi-tech-bio-cannon")

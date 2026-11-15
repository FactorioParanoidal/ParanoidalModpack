require("__zzzparanoidal__.paralib")

--скрываем имбалансную технологию боба
paralib.bobmods.lib.tech.hide("bob-robot-plasma-drones")


--фикс плазменных ракет
paralib.bobmods.lib.tech.add_prerequisite("bob-plasma-rocket", "rocketry")

--привязываем базовую артиллерию к новому прототипу
paralib.bobmods.lib.tech.add_prerequisite("artillery", "artillery-prototype")
--удаляем лишние зависимости
paralib.bobmods.lib.tech.remove_prerequisite("artillery", "bi-tech-bio-cannon")

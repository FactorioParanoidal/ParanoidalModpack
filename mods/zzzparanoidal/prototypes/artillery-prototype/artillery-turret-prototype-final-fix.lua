--добавляем к рецепту базовой артиллерии прототип.
bobmods.lib.recipe.add_ingredient("artillery-turret", { "artillery-turret-prototype", 2 })
-------------------------------------------------------------------------------------------------
--привязываем базовую артиллерию к новому прототипу
bobmods.lib.tech.add_prerequisite("artillery", "artillery-prototype")

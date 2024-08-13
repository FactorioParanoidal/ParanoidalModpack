-- Ненужные рецепты скрываем

data.raw.recipe["slag-processing-yi"].enabled = false
data.raw.recipe["slag-processing-yi"].hidden = true

data.raw.recipe["y-crusher-recipe"].enabled = false
data.raw.recipe["y-crusher-recipe"].hidden = true

data.raw.recipe["y-heat-form-press-recipe"].enabled = false
data.raw.recipe["y-heat-form-press-recipe"].hidden = true

data.raw.recipe["y-ac-copper2uc-recipe"].hidden = true
data.raw.recipe["y-ac-iron2uc-recipe"].hidden = true
data.raw.recipe["y-ac-wood2uc-recipe"].hidden = true
data.raw.recipe["y-ac-coal2uc-recipe"].hidden = true
data.raw.recipe["y-ac-stone2uc-recipe"].hidden = true
data.raw.recipe["y-ac-iron2uc-recipe"].hidden = true

-- Ненужные технологии скрываем

data.raw.technology["yi-inserters"].hidden = true
data.raw.technology["yi-advanced-inserters"].hidden = true
data.raw.technology["yi-basic-transport"].hidden = true
data.raw.technology["yi-advanced-transport"].hidden = true
data.raw.technology["yi-lights"].hidden = true
data.raw.technology["yi-inserters"].hidden = true
data.raw.technology["yi-inserters"].hidden = true
data.raw.technology["yi-inserters"].hidden = true

-- Ненужные вещи из рецептов удаляем

-- bobmods.lib.recipe.remove_result("Recipename", "Itemname")
-- bobmods.lib.recipe.remove_ingredient ("Recipename", "itemname")
-- bobmods.lib.recipe.add_new_ingredient ("Recipename", {type="item", name="Itemname", amount=2})
-- table.insert( data.raw["recipe"]["Recipename"].ingredients, {"Itemname", 14})

bobmods.lib.recipe.remove_result("angels-ore1-chunk", "y-res1")
bobmods.lib.recipe.remove_result("angels-ore3-chunk", "y-res2")
bobmods.lib.recipe.remove_result("angels-ore1-crystal", "y-res1")
bobmods.lib.recipe.remove_result("angels-ore3-crystal", "y-res2")
bobmods.lib.recipe.remove_result("angels-ore1-pure", "y-res1")
bobmods.lib.recipe.remove_result("angels-ore3-pure", "y-res2")

-- заменяем ингриды и результат у рецептов
--Уникомпозит
data.raw.recipe["angelsore-chunk-mix-yi1-processing"].category = "ore-sorting-4"
data.raw.recipe["angelsore-chunk-mix-yi1-processing"].ingredients = {
	{ type = "item", name = "angels-ore1-pure", amount = 4 },
	{ type = "item", name = "angels-ore3-pure", amount = 4 },
	{ type = "item", name = "angels-ore5-pure", amount = 4 },
	{ type = "item", name = "solid-sodium", amount = 20 },
}

data.raw.recipe["angelsore-chunk-mix-yi1-processing"].results = {
	{ type = "item", name = "y-res1", amount = 1 },
}
--Энергоминерал
data.raw.recipe["angelsore-chunk-mix-yi2-processing"].category = "ore-sorting-4"
data.raw.recipe["angelsore-chunk-mix-yi2-processing"].ingredients = {
	{ type = "item", name = "angels-ore2-pure", amount = 4 },
	{ type = "item", name = "angels-ore4-pure", amount = 4 },
	{ type = "item", name = "angels-ore6-pure", amount = 4 },
	{ type = "item", name = "solid-white-phosphorus", amount = 20 },
}

data.raw.recipe["angelsore-chunk-mix-yi2-processing"].results = {
	{ type = "item", name = "y-res2", amount = 1 },
}

data.raw.recipe["y-c22-recipe"].ingredients = {
	{ type = "item", name = "angels-ore2-pure", amount = 4 },
	{ type = "item", name = "angels-ore4-pure", amount = 4 },
	{ type = "item", name = "angels-ore6-pure", amount = 4 },
	{ type = "item", name = "solid-white-phosphorus", amount = 20 },
}

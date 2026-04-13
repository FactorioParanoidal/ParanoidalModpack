require("__zzzparanoidal__.paralib")
if mods["yuoki"] then
	-- Ненужные рецепты скрываем

	paralib.bobmods.lib.recipe.hide("slag-processing-yi")
	paralib.bobmods.lib.recipe.hide("y-crusher-recipe")
	paralib.bobmods.lib.recipe.hide("y-heat-form-press-recipe")

	paralib.bobmods.lib.recipe.hide("y-ac-copper2uc-recipe")
	paralib.bobmods.lib.recipe.hide("y-ac-iron2uc-recipe")
	paralib.bobmods.lib.recipe.hide("y-ac-wood2uc-recipe")
	paralib.bobmods.lib.recipe.hide("y-ac-coal2uc-recipe")
	paralib.bobmods.lib.recipe.hide("y-ac-stone2uc-recipe")
	paralib.bobmods.lib.recipe.hide("y-ac-iron2uc-recipe")

	paralib.bobmods.lib.recipe.remove_result("angels-ore1-chunk", "y-res1")
	paralib.bobmods.lib.recipe.remove_result("angels-ore3-chunk", "y-res2")
	paralib.bobmods.lib.recipe.remove_result("angels-ore1-crystal", "y-res1")
	paralib.bobmods.lib.recipe.remove_result("angels-ore3-crystal", "y-res2")
	paralib.bobmods.lib.recipe.remove_result("angels-ore1-pure", "y-res1")
	paralib.bobmods.lib.recipe.remove_result("angels-ore3-pure", "y-res2")

	-- заменяем ингриды и результат у рецептов
	--Уникомпозит
	data.raw.recipe["angelsore-chunk-mix-yi1-processing"].category = "angels-ore-sorting-4"
	paralib.bobmods.lib.recipe.set_ingredients("angelsore-chunk-mix-yi1-processing", {
		{ type = "item", name = "angels-ore1-pure", amount = 4 },
		{ type = "item", name = "angels-ore3-pure", amount = 4 },
		{ type = "item", name = "angels-ore5-pure", amount = 4 },
		{ type = "item", name = "angels-solid-sodium", amount = 20 },
	})

	paralib.bobmods.lib.recipe.set_results("angelsore-chunk-mix-yi1-processing", {
		{ type = "item", name = "y-res1", amount = 1 },
	})

	--Энергоминерал
	data.raw.recipe["angelsore-chunk-mix-yi2-processing"].category = "angels-ore-sorting-4"
	paralib.bobmods.lib.recipe.set_ingredients("angelsore-chunk-mix-yi2-processing", {
		{ type = "item", name = "angels-ore2-pure", amount = 4 },
		{ type = "item", name = "angels-ore4-pure", amount = 4 },
		{ type = "item", name = "angels-ore6-pure", amount = 4 },
		{ type = "item", name = "solid-white-phosphorus", amount = 20 },
	})

	paralib.bobmods.lib.recipe.set_results("angelsore-chunk-mix-yi2-processing", {
		{ type = "item", name = "y-res2", amount = 1 },
	})
end

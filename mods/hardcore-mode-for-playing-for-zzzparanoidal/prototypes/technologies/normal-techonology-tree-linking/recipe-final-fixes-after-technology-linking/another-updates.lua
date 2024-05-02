local recipeUtil = require("__automated-utility-protocol__.util.recipe-util")
local function remove_recipe_ingredients(mode)
	recipeUtil.remove_recipe_ingredient("heat-exchanger", mode, { type = "item", name = "boiler-2" })
	recipeUtil.remove_recipe_ingredient(
		"electric-mixing-furnace",
		mode,
		{ type = "item", name = "electric-chemical-furnace" }
	)
	if data.raw["item"]["steam-turbine"] then
		recipeUtil.remove_recipe_ingredient("nuclear-reactor", mode, { type = "item", name = "boiler-4" })
	end
	recipeUtil.remove_recipe_ingredients("intelligent-io", mode, {
		{ type = "item", name = "speed-processor-3" },
		{ type = "item", name = "effectivity-processor-3" },
		{ type = "item", name = "productivity-processor-3" },
	})
end
local function add_recipe_ingredients(mode)
	if data.raw["item"]["steam-turbine"] then
		recipeUtil.add_recipe_ingredients("nuclear-reactor", mode, {
			{ type = "item", name = "boiler-4-steam-615-with-fuel-item-solid-oil-residual", amount = 1 },
			{ type = "item", name = "boiler-4-steam-615-with-fuel-item-wood-pellets", amount = 1 },
		})
	end
	recipeUtil.add_recipe_ingredients("heat-exchanger", mode, {
		{ type = "item", name = "boiler-2-steam-315-with-fuel-item-coal", amount = 1 },
		{ type = "item", name = "boiler-2-steam-315-with-fuel-item-solid-carbon", amount = 1 },
	})
	recipeUtil.add_recipe_ingredients("intelligent-io", mode, {
		{ type = "item", name = "speed-processor-2", amount = 16 },
		{ type = "item", name = "effectivity-processor-2", amount = 16 },
		{ type = "item", name = "productivity-processor-2", amount = 16 },
	})
end
_table.each(GAME_MODES, function(mode)
	remove_recipe_ingredients(mode)
	add_recipe_ingredients(mode)
end)

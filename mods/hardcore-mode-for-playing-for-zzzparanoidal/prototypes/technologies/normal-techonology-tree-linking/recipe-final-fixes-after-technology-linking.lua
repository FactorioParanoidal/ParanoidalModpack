local recipeUtil = require("__automated-utility-protocol__.util.recipe-util")
-- обновление бойлеров
local boiler_recipe_ingredients = {
	{
		type = "item",
		name = "bi-wood-pipe",
		amount = 6,
	},
	{
		type = "item",
		name = "stone-furnace",
		amount = 1,
	},
}

local boiler_wood_165_recipe = data.raw["recipe"]["boiler-steam-165-with-fuel-item-wood"]
boiler_wood_165_recipe.normal.ingredients = boiler_recipe_ingredients
boiler_wood_165_recipe.expensive.ingredients = boiler_recipe_ingredients

local boiler_coal_165_recipe = data.raw["recipe"]["boiler-steam-165-with-fuel-item-coal"]
boiler_coal_165_recipe.normal.ingredients = boiler_recipe_ingredients
boiler_coal_165_recipe.expensive.ingredients = boiler_recipe_ingredients

-- конец обновление бойлеров
local function remove_recipe_ingredients(mode)
	if data.raw["item"]["steam-turbine"] then
		recipeUtil.remove_recipe_ingredient("nuclear-reactor", mode, { type = "item", name = "boiler-4" })
	end
	recipeUtil.remove_recipe_ingredient("heat-exchanger", mode, { type = "item", name = "boiler-2" })
	recipeUtil.remove_recipe_ingredient(
		"electric-mixing-furnace",
		mode,
		{ type = "item", name = "electric-chemical-furnace" }
	)
	recipeUtil.remove_recipe_ingredient(
		"boiler-2-steam-315-with-fuel-item-coal",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"boiler-2-steam-315-with-fuel-item-solid-carbon",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"boiler-3-steam-465-with-fuel-item-solid-oil-residual",
		mode,
		{ type = "item", name = "boiler-2" }
	)
	recipeUtil.remove_recipe_ingredient(
		"boiler-3-steam-465-with-fuel-item-wood-charcoal",
		mode,
		{ type = "item", name = "boiler-2" }
	)
	recipeUtil.remove_recipe_ingredient(
		"boiler-4-steam-615-with-fuel-item-solid-oil-residual",
		mode,
		{ type = "item", name = "boiler-3" }
	)
	recipeUtil.remove_recipe_ingredient(
		"boiler-4-steam-615-with-fuel-item-gas-hydrogen-barrel",
		mode,
		{ type = "item", name = "boiler-3" }
	)
	recipeUtil.remove_recipe_ingredient(
		"boiler-4-steam-615-with-fuel-item-gas-urea-barrel",
		mode,
		{ type = "item", name = "boiler-3" }
	)
	recipeUtil.remove_recipe_ingredient(
		"boiler-4-steam-615-with-fuel-item-wood-pellets",
		mode,
		{ type = "item", name = "boiler-3" }
	)
	recipeUtil.remove_recipe_ingredient(
		"boiler-4-steam-615-with-fuel-item-solid-fuel",
		mode,
		{ type = "item", name = "boiler-3" }
	)
	recipeUtil.remove_recipe_ingredient(
		"boiler-5-steam-765-with-fuel-item-solid-oil-residual",
		mode,
		{ type = "item", name = "boiler-4" }
	)
	recipeUtil.remove_recipe_ingredient(
		"boiler-5-steam-765-with-fuel-item-gas-hydrogen-barrel",
		mode,
		{ type = "item", name = "boiler-4" }
	)
	recipeUtil.remove_recipe_ingredient(
		"boiler-5-steam-765-with-fuel-item-gas-urea-barrel",
		mode,
		{ type = "item", name = "boiler-4" }
	)
	recipeUtil.remove_recipe_ingredient(
		"boiler-5-steam-765-with-fuel-item-wood-pellets",
		mode,
		{ type = "item", name = "boiler-4" }
	)
	recipeUtil.remove_recipe_ingredient(
		"boiler-5-steam-765-with-fuel-item-solid-fuel",
		mode,
		{ type = "item", name = "boiler-4" }
	)
	recipeUtil.remove_recipe_ingredient(
		"boiler-5-steam-765-with-fuel-item-wood-bricks",
		mode,
		{ type = "item", name = "boiler-4" }
	)
	--жидкие котлы
	recipeUtil.remove_recipe_ingredient(
		"oil-steam-boiler-steam-165-with-fuel-fluid-liquid-plastic",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"oil-steam-boiler-steam-165-with-fuel-fluid-gas-residual",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"oil-steam-boiler-steam-165-with-fuel-fluid-gas-ethylene",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"oil-steam-boiler-steam-165-with-fuel-fluid-gas-benzene",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"oil-steam-boiler-steam-165-with-fuel-fluid-gas-propene",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"oil-steam-boiler-steam-165-with-fuel-fluid-gas-butadiene",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"oil-steam-boiler-steam-165-with-fuel-fluid-liquid-ngl",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"oil-steam-boiler-steam-165-with-fuel-fluid-gas-methane",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"oil-steam-boiler-steam-165-with-fuel-fluid-gas-ethane",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"oil-steam-boiler-steam-165-with-fuel-fluid-gas-butane",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"oil-steam-boiler-steam-165-with-fuel-fluid-gas-raw-1",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"oil-steam-boiler-steam-165-with-fuel-fluid-crude-oil",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"oil-steam-boiler-steam-165-with-fuel-fluid-gas-natural-1",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"oil-steam-boiler-steam-165-with-fuel-fluid-liquid-fuel-oil",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"oil-steam-boiler-steam-165-with-fuel-fluid-liquid-naphtha",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"oil-steam-boiler-steam-165-with-fuel-fluid-gas-acetone",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"oil-steam-boiler-steam-165-with-fuel-fluid-gas-ethanol",
		mode,
		{ type = "item", name = "boiler" }
	)

	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-2-steam-315-with-fuel-fluid-liquid-plastic",
		mode,
		{ { type = "item", name = "oil-steam-boiler" }, { type = "item", name = "boiler-2" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-2-steam-315-with-fuel-fluid-gas-ethylene",
		mode,
		{ { type = "item", name = "oil-steam-boiler" }, { type = "item", name = "boiler-2" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-2-steam-315-with-fuel-fluid-gas-benzene",
		mode,
		{ { type = "item", name = "oil-steam-boiler" }, { type = "item", name = "boiler-2" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-2-steam-315-with-fuel-fluid-gas-butadiene",
		mode,
		{ { type = "item", name = "oil-steam-boiler" }, { type = "item", name = "boiler-2" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-2-steam-315-with-fuel-fluid-gas-ethane",
		mode,
		{ { type = "item", name = "oil-steam-boiler" }, { type = "item", name = "boiler-2" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-2-steam-315-with-fuel-fluid-gas-butane",
		mode,
		{ { type = "item", name = "oil-steam-boiler" }, { type = "item", name = "boiler-2" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-2-steam-315-with-fuel-fluid-liquid-fuel-oil",
		mode,
		{ { type = "item", name = "oil-steam-boiler" }, { type = "item", name = "boiler-2" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-3-steam-465-with-fuel-fluid-liquid-plastic",
		mode,
		{ { type = "item", name = "oil-steam-boiler-2" }, { type = "item", name = "boiler-3" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-3-steam-465-with-fuel-fluid-gas-benzene",
		mode,
		{ { type = "item", name = "oil-steam-boiler-2" }, { type = "item", name = "boiler-3" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-3-steam-465-with-fuel-fluid-gas-butadiene",
		mode,
		{ { type = "item", name = "oil-steam-boiler-2" }, { type = "item", name = "boiler-3" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-3-steam-465-with-fuel-fluid-gas-butane",
		mode,
		{ { type = "item", name = "oil-steam-boiler-2" }, { type = "item", name = "boiler-3" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-4-steam-615-with-fuel-fluid-liquid-plastic",
		mode,
		{ { type = "item", name = "oil-steam-boiler-3" }, { type = "item", name = "boiler-4" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-4-steam-615-with-fuel-fluid-gas-benzene",
		mode,
		{ { type = "item", name = "oil-steam-boiler-3" }, { type = "item", name = "boiler-4" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-4-steam-615-with-fuel-fluid-gas-butadiene",
		mode,
		{ { type = "item", name = "oil-steam-boiler-3" }, { type = "item", name = "boiler-4" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-4-steam-615-with-fuel-fluid-gas-butane",
		mode,
		{ { type = "item", name = "oil-steam-boiler-3" }, { type = "item", name = "boiler-4" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-4-steam-615-with-fuel-fluid-liquid-rubber",
		mode,
		{ { type = "item", name = "oil-steam-boiler-3" }, { type = "item", name = "boiler-4" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-4-steam-615-with-fuel-fluid-liquid-resin",
		mode,
		{ { type = "item", name = "oil-steam-boiler-3" }, { type = "item", name = "boiler-4" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-4-steam-615-with-fuel-fluid-liquid-styrene",
		mode,
		{ { type = "item", name = "oil-steam-boiler-3" }, { type = "item", name = "boiler-4" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-4-steam-615-with-fuel-fluid-liquid-ethylbenzene",
		mode,
		{ { type = "item", name = "oil-steam-boiler-3" }, { type = "item", name = "boiler-4" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-4-steam-615-with-fuel-fluid-liquid-polyethylene",
		mode,
		{ { type = "item", name = "oil-steam-boiler-3" }, { type = "item", name = "boiler-4" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-4-steam-615-with-fuel-fluid-liquid-toluene",
		mode,
		{ { type = "item", name = "oil-steam-boiler-3" }, { type = "item", name = "boiler-4" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-5-steam-765-with-fuel-fluid-liquid-plastic",
		mode,
		{ { type = "item", name = "oil-steam-boiler-4" }, { type = "item", name = "boiler-5" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-5-steam-765-with-fuel-fluid-gas-benzene",
		mode,
		{ { type = "item", name = "oil-steam-boiler-4" }, { type = "item", name = "boiler-5" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-5-steam-765-with-fuel-fluid-gas-butadiene",
		mode,
		{ { type = "item", name = "oil-steam-boiler-4" }, { type = "item", name = "boiler-5" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-5-steam-765-with-fuel-fluid-gas-butane",
		mode,
		{ { type = "item", name = "oil-steam-boiler-4" }, { type = "item", name = "boiler-5" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-5-steam-765-with-fuel-fluid-liquid-rubber",
		mode,
		{ { type = "item", name = "oil-steam-boiler-4" }, { type = "item", name = "boiler-5" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-5-steam-765-with-fuel-fluid-liquid-resin",
		mode,
		{ { type = "item", name = "oil-steam-boiler-4" }, { type = "item", name = "boiler-5" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-5-steam-765-with-fuel-fluid-liquid-styrene",
		mode,
		{ { type = "item", name = "oil-steam-boiler-4" }, { type = "item", name = "boiler-5" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-5-steam-765-with-fuel-fluid-liquid-ethylbenzene",
		mode,
		{ { type = "item", name = "oil-steam-boiler-4" }, { type = "item", name = "boiler-5" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-5-steam-765-with-fuel-fluid-liquid-polyethylene",
		mode,
		{ { type = "item", name = "oil-steam-boiler-4" }, { type = "item", name = "boiler-5" } }
	)
	recipeUtil.remove_recipe_ingredients(
		"oil-steam-boiler-5-steam-765-with-fuel-fluid-liquid-toluene",
		mode,
		{ { type = "item", name = "oil-steam-boiler-4" }, { type = "item", name = "boiler-5" } }
	)
	--конец жидкие котлы
	--биобойлеры
	recipeUtil.remove_recipe_ingredient(
		"bi-bio-boiler-steam-165-with-fuel-item-small-alien-artifact-red",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"bi-bio-boiler-steam-165-with-fuel-item-small-alien-artifact-yellow",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"bi-bio-boiler-steam-165-with-fuel-item-small-alien-artifact-orange",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"bi-bio-boiler-steam-165-with-fuel-item-small-alien-artifact-blue",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"bi-bio-boiler-steam-165-with-fuel-item-small-alien-artifact-purple",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"bi-bio-boiler-steam-165-with-fuel-item-small-alien-artifact-green",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"bi-bio-boiler-steam-165-with-fuel-item-small-alien-artifact",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"bi-bio-boiler-steam-165-with-fuel-item-coal",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"bi-bio-boiler-steam-165-with-fuel-item-wood",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"bi-bio-boiler-steam-165-with-fuel-item-solid-carbon",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"bi-bio-boiler-steam-165-with-fuel-item-coal-crushed",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"bi-bio-boiler-steam-165-with-fuel-item-solid-coke",
		mode,
		{ type = "item", name = "boiler" }
	)
	recipeUtil.remove_recipe_ingredient(
		"bi-bio-boiler-steam-165-with-fuel-item-wood-charcoal",
		mode,
		{ type = "item", name = "boiler" }
	)
	-- конец биобойлеры
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
	recipeUtil.add_recipe_ingredients(
		"boiler-2-steam-315-with-fuel-item-coal",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"boiler-2-steam-315-with-fuel-item-solid-carbon",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"boiler-3-steam-465-with-fuel-item-solid-oil-residual",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 4 }, { type = "item", name = "steel-pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"boiler-3-steam-465-with-fuel-item-wood-charcoal",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 4 }, { type = "item", name = "steel-pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"boiler-4-steam-615-with-fuel-item-solid-oil-residual",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 6 }, { type = "item", name = "steel-pipe", amount = 7 } }
	)
	recipeUtil.add_recipe_ingredients(
		"boiler-4-steam-615-with-fuel-item-gas-hydrogen-barrel",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 6 }, { type = "item", name = "steel-pipe", amount = 7 } }
	)
	recipeUtil.add_recipe_ingredients(
		"boiler-4-steam-615-with-fuel-item-gas-urea-barrel",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 6 }, { type = "item", name = "steel-pipe", amount = 7 } }
	)
	recipeUtil.add_recipe_ingredients(
		"boiler-4-steam-615-with-fuel-item-wood-pellets",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 6 }, { type = "item", name = "steel-pipe", amount = 7 } }
	)
	recipeUtil.add_recipe_ingredients(
		"boiler-4-steam-615-with-fuel-item-solid-fuel",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 6 }, { type = "item", name = "steel-pipe", amount = 7 } }
	)
	recipeUtil.add_recipe_ingredients(
		"boiler-5-steam-765-with-fuel-item-solid-oil-residual",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 8 }, { type = "item", name = "steel-pipe", amount = 10 } }
	)
	recipeUtil.add_recipe_ingredients(
		"boiler-5-steam-765-with-fuel-item-gas-hydrogen-barrel",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 8 }, { type = "item", name = "steel-pipe", amount = 10 } }
	)
	recipeUtil.add_recipe_ingredients(
		"boiler-5-steam-765-with-fuel-item-gas-urea-barrel",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 8 }, { type = "item", name = "steel-pipe", amount = 10 } }
	)
	recipeUtil.add_recipe_ingredients(
		"boiler-5-steam-765-with-fuel-item-wood-pellets",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 8 }, { type = "item", name = "steel-pipe", amount = 10 } }
	)
	recipeUtil.add_recipe_ingredients(
		"boiler-5-steam-765-with-fuel-item-solid-fuel",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 8 }, { type = "item", name = "steel-pipe", amount = 10 } }
	)
	recipeUtil.add_recipe_ingredients(
		"boiler-5-steam-765-with-fuel-item-wood-bricks",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 8 }, { type = "item", name = "steel-pipe", amount = 10 } }
	)
	--жидкие котлы
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-steam-165-with-fuel-fluid-liquid-plastic",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-steam-165-with-fuel-fluid-gas-residual",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-steam-165-with-fuel-fluid-gas-ethylene",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-steam-165-with-fuel-fluid-gas-benzene",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-steam-165-with-fuel-fluid-gas-propene",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-steam-165-with-fuel-fluid-gas-butadiene",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-steam-165-with-fuel-fluid-liquid-ngl",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-steam-165-with-fuel-fluid-gas-methane",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-steam-165-with-fuel-fluid-gas-ethane",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-steam-165-with-fuel-fluid-gas-butane",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-steam-165-with-fuel-fluid-gas-raw-1",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-steam-165-with-fuel-fluid-crude-oil",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-steam-165-with-fuel-fluid-gas-natural-1",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-steam-165-with-fuel-fluid-liquid-fuel-oil",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-steam-165-with-fuel-fluid-liquid-naphtha",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-steam-165-with-fuel-fluid-gas-acetone",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-steam-165-with-fuel-fluid-gas-ethanol",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-2-steam-315-with-fuel-fluid-liquid-plastic",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 8 }, { type = "item", name = "steel-pipe", amount = 9 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-2-steam-315-with-fuel-fluid-gas-ethylene",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 8 }, { type = "item", name = "steel-pipe", amount = 9 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-2-steam-315-with-fuel-fluid-gas-benzene",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 8 }, { type = "item", name = "steel-pipe", amount = 9 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-2-steam-315-with-fuel-fluid-gas-butadiene",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 8 }, { type = "item", name = "steel-pipe", amount = 9 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-2-steam-315-with-fuel-fluid-gas-ethane",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 8 }, { type = "item", name = "steel-pipe", amount = 9 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-2-steam-315-with-fuel-fluid-gas-butane",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 8 }, { type = "item", name = "steel-pipe", amount = 9 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-2-steam-315-with-fuel-fluid-liquid-fuel-oil",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 12 }, { type = "item", name = "steel-pipe", amount = 13 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-3-steam-465-with-fuel-fluid-liquid-plastic",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 12 }, { type = "item", name = "steel-pipe", amount = 13 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-3-steam-465-with-fuel-fluid-gas-benzene",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 12 }, { type = "item", name = "steel-pipe", amount = 13 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-3-steam-465-with-fuel-fluid-gas-butadiene",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 12 }, { type = "item", name = "steel-pipe", amount = 13 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-3-steam-465-with-fuel-fluid-gas-butane",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 12 }, { type = "item", name = "steel-pipe", amount = 13 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-4-steam-615-with-fuel-fluid-gas-benzene",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 18 }, { type = "item", name = "steel-pipe", amount = 19 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-4-steam-615-with-fuel-fluid-gas-butadiene",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 18 }, { type = "item", name = "steel-pipe", amount = 19 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-4-steam-615-with-fuel-fluid-gas-butane",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 18 }, { type = "item", name = "steel-pipe", amount = 19 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-4-steam-615-with-fuel-fluid-liquid-rubber",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 18 }, { type = "item", name = "steel-pipe", amount = 19 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-4-steam-615-with-fuel-fluid-liquid-resin",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 18 }, { type = "item", name = "steel-pipe", amount = 19 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-4-steam-615-with-fuel-fluid-liquid-styrene",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 18 }, { type = "item", name = "steel-pipe", amount = 19 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-4-steam-615-with-fuel-fluid-liquid-ethylbenzene",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 18 }, { type = "item", name = "steel-pipe", amount = 19 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-4-steam-615-with-fuel-fluid-liquid-polyethylene",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 18 }, { type = "item", name = "steel-pipe", amount = 19 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-4-steam-615-with-fuel-fluid-liquid-toluene",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 18 }, { type = "item", name = "steel-pipe", amount = 19 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-5-steam-765-with-fuel-fluid-liquid-plastic",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 26 }, { type = "item", name = "steel-pipe", amount = 27 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-5-steam-765-with-fuel-fluid-gas-benzene",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 26 }, { type = "item", name = "steel-pipe", amount = 27 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-5-steam-765-with-fuel-fluid-gas-butadiene",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 26 }, { type = "item", name = "steel-pipe", amount = 27 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-5-steam-765-with-fuel-fluid-gas-butane",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 26 }, { type = "item", name = "steel-pipe", amount = 27 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-5-steam-765-with-fuel-fluid-liquid-rubber",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 26 }, { type = "item", name = "steel-pipe", amount = 27 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-5-steam-765-with-fuel-fluid-liquid-resin",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 26 }, { type = "item", name = "steel-pipe", amount = 27 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-5-steam-765-with-fuel-fluid-liquid-styrene",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 26 }, { type = "item", name = "steel-pipe", amount = 27 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-5-steam-765-with-fuel-fluid-liquid-ethylbenzene",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 26 }, { type = "item", name = "steel-pipe", amount = 27 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-5-steam-765-with-fuel-fluid-liquid-polyethylene",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 26 }, { type = "item", name = "steel-pipe", amount = 27 } }
	)
	recipeUtil.add_recipe_ingredients(
		"oil-steam-boiler-5-steam-765-with-fuel-fluid-liquid-toluene",
		mode,
		{ { type = "item", name = "steel-furnace", amount = 26 }, { type = "item", name = "steel-pipe", amount = 27 } }
	)
	--конец жидкие котлы
	--биобойлеры
	recipeUtil.add_recipe_ingredients(
		"bi-bio-boiler-steam-165-with-fuel-item-small-alien-artifact-red",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"bi-bio-boiler-steam-165-with-fuel-item-small-alien-artifact-yellow",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"bi-bio-boiler-steam-165-with-fuel-item-small-alien-artifact-orange",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"bi-bio-boiler-steam-165-with-fuel-item-small-alien-artifact-blue",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"bi-bio-boiler-steam-165-with-fuel-item-small-alien-artifact-purple",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"bi-bio-boiler-steam-165-with-fuel-item-small-alien-artifact-green",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"bi-bio-boiler-steam-165-with-fuel-item-small-alien-artifact",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"bi-bio-boiler-steam-165-with-fuel-item-coal",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"bi-bio-boiler-steam-165-with-fuel-item-wood",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"bi-bio-boiler-steam-165-with-fuel-item-solid-carbon",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"bi-bio-boiler-steam-165-with-fuel-item-coal-crushed",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"bi-bio-boiler-steam-165-with-fuel-item-solid-coke",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	recipeUtil.add_recipe_ingredients(
		"bi-bio-boiler-steam-165-with-fuel-item-wood-charcoal",
		mode,
		{ { type = "item", name = "stone-furnace", amount = 4 }, { type = "item", name = "pipe", amount = 4 } }
	)
	-- конец биобойлеры
end
_table.each(GAME_MODES, function(mode)
	remove_recipe_ingredients(mode)
	add_recipe_ingredients(mode)
end)

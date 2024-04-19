require("resource-detected-technology-creating")
require("link-basic-technologies-to-regular-tree")
require("__hardcore-mode-for-playing__.prototypes.fuel-category.fuel-category-prototype-updates")
require("__hardcore-mode-for-playing__.prototypes.steam-processing.main")
require("__hardcore-mode-for-playing__.prototypes.burner-prototypes.main")
require(
	"__make-moded-technology-tree-mods-protocol__.prototypes.copying-for-modes.copy-to-normal-expensive-mode-recipe-data"
)

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

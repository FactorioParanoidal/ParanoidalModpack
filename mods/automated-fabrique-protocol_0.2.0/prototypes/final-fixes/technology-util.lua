local TechUtil = {}
local RecipeUtil = require('recipe-util')

local function getTechnologyObjectForMode(technology_name, mode)
	return Utils.getModedObject(data.raw["technology"][technology_name], mode)
end

local function filterTechnologyEffectUnlockRecipe(effect)
	return effect and effect.type == 'unlock-recipe' and effect.recipe and
		not RecipeUtil.isContainDry411Srev(effect.recipe)
end

local function getTechnologyObjectEffectRecipesByName(technology_name, mode)
	local technology_object = getTechnologyObjectForMode(technology_name, mode)
	if not technology_object or not technology_object.effects then
		return {}
	end
	return _table.filter(technology_object.effects,
		filterTechnologyEffectUnlockRecipe)
end

TechUtil.getAllRecipesIngredientsForSpecifiedTechnology = function(technology_name, mode)
	local result = {}
	local unlocked_recipes = getTechnologyObjectEffectRecipesByName(technology_name, mode)
	_table.each(unlocked_recipes,
		function(unlocked_recipe)
			local recipe_name = unlocked_recipe.recipe
			local ingredients = RecipeUtil.getAllRecipeIngredients(recipe_name, mode)
			_table.insert_all_if_not_exists(result, ingredients)
		end)
	return result
end

TechUtil.getAllRecipesResultsForSpecifiedTechnology = function(technology_name, mode)
	local result = {}
	local unlocked_recipes = getTechnologyObjectEffectRecipesByName(technology_name, mode)
	_table.each(unlocked_recipes,
		function(unlocked_recipe)
			local recipe_name = unlocked_recipe.recipe
			local results = RecipeUtil.getAllRecipeResults(recipe_name, mode)
			_table.insert_all_if_not_exists(result, results)
		end)
	return result
end

TechUtil.getAllUnitsForSpecifiedTechnology = function(technology_name, mode)
	local result = {}
	local technology_object = getTechnologyObjectForMode(technology_name, mode)
	if not technology_object or not technology_object.unit or not technology_object.unit.ingredients then
		return
	end
	_table.each(technology_object.unit.ingredients,
		function(research_unit_ingredient)
			local ingredient_name = research_unit_ingredient.name or research_unit_ingredient[1]
			local research_unit_ingredient_type = research_unit_ingredient.type or "item"
			table.insert(result, { type = research_unit_ingredient_type, name = ingredient_name })
		end)
	return result
end

return TechUtil

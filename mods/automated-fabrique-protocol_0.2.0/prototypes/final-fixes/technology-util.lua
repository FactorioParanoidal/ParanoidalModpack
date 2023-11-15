local TechUtil = {}
local RecipeUtil = require("recipe-util")
local function getTechnologyObjectForMode(technology_name, mode)
	return Utils.getModedObject(data.raw["technology"][technology_name], mode)
end

local function filterTechnologyEffectUnlockRecipe(effect)
	return effect
		and effect.type == "unlock-recipe"
		and effect.recipe
		and not RecipeUtil.isContainDry411Srev(effect.recipe)
end

local function getTechnologyObjectEffectRecipesByName(technology_name, mode)
	local technology_object = getTechnologyObjectForMode(technology_name, mode)
	if not technology_object or not technology_object.effects then
		return {}
	end
	return _table.filter(technology_object.effects, filterTechnologyEffectUnlockRecipe)
end

TechUtil.getAllRecipesIngredientsForSpecifiedTechnology = function(technology_name, mode)
	local result = {}
	local unlocked_recipes = getTechnologyObjectEffectRecipesByName(technology_name, mode)
	_table.each(unlocked_recipes, function(unlocked_recipe)
		local recipe_name = unlocked_recipe.recipe
		local ingredients = RecipeUtil.getAllRecipeIngredients(recipe_name, mode)
		_table.insert_all_if_not_exists(result, ingredients)
	end)
	return result
end

TechUtil.getAllRecipesResultsForSpecifiedTechnology = function(technology_name, mode)
	local result = {}
	local unlocked_recipes = getTechnologyObjectEffectRecipesByName(technology_name, mode)
	_table.each(unlocked_recipes, function(unlocked_recipe)
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
	_table.each(technology_object.unit.ingredients, function(research_unit_ingredient)
		local ingredient_name = research_unit_ingredient.name or research_unit_ingredient[1]
		local research_unit_ingredient_type = research_unit_ingredient.type or "item"
		table.insert(result, { type = research_unit_ingredient_type, name = ingredient_name })
	end)
	return result
end

TechUtil.getAllRecipesNamesForSpecifiedTechnology = function(technology_name, mode)
	return _table.map(getTechnologyObjectEffectRecipesByName(technology_name, mode), function(unlocked_recipe)
		return unlocked_recipe.recipe
	end)
end

local function technologyNotFound()
	error("technology is null!!")
end
local function getModedTechnology(technology_candidate, mode)
	if type(technology_candidate) ~= "table" then
		error("technology must be a table but got " .. type(technology_candidate))
	end
	if not technology_candidate then
		technologyNotFound()
	end
	local result = Utils.getModedObject(technology_candidate, mode)
	if not result then
		error("mode " .. mode .. "for techology " .. result.name .. " not specified!!")
	end
	return result
end
TechUtil.addPrerequisitesToTechnology = function(technology_candidate, prerequisites, mode)
	if not prerequisites then
		error("prerequisites not specified")
	end
	local technology = getModedTechnology(technology_candidate, mode)
	if technology.prerequisites then
		_table.insert_all_if_not_exists(technology.prerequisites, prerequisites)
	else
		technology.prerequisites = prerequisites
	end
end
TechUtil.removePrerequisitesFromTechnology = function(technology_candidate, prerequisites, mode)
	if not prerequisites then
		error("prerequisites not specified")
	end
	local technology = getModedTechnology(technology_candidate, mode)
	if not technology.prerequisites then
		error("try to remove from not exists prerequisistes")
	end
	_table.each(prerequisites, function(prerequisite)
		_table.remove_item(technology.prerequisites, prerequisite)
	end)
end

TechUtil.resetTechnologyPrerequisites = function(technology_candidate, prerequisites, mode)
	if not prerequisites then
		error("prerequisites not specified")
	end
	local technology = getModedTechnology(technology_candidate, mode)
	if technology.prerequisites then
		technology.prerequisites = nil
	end
	TechUtil.addPrerequisitesToTechnology(technology_candidate, prerequisites, mode)
end
TechUtil.addRecipeEffectToTechnologyEffects = function(technology_candidate, recipe_name, mode)
	local technology = getModedTechnology(technology_candidate, mode)
	if not recipe_name then
		error("recipe_name not specified!")
	end
	if not technology.effects then
		technology.effects = {}
	end
	table.insert(technology.effects, { type = "unlock-recipe", recipe = recipe_name })
	local recipe = Utils.getModedObject(data.raw.recipe[recipe_name], mode)
	if not recipe then
		error("recipe with name " .. recipe_name .. " not found!")
	end
	recipe.enabled = false
end

TechUtil.removeRecipeEffectFromTechnologyEffects = function(technology_candidate, recipe_name, mode)
	local technology = getModedTechnology(technology_candidate, mode)
	if not recipe_name then
		error("recipe_name not specified!")
	end
	if not technology.effects then
		error("technology effects not specified!")
	end
	_table.remove_item(technology.effects, { type = "unlock-recipe", recipe = recipe_name })
end

local function addSciencePackToTechnologyUnit(technology_candidate, ingredient_value, mode)
	if not ingredient_value then
		error("ingredient_value not specified")
	end
	local ingredient = {
		type = "item",
		name = ingredient_value[1],
		amount = ingredient_value[2],
	}
	local technology = getModedTechnology(technology_candidate, mode)
	if technology.unit and technology.unit.ingredients then
		_table.insert_all_if_not_exists(technology.unit.ingredients, { ingredient })
	end
end
TechUtil.addSciencePacksToTechnologyUnits = function(technology_candidate, technology_units, mode)
	if not technology_units then
		error("technology_units not specified")
	end
	_table.each(technology_units, function(technology_unit)
		addSciencePackToTechnologyUnit(technology_candidate, technology_unit, mode)
	end)
end
TechUtil.removeSciencePackFrom = function(technology_candidate, science_pack_name, mode)
	if not science_pack_name then
		error("science_pack_name not specified")
	end
	local technology = getModedTechnology(technology_candidate, mode)
	_table.remove_item(technology.unit.ingredients, science_pack_name, function(table_item, item_for_remove)
		return table_item[1] == item_for_remove
	end)
end

TechUtil.hideTechnology = function(technology_candidate, mode)
	local technology = getModedTechnology(technology_candidate, mode)
	technology.hidden = true
end

TechUtil.getAllTechnologiesWithRecipeFluidResultSpecifiedInAnotherRecipeByName = function(recipe_name, mode)
	local fluids = _table.filter(RecipeUtil.getAllRecipeIngredients(recipe_name, mode), function(result_data)
		return result_data.type == "fluid"
	end)
	if _table.size(fluids) ~= 1 then
		return {}
	end
	local target_fluid = fluids[1]
	local technology_names = TechUtil.getAllActiveTechnologyNames()
	return _table.filter(technology_names, function(technology_name)
		local results = TechUtil.getAllRecipesResultsForSpecifiedTechnology(technology_name, mode)
		return _table.contains_f_deep(results, target_fluid)
	end)
end

TechUtil.getAllActiveTechnologyNames = function()
	local result = {}
	_table.each(data.raw["technology"], function(technology)
		local technology_name = technology.name
		if not technology.hidden then --and filterTechnologyDataHasRecipes(technology_name, mode) then
			table.insert(result, technology_name)
		end
	end)
	return result
end

TechUtil.getAllTechnologyNamesWithHidden = function()
	return _table.map(data.raw["technology"], function(technology)
		return technology.name
	end)
end

return TechUtil

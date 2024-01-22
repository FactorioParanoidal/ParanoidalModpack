local techUtil = require("__automated-utility-protocol__.util.technology-util")
local recipeUtil = require("__automated-utility-protocol__.util.recipe-util")
local TechnologyLeafHandlerMissedIngredientsInTechnologyTreeStep = {}

TechnologyLeafHandlerMissedIngredientsInTechnologyTreeStep.excluded_item_science_pack =
	{ type = "item", name = "salvaged-automation-science-pack" }
local function filterTechnologyNameCandidatePredicate(
	technology_name_candidate,
	mode,
	effect_ingredient_not_found_in_current_tree
)
	local products = EvaluatingStepStatusHolder.getEffectResultsFromTechnologyStatus(mode, technology_name_candidate)
	return _table.contains_f(products, function(product)
		--[[	log('technology_name_candidate ' ..
				technology_name_candidate .. ',product.type ' .. product.type ..
				',product.name ' .. product.name)]]
		return effect_ingredient_not_found_in_current_tree.type == product.type
			and effect_ingredient_not_found_in_current_tree.name == product.name
	end)
end
local function filterAllAvaliableTechnologiesWithIngredient(
	all_found_technology_names,
	mode,
	effect_ingredient_not_found_in_current_tree
)
	return _table.filter(all_found_technology_names, function(found_technology_name)
		return filterTechnologyNameCandidatePredicate(
			found_technology_name,
			mode,
			effect_ingredient_not_found_in_current_tree
		)
	end)
end
local function printInfoForAvailableForIngredientsTechnologyNames(
	available_technology_name_for_ingredients,
	technology_name,
	mode
)
	local basic_units = EvaluatingStepStatusHolder.getUnitsFromTechnologyStatus(mode, technology_name)
	local units =
		EvaluatingStepStatusHolder.getUnitsFromTechnologyStatus(mode, available_technology_name_for_ingredients)
	local diff_units = _table.deep_copy(units)
	_table.each(basic_units, function(basic_unit)
		_table.remove_item(diff_units, basic_unit, nil, true)
	end)
	log(
		available_technology_name_for_ingredients
			.. " has missing for current technology units "
			.. Utils.dump_to_console(diff_units)
	)
	log(
		"results for "
			.. available_technology_name_for_ingredients
			.. " are "
			.. Utils.dump_to_console(
				EvaluatingStepStatusHolder.getEffectResultsFromTechnologyStatus(
					mode,
					available_technology_name_for_ingredients
				)
			)
	)
	log(
		available_technology_name_for_ingredients
			.. " is "
			.. Utils.dump_to_console(data.raw["technology"][available_technology_name_for_ingredients])
	)
	local cyclingCandidates = EvaluatingStepStatusHolder.getOccursTechnologyInAnotherTechnologyTree(
		available_technology_name_for_ingredients,
		technology_name,
		mode
	)
	if _table.size(cyclingCandidates) > 0 then
		log(
			technology_name
				.. " contains in tree of "
				.. available_technology_name_for_ingredients
				.. " in following technologies "
				.. Utils.dump_to_console(cyclingCandidates)
		)
	end
end

local function getAnotherTreesHandlingErrorMessage(
	effect_ingredient_not_found_in_current_tree,
	technology_name,
	mode,
	available_technology_names_for_ingredients,
	technologyPropertiesEvaluatingStep
)
	local all_found_technology_names = EvaluatingStepStatusHolder.getAllTechnologyNames(mode)
	local available_technology_names_for_missed_ingredient = filterAllAvaliableTechnologiesWithIngredient(
		all_found_technology_names,
		mode,
		effect_ingredient_not_found_in_current_tree
	)
	local all_with_hidden_technology_names = techUtil.getAllTechnologyNamesWithHidden()
	local result = "all with hidden technology names "
		.. Utils.dump_to_console(all_with_hidden_technology_names)
		.. "\n"
	EvaluatingStepStatusHolder.initForMode(mode)
	TechnologyTreeCacheUtil.cleanupTechnologyTreeCache(mode)
	TechnologyTreeCacheUtil.initTechnologyTreeCache(mode)
	_table.each(all_with_hidden_technology_names, function(all_with_hidden_technology_name)
		technologyPropertiesEvaluatingStep.evaluate(all_with_hidden_technology_name, mode, true)
	end)
	local all_with_hidden_technology_names_for_missed_ingredient = filterAllAvaliableTechnologiesWithIngredient(
		all_with_hidden_technology_names,
		mode,
		effect_ingredient_not_found_in_current_tree
	)

	local effect_ingredient_not_found_in_current_tree_name = effect_ingredient_not_found_in_current_tree.name
		or effect_ingredient_not_found_in_current_tree[1]
	result = result
		.. "with ingredient as result "
		.. effect_ingredient_not_found_in_current_tree_name
		.. " all ACTIVE technologies "
		.. Utils.dump_to_console(available_technology_names_for_missed_ingredient)
		.. "\n"
	result = result
		.. "with ingredient as result "
		.. effect_ingredient_not_found_in_current_tree_name
		.. " all WITH HIDDEN technologies "
		.. Utils.dump_to_console(all_with_hidden_technology_names_for_missed_ingredient)
		.. "\n"
	_table.each(
		available_technology_names_for_missed_ingredient,
		function(available_technology_name_for_missed_ingredient)
			printInfoForAvailableForIngredientsTechnologyNames(
				available_technology_name_for_missed_ingredient,
				technology_name,
				mode
			)
		end
	)
	result = result
		.. 'data.raw["technology"]['
		.. technology_name
		.. "]"
		.. Utils.dump_to_console(data.raw["technology"][technology_name])
		.. "\n"
	result = result
		.. "technology tree of "
		.. technology_name
		.. " is "
		.. Utils.dump_to_console(TechnologyTreeUtil.findPrerequisitesForTechnologyForAllLevels(technology_name, mode))
		.. "\n"
	result = result
		.. "available_technology_names_for_ingredients "
		.. Utils.dump_to_console(available_technology_names_for_ingredients)
		.. "\n"
	_table.each(available_technology_names_for_ingredients, function(available_technology_name_for_ingredients)
		printInfoForAvailableForIngredientsTechnologyNames(
			available_technology_name_for_ingredients,
			technology_name,
			mode
		)
	end)
	EvaluatingStepStatusHolder.cleanupForMode(mode)
	TechnologyTreeCacheUtil.cleanupTechnologyTreeCache(mode)
	local recipe_names = techUtil.getAllRecipesNamesForSpecifiedTechnology(technology_name, mode)
	local available_recipe_names_for_ingredient = _table.filter(recipe_names, function(recipe_name)
		return _table.contains_f_deep(
			recipeUtil.getAllRecipeIngredients(recipe_name, mode),
			effect_ingredient_not_found_in_current_tree
		)
	end)

	result = result
		.. "for technology "
		.. technology_name
		.. " for mode "
		.. mode
		.. " keep unresolved "
		.. Utils.dump_to_console(effect_ingredient_not_found_in_current_tree)
		.. " ingredient dependency! Contained recipe names: "
		.. Utils.dump_to_console(available_recipe_names_for_ingredient)
		.. "\n"
	return result
end

local function raiseErrorUnresolvedIngredientInTechnologyTree(
	technology_name,
	mode,
	unresolved_ingredient,
	technologyPropertiesEvaluatingStep
)
	log("\nhandle unresolved ingredient")
	local all_found_technology_names =
		EvaluatingStepStatusHolder.getTechnologyNamesWithCompatiableSciencePack(mode, technology_name)
	local available_technology_names_for_ingredients =
		filterAllAvaliableTechnologiesWithIngredient(all_found_technology_names, mode, unresolved_ingredient)
	local error_message = getAnotherTreesHandlingErrorMessage(
		unresolved_ingredient,
		technology_name,
		mode,
		available_technology_names_for_ingredients,
		technologyPropertiesEvaluatingStep
	)
	log("\nunresolved ingredient handled")
	error(error_message)
end

local function isUnresolvedIngredientInTechnologyProductList(ingredient, products, technology_name, mode)
	return not _table.contains_f(products, function(product)
		return ingredient.type == product.type and ingredient.name == product.name
	end)
end
local function writeMissedIngredientsInTechnologyTreeToTechnologyStatus(technology_name, mode)
	local result = {}
	local recipe_ingredients =
		EvaluatingStepStatusHolder.getEffectIngredientsFromTechnologyStatus(mode, technology_name)
	local technology_unit_ingredients = EvaluatingStepStatusHolder.getUnitsFromTechnologyStatus(mode, technology_name)
	local all_need_ingredients_for_technology_research = {}
	_table.insert_all_if_not_exists(all_need_ingredients_for_technology_research, recipe_ingredients)
	_table.insert_all_if_not_exists(all_need_ingredients_for_technology_research, technology_unit_ingredients)
	local products = EvaluatingStepStatusHolder.getEffectResultsFromTechnologyStatus(mode, technology_name)
	_table.each(all_need_ingredients_for_technology_research, function(ingredient)
		if isUnresolvedIngredientInTechnologyProductList(ingredient, products, technology_name, mode) then
			table.insert(result, ingredient)
		end
	end)
	return result
end
local function tryToResolveRecipeIngregientInHerselfTreeRecipeProducts(
	technology_name,
	mode,
	unresolved_ingredients,
	technologyPropertiesEvaluatingStep
)
	if not unresolved_ingredients or _table.size(unresolved_ingredients) == 0 then
		return
	end
	local all_technology_candidate_names =
		TechnologyTreeUtil.findPrerequisitesForTechnologyForAllLevels(technology_name, mode)
	table.insert(all_technology_candidate_names, technology_name)
	local all_recipe_products_by_technologies = _table.map(
		all_technology_candidate_names,
		function(technology_candidate_name)
			return {
				technology_name = technology_candidate_name,
				products = EvaluatingStepStatusHolder.getEffectResultsFromTechnologyStatus(
					mode,
					technology_candidate_name
				),
			}
		end
	)
	_table.each(unresolved_ingredients, function(unresolved_ingredient)
		local found = false
		_table.each(all_recipe_products_by_technologies, function(all_recipe_products_by_technology)
			if found then
				return
			end
			local products = all_recipe_products_by_technology.products
			if
				_table.contains_f(products, function(product)
					return unresolved_ingredient.type == product.type and unresolved_ingredient.name == product.name
				end)
			then
				found = true
			end
		end)
		if not found then
			raiseErrorUnresolvedIngredientInTechnologyTree(
				technology_name,
				mode,
				unresolved_ingredient,
				technologyPropertiesEvaluatingStep
			)
		end
	end)
end
TechnologyLeafHandlerMissedIngredientsInTechnologyTreeStep.evaluate = function(
	technology_name,
	mode,
	technologyPropertiesEvaluatingStep
)
	if EvaluatingStepStatusHolder.isVisitedTechnology(mode, technology_name) then
		return
	end
	EvaluatingStepStatusHolder.markTechnologyAsVisited(mode, technology_name)

	local unresolved_ingredients = writeMissedIngredientsInTechnologyTreeToTechnologyStatus(technology_name, mode)
	tryToResolveRecipeIngregientInHerselfTreeRecipeProducts(
		technology_name,
		mode,
		unresolved_ingredients,
		technologyPropertiesEvaluatingStep
	)
	local dependencies = EvaluatingStepStatusHolder.getTreeFromTechnologyStatus(mode, technology_name)
	_table.each(dependencies, function(dependency_name)
		TechnologyLeafHandlerMissedIngredientsInTechnologyTreeStep.evaluate(
			dependency_name,
			mode,
			technologyPropertiesEvaluatingStep
		)
	end)
end

return TechnologyLeafHandlerMissedIngredientsInTechnologyTreeStep

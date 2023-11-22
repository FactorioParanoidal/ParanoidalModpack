local AnotherTechnologyTreeResolvingStep = {}

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

local function raiseAnotherTreesHandlingError(
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
	log("all with hidden technology names " .. Utils.dump_to_console(all_with_hidden_technology_names))
	EvaluatingStepStatusHolder.initForMode(mode)
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
	log(
		"with ingredient as result "
			.. effect_ingredient_not_found_in_current_tree_name
			.. " all ACTIVE technologies "
			.. Utils.dump_to_console(available_technology_names_for_missed_ingredient)
	)
	log(
		"with ingredient as result "
			.. effect_ingredient_not_found_in_current_tree_name
			.. " all WITH HIDDEN technologies "
			.. Utils.dump_to_console(all_with_hidden_technology_names_for_missed_ingredient)
	)
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
	log(
		'data.raw["technology"]['
			.. technology_name
			.. "]"
			.. Utils.dump_to_console(data.raw["technology"][technology_name])
	)
	log(
		"available_technology_names_for_ingredients "
			.. Utils.dump_to_console(available_technology_names_for_ingredients)
	)
	_table.each(available_technology_names_for_ingredients, function(available_technology_name_for_ingredients)
		printInfoForAvailableForIngredientsTechnologyNames(
			available_technology_name_for_ingredients,
			technology_name,
			mode
		)
	end)
	EvaluatingStepStatusHolder.cleanupForMode(mode)
	local recipe_names = techUtil.getAllRecipesNamesForSpecifiedTechnology(technology_name, mode)
	local available_recipe_names_for_ingredient = _table.filter(recipe_names, function(recipe_name)
		return _table.contains_f_deep(
			recipeUtil.getAllRecipeIngredients(recipe_name, mode),
			effect_ingredient_not_found_in_current_tree
		)
	end)

	error(
		"for technology "
			.. technology_name
			.. " for mode "
			.. mode
			.. " keep unresolved "
			.. Utils.dump_to_console(effect_ingredient_not_found_in_current_tree)
			.. " ingredient dependency! Contained recipe names: "
			.. Utils.dump_to_console(available_recipe_names_for_ingredient)
	)
end
local function handlePossibleError(
	effect_ingredient_not_found_in_current_tree,
	technology_name,
	mode,
	available_technology_names_for_ingredients,
	herselfTechnologyTreeResolvingStep,
	technologyPropertiesEvaluatingStep
)
	EvaluatingStepStatusHolder.markTechnologyWithTreeAsUnvisited(mode, technology_name)
	herselfTechnologyTreeResolvingStep.evaluate(technology_name, mode, {})
	if
		EvaluatingStepStatusHolder.hasResolvedStatusForIngredientForTechnology(
			effect_ingredient_not_found_in_current_tree,
			technology_name,
			mode
		)
	then
		log(
			"for technology "
				.. technology_name
				.. " effect_ingredient_not_found_in_current_tree "
				.. effect_ingredient_not_found_in_current_tree.name
				.. " resolved in herself tree after adding from another trees!"
		)
		return
	end
	raiseAnotherTreesHandlingError(
		effect_ingredient_not_found_in_current_tree,
		technology_name,
		mode,
		available_technology_names_for_ingredients,
		technologyPropertiesEvaluatingStep
	)
end
local function handleNotFoundIngredentInAnotherTrees(
	effect_ingredient_not_found_in_current_tree,
	mode,
	technology_name,
	herselfTechnologyTreeResolvingStep,
	technologyPropertiesEvaluatingStep
)
	local all_found_technology_names =
		EvaluatingStepStatusHolder.getTechnologyNamesWithCompatiableSciencePack(mode, technology_name)
	local available_technology_names_for_ingredients = filterAllAvaliableTechnologiesWithIngredient(
		all_found_technology_names,
		mode,
		effect_ingredient_not_found_in_current_tree
	)
	if _table.size(available_technology_names_for_ingredients) == 0 then
		handlePossibleError(
			effect_ingredient_not_found_in_current_tree,
			technology_name,
			mode,
			available_technology_names_for_ingredients,
			herselfTechnologyTreeResolvingStep,
			technologyPropertiesEvaluatingStep
		)
		return
	end
	for _, uncycled_tech_name_candidate in pairs(available_technology_names_for_ingredients) do
		-- если технологии в дереве нет, либо если данная технлогия УЖЕ пристутствует в в данном дереве после какого-то этапа считаем, что конфликт разрешён.
		if
			not TechnologyTreeUtil.haveTechnologyInTree(uncycled_tech_name_candidate, technology_name, mode)
			or TechnologyTreeUtil.haveTechnologyInTree(technology_name, uncycled_tech_name_candidate, mode)
		then
			EvaluatingStepStatusHolder.resolveNotFoundIngredientsFromTechnologyStatus(
				mode,
				technology_name,
				effect_ingredient_not_found_in_current_tree,
				uncycled_tech_name_candidate,
				false
			)
			return
		end
	end
	handlePossibleError(
		effect_ingredient_not_found_in_current_tree,
		technology_name,
		mode,
		available_technology_names_for_ingredients,
		herselfTechnologyTreeResolvingStep,
		technologyPropertiesEvaluatingStep
	)
end

local function resolvingNotFoundIngredientsInAnotherTechnologyTree(
	mode,
	technology_name,
	herSelfTechnologyTreeResolvingStep,
	technologyPropertiesEvaluatingStep
)
	local effect_ingredients_not_found_in_current_tree =
		EvaluatingStepStatusHolder.getNotFoundIngredientsFromTechnologyStatus(mode, technology_name)
	local loggable = _table.size(effect_ingredients_not_found_in_current_tree) > 0
	if loggable then
		log(
			"mode "
				.. mode
				.. " for "
				.. technology_name
				.. " resolving not found ingredient start. Count unresolved ingredients: "
				.. tostring(_table.size(effect_ingredients_not_found_in_current_tree))
		)
	end
	_table.each(effect_ingredients_not_found_in_current_tree, function(effect_ingredient_not_found_in_current_tree)
		handleNotFoundIngredentInAnotherTrees(
			effect_ingredient_not_found_in_current_tree,
			mode,
			technology_name,
			herSelfTechnologyTreeResolvingStep,
			technologyPropertiesEvaluatingStep
		)
	end)
	if loggable then
		log("mode " .. mode .. " for " .. technology_name .. " resolving not found ingredient end")
	end
end

AnotherTechnologyTreeResolvingStep.evaluate = function(
	technology_name,
	mode,
	herselfTechnologyTreeResolvingStep,
	technologyPropertiesEvaluatingStep
)
	if EvaluatingStepStatusHolder.isVisitedTechnology(mode, technology_name) then
		return
	end
	EvaluatingStepStatusHolder.markTechnologyAsVisited(mode, technology_name)
	-- защита от копирования зависимостей.
	local dependencies = EvaluatingStepStatusHolder.getTreeFromTechnologyStatus(mode, technology_name)

	resolvingNotFoundIngredientsInAnotherTechnologyTree(
		mode,
		technology_name,
		herselfTechnologyTreeResolvingStep,
		technologyPropertiesEvaluatingStep
	)

	if not dependencies then
		return
	end
	_table.each(dependencies, function(dependency_name)
		AnotherTechnologyTreeResolvingStep.evaluate(
			dependency_name,
			mode,
			herselfTechnologyTreeResolvingStep,
			technologyPropertiesEvaluatingStep
		)
	end)
end
return AnotherTechnologyTreeResolvingStep

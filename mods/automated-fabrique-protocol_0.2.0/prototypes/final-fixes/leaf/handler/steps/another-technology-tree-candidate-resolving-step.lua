local AnotherTechnologyTreeResolvingStep = {}

local function filterTechnologyNameCandatePredicate(
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
		return filterTechnologyNameCandatePredicate(
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
	available_technology_names_for_ingredients
)
	local all_found_technology_names = EvaluatingStepStatusHolder.getAllTechnologyNames(mode)
	local available_technology_names_for_missed_ingredient = filterAllAvaliableTechnologiesWithIngredient(
		all_found_technology_names,
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
	log(Utils.dump_to_console(data.raw["technology"][technology_name]))
	log(Utils.dump_to_console(available_technology_names_for_ingredients))
	_table.each(available_technology_names_for_ingredients, function(available_technology_name_for_ingredients)
		printInfoForAvailableForIngredientsTechnologyNames(
			available_technology_name_for_ingredients,
			technology_name,
			mode
		)
	end)
	error(
		"for technology "
			.. technology_name
			.. " keep unresolved "
			.. effect_ingredient_not_found_in_current_tree_name
			.. " ingredient dependency!"
	)
end
local function handlePossibleError(
	effect_ingredient_not_found_in_current_tree,
	technology_name,
	mode,
	available_technology_names_for_ingredients,
	herselfTechnologyTreeResolvingStep
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
		available_technology_names_for_ingredients
	)
end
local function handleNotFoundIngredentInAnotherTrees(
	effect_ingredient_not_found_in_current_tree,
	mode,
	technology_name,
	herselfTechnologyTreeResolvingStep
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
			herselfTechnologyTreeResolvingStep
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
		herselfTechnologyTreeResolvingStep
	)
end

local function resolvingNotFoundIngredientsInAnotherTechnologyTree(
	mode,
	technology_name,
	herSelfTechnologyTreeResolvingStep
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
			herSelfTechnologyTreeResolvingStep
		)
	end)
	if loggable then
		log("mode " .. mode .. " for " .. technology_name .. " resolving not found ingredient end")
	end
end

AnotherTechnologyTreeResolvingStep.evaluate = function(technology_name, mode, herselfTechnologyTreeResolvingStep)
	if EvaluatingStepStatusHolder.isVisitedTechnology(mode, technology_name) then
		return
	end
	EvaluatingStepStatusHolder.markTechnologyAsVisited(mode, technology_name)
	-- защита от копирования зависимостей.
	local dependencies = EvaluatingStepStatusHolder.getTreeFromTechnologyStatus(mode, technology_name)

	resolvingNotFoundIngredientsInAnotherTechnologyTree(mode, technology_name, herselfTechnologyTreeResolvingStep)

	if not dependencies then
		return
	end
	_table.each(dependencies, function(dependency_name)
		AnotherTechnologyTreeResolvingStep.evaluate(dependency_name, mode, herselfTechnologyTreeResolvingStep)
	end)
end
return AnotherTechnologyTreeResolvingStep

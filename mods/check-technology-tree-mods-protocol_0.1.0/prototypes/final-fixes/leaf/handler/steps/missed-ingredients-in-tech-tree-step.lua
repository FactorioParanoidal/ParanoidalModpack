local TechnologyLeafHandlerMissedIngredientsInTechnologyTreeStep = {}

local function handleIngredientInTechnologyIngredientsList(ingredient, products, technology_name, mode)
	if
		not _table.contains_f(products, function(product)
			return ingredient.type == product.type and ingredient.name == product.name
		end)
	then
		EvaluatingStepStatusHolder.addNotFoundIngredientToTechnologyStatus(mode, technology_name, ingredient)
	end
end
local function writeMissedIngredientsInTechnologyTreeToTechnologyStatus(technology_name, mode)
	local recipe_ingredients =
		EvaluatingStepStatusHolder.getEffectIngredientsFromTechnologyStatus(mode, technology_name)
	local technology_unit_ingredients = EvaluatingStepStatusHolder.getUnitsFromTechnologyStatus(mode, technology_name)
	local all_need_ingredients_for_technology_research = {}
	_table.insert_all_if_not_exists(all_need_ingredients_for_technology_research, recipe_ingredients)
	_table.insert_all_if_not_exists(all_need_ingredients_for_technology_research, technology_unit_ingredients)
	local products = EvaluatingStepStatusHolder.getEffectResultsFromTechnologyStatus(mode, technology_name)
	_table.each(all_need_ingredients_for_technology_research, function(ingredient)
		handleIngredientInTechnologyIngredientsList(ingredient, products, technology_name, mode)
	end)
end
local function tryToResolveRecipeIngregientInHerselfTreeRecipeProducts(technology_name, mode)
	local unresolved_ingredients =
		EvaluatingStepStatusHolder.getNotFoundIngredientsFromTechnologyStatus(mode, technology_name)
	if not unresolved_ingredients or _table.size(unresolved_ingredients) == 0 then
		return
	end
	log("try to resolve technology_name " .. technology_name .. " unresolved_ingredients")
	local all_prerequisite_names = TechnologyTreeUtil.findPrerequisitesForTechnologyForAllLevels(technology_name, mode)
	-- добавляем себя в список
	table.insert(all_prerequisite_names, technology_name)
	local all_recipe_products_by_technologies = _table.map(all_prerequisite_names, function(prerequisite_name)
		return {
			technology_name = prerequisite_name,
			products = EvaluatingStepStatusHolder.getEffectResultsFromTechnologyStatus(mode, prerequisite_name),
		}
	end)
	_table.each(unresolved_ingredients, function(unresolved_ingredient)
		local found = false
		_table.each(all_recipe_products_by_technologies, function(all_recipe_products_by_technology)
			if found then
				return
			end
			local technology_candidate_name = all_recipe_products_by_technology.technology_name
			local products = all_recipe_products_by_technology.products
			if _table.contains_f_deep(products, unresolved_ingredient) then
				found = true
				EvaluatingStepStatusHolder.resolveNotFoundIngredientsFromTechnologyStatus(
					mode,
					technology_name,
					unresolved_ingredient,
					technology_candidate_name,
					false
				)
			end
		end)
	end)
end
TechnologyLeafHandlerMissedIngredientsInTechnologyTreeStep.evaluate = function(technology_name, mode)
	if EvaluatingStepStatusHolder.isVisitedTechnology(mode, technology_name) then
		return
	end
	EvaluatingStepStatusHolder.markTechnologyAsVisited(mode, technology_name)

	writeMissedIngredientsInTechnologyTreeToTechnologyStatus(technology_name, mode)
	tryToResolveRecipeIngregientInHerselfTreeRecipeProducts(technology_name, mode)
	local dependencies = EvaluatingStepStatusHolder.getTreeFromTechnologyStatus(mode, technology_name)
	if not dependencies then
		return
	end
	_table.each(dependencies, function(dependency_name)
		TechnologyLeafHandlerMissedIngredientsInTechnologyTreeStep.evaluate(dependency_name, mode)
	end)
end

return TechnologyLeafHandlerMissedIngredientsInTechnologyTreeStep

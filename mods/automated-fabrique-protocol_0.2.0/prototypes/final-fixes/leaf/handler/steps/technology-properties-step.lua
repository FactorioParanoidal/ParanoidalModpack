local TechnologyLeafHandlerTechnologyPropertiesStep = {}

local function writeTechnologyPropertiesToTechnologyStatus(technology_name, mode, first_level_parents)
	EvaluatingStepStatusHolder.addTreeToTechnologyStatus(mode, technology_name, first_level_parents)
	EvaluatingStepStatusHolder.addEffectIngredientsToTechnologyStatus(
		mode,
		technology_name,
		techUtil.getAllRecipesIngredientsForSpecifiedTechnology(technology_name, mode)
	)
	EvaluatingStepStatusHolder.addEffectResultsToTechnologyStatus(
		mode,
		technology_name,
		techUtil.getAllRecipesResultsForSpecifiedTechnology(technology_name, mode)
	)
	EvaluatingStepStatusHolder.addUnitsToTechnologyStatus(
		mode,
		technology_name,
		techUtil.getAllUnitsForSpecifiedTechnology(technology_name, mode)
	)
end

TechnologyLeafHandlerTechnologyPropertiesStep.evaluate = function(technology_name, mode)
	if EvaluatingStepStatusHolder.isVisitedTechnology(mode, technology_name) then
		return
	end
	EvaluatingStepStatusHolder.markTechnologyAsVisited(mode, technology_name)
	EvaluatingStepStatusHolder.initForModeAndTechnology(mode, technology_name)
	local first_level_parents = TechnologyTreeUtil.findParentsForTechnologyForFirstLevel(technology_name, mode)

	writeTechnologyPropertiesToTechnologyStatus(technology_name, mode, first_level_parents or {})

	if not first_level_parents then
		return
	end
	_table.each(first_level_parents, function(dependency_name)
		TechnologyLeafHandlerTechnologyPropertiesStep.evaluate(dependency_name, mode)
	end)
end
return TechnologyLeafHandlerTechnologyPropertiesStep

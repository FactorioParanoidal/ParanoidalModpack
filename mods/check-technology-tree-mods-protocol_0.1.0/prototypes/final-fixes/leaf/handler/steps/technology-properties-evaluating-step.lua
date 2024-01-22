local techUtil = require("__automated-utility-protocol__.util.technology-util")
local TechnologyLeafHandlerTechnologyPropertiesStep = {}

local function writeTechnologyPropertiesToTechnologyStatus(technology_name, mode, first_level_parents)
	EvaluatingStepStatusHolder.addTreeToTechnologyStatus(mode, technology_name, first_level_parents)
	local recipe_ingredients = techUtil.getAllRecipesIngredientsForSpecifiedTechnology(technology_name, mode)
	EvaluatingStepStatusHolder.addEffectIngredientsToTechnologyStatus(mode, technology_name, recipe_ingredients)
	local recipe_results = techUtil.getAllRecipesResultsForSpecifiedTechnology(technology_name, mode)
	EvaluatingStepStatusHolder.addEffectResultsToTechnologyStatus(mode, technology_name, recipe_results)
	local tool_units = techUtil.getAllUnitsForSpecifiedTechnology(technology_name, mode)
	EvaluatingStepStatusHolder.addUnitsToTechnologyStatus(mode, technology_name, tool_units)
	log(
		"for technology "
			.. technology_name
			.. " mode "
			.. mode
			.. "\ntree is "
			.. Utils.dump_to_console(first_level_parents)
			.. "\nrecipe_ingredients are "
			.. Utils.dump_to_console(recipe_ingredients)
			.. "\nrecipe_results are "
			.. Utils.dump_to_console(recipe_results)
			.. "\ntechnology_units are "
			.. Utils.dump_to_console(tool_units)
	)
end

TechnologyLeafHandlerTechnologyPropertiesStep.evaluate = function(technology_name, mode)
	if EvaluatingStepStatusHolder.isVisitedTechnology(mode, technology_name) then
		return
	end
	EvaluatingStepStatusHolder.markTechnologyAsVisited(mode, technology_name)
	EvaluatingStepStatusHolder.initForModeAndTechnology(mode, technology_name)
	local first_level_parents = TechnologyTreeUtil.findPrerequisitesForTechnologyForFirstLevel(technology_name, mode)

	writeTechnologyPropertiesToTechnologyStatus(technology_name, mode, first_level_parents or {})

	_table.each(first_level_parents, function(dependency_name)
		TechnologyLeafHandlerTechnologyPropertiesStep.evaluate(dependency_name, mode)
	end)
end
return TechnologyLeafHandlerTechnologyPropertiesStep

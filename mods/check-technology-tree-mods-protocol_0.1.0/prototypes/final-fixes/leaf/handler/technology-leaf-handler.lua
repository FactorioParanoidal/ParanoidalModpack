require("steps.status-holder.evaluate-step-status-holder")

local TechnologyLeafHandler = {}

local technologyPropertiesEvaluatingStep = require("steps.technology-properties-evaluating-step")
local technologyNoHiddenValidatningStep = require("steps.technology-no-hidden-validating-step")
local technologyNoHiddenRecipeEffectsValidatningStep =
	require("steps.technology-no-hidden-recipe-effects-validating-step")
local herselfTechnologyTreeResolvingStep = require("steps.missed-ingredients-in-tech-tree-step")
local anotherTechnologyTreeResolvingStep = require("steps.another-technology-tree-candidate-resolving-step")
local technologyTreeResolvedValidatingStep = require("steps.technology-tree-resolved-validating-step")
local technologyTreeResettingStep = require("steps.technology-tree-resetting-step")
local function clearStateBeforeStep(mode)
	EvaluatingStepStatusHolder.cleanupVisitedTechnologies(mode)
	return 1
end
local function evaluateTechnologyProperties(technology_names, mode, technology_names_count)
	log("start evaluating cache for properties for all technologies")
	local index = clearStateBeforeStep(mode)
	_table.each(technology_names, function(technology_name)
		log(tostring(index) .. " of " .. tostring(technology_names_count))
		technologyPropertiesEvaluatingStep.evaluate(technology_name, mode)
		index = index + 1
	end)
	log("end evaluating cache for properties for all technologies")
end
local function validateTechnologyPrerequisitesNoHidden(technology_names, mode, technology_names_count)
	log("start check no hidden prerequisites for all technologies")
	local index = clearStateBeforeStep(mode)
	_table.each(technology_names, function(technology_name)
		log(tostring(index) .. " of " .. tostring(technology_names_count))
		technologyNoHiddenValidatningStep.evaluate(technology_name, mode)
		index = index + 1
	end)
	log("end check no hidden prerequisites for all technologies")
end
local function validateTechnologyEffectsNoHidden(technology_names, mode, technology_names_count)
	log("start check no hidden recipe effects for all technologies")
	local index = clearStateBeforeStep(mode)
	_table.each(technology_names, function(technology_name)
		log(tostring(index) .. " of " .. tostring(technology_names_count))
		technologyNoHiddenRecipeEffectsValidatningStep.evaluate(technology_name, mode)
		index = index + 1
	end)
	log("end check no hidden recipe effects for all technologies")
end
local function findUnresolvedRecipeIngredientNamesInHerselfTechnologyTree(
	technology_names,
	mode,
	technology_names_count
)
	local index = clearStateBeforeStep(mode)
	log("start trying to resolve recipe ingredient missing evaluating in herself technology tree")
	_table.each(technology_names, function(technology_name)
		log(tostring(index) .. " of " .. tostring(technology_names_count))
		local root_technologies = {}
		herselfTechnologyTreeResolvingStep.evaluate(technology_name, mode, root_technologies)
		index = index + 1
	end)
	log("end trying to resolve recipe ingredient missing evaluating in technology tree")
end
local function tryResolveUnresolvedRecipeIngredientInAnotherTechnologyTrees(
	technology_names,
	mode,
	technology_names_count
)
	local index = clearStateBeforeStep(mode)
	log("start trying to resolve recipe ingredient missing evaluating in another technology tree")
	_table.each(technology_names, function(technology_name)
		log(tostring(index) .. " of " .. tostring(technology_names_count))
		anotherTechnologyTreeResolvingStep.evaluate(
			technology_name,
			mode,
			herselfTechnologyTreeResolvingStep,
			technologyPropertiesEvaluatingStep
		)
		index = index + 1
	end)
	log("end trying to resolve recipe ingredient missing evaluating in another technology tree")
end
local function validateAllUnresolvedRecipeIngredientMarkAsResolved(technology_names, mode, technology_names_count)
	local index = clearStateBeforeStep(mode)
	log("start check all unresolved ingredient marked as resolved")
	_table.each(technology_names, function(technology_name)
		log(tostring(index) .. " of " .. tostring(technology_names_count))
		technologyTreeResolvedValidatingStep.evaluate(technology_name, mode)
		index = index + 1
	end)
	log("end check all unresolved ingredient marked as resolved")
end
local function updateTechnologyTreesWithResolvedIngredientsAdditions(technology_names, mode, technology_names_count)
	local index = clearStateBeforeStep(mode)
	log("start resetting technology trees to technology prototypes")
	_table.each(technology_names, function(technology_name)
		log(tostring(index) .. " of " .. tostring(technology_names_count))
		technologyTreeResettingStep.evaluate(technology_name, mode)
		index = index + 1
	end)
	log("end resetting technology trees to technology prototypes")
end
TechnologyLeafHandler.handleLeafTechonologies = function(technology_names, mode)
	EvaluatingStepStatusHolder.initForMode(mode)
	local technology_names_count = #technology_names
	_table.each(technology_names, function(technology_name)
		log("technology_name " .. technology_name)
		log("technology " .. Utils.dump_to_console(data.raw["technology"][technology_name]))
	end)
	evaluateTechnologyProperties(technology_names, mode, technology_names_count)
	validateTechnologyPrerequisitesNoHidden(technology_names, mode, technology_names_count)
	validateTechnologyEffectsNoHidden(technology_names, mode, technology_names_count)
	findUnresolvedRecipeIngredientNamesInHerselfTechnologyTree(technology_names, mode, technology_names_count)
	tryResolveUnresolvedRecipeIngredientInAnotherTechnologyTrees(technology_names, mode, technology_names_count)
	validateAllUnresolvedRecipeIngredientMarkAsResolved(technology_names, mode, technology_names_count)
	updateTechnologyTreesWithResolvedIngredientsAdditions(technology_names, mode, technology_names_count)
	--[[ после того как мы переставили вс технологии проверяем ещё раз, что не возникло никаких циклов или неразрешённых рецептов.
	В случае успеха - переходим к обработке технологий следующего режима!!]]
	evaluateTechnologyProperties(technology_names, mode, technology_names_count)
	validateTechnologyPrerequisitesNoHidden(technology_names, mode, technology_names_count)
	validateTechnologyEffectsNoHidden(technology_names, mode, technology_names_count)
	validateAllUnresolvedRecipeIngredientMarkAsResolved(technology_names, mode, technology_names_count)
	EvaluatingStepStatusHolder.cleanupForMode(mode)
end

return TechnologyLeafHandler

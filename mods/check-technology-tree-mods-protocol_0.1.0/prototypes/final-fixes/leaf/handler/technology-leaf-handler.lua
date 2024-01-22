require("steps.status-holder.evaluate-step-status-holder")

local TechnologyLeafHandler = {}

local technologyPropertiesEvaluatingStep = require("steps.technology-properties-evaluating-step")
local technologyNoHiddenValidatningStep = require("steps.technology-no-hidden-validating-step")
local technologyNoHiddenRecipeEffectsValidatningStep =
	require("steps.technology-no-hidden-recipe-effects-validating-step")
local herselfTechnologyTreeResolvingStep = require("steps.missed-ingredients-in-tech-tree-step")
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
	--log("start check no hidden prerequisites for all technologies")
	local index = clearStateBeforeStep(mode)
	_table.each(technology_names, function(technology_name)
		--	log(tostring(index) .. " of " .. tostring(technology_names_count))
		technologyNoHiddenValidatningStep.evaluate(technology_name, mode)
		index = index + 1
	end)
	--log("end check no hidden prerequisites for all technologies")
end
local function validateTechnologyEffectsNoHidden(technology_names, mode, technology_names_count)
	--log("start check no hidden recipe effects for all technologies")
	local index = clearStateBeforeStep(mode)
	_table.each(technology_names, function(technology_name)
		--	log(tostring(index) .. " of " .. tostring(technology_names_count))
		technologyNoHiddenRecipeEffectsValidatningStep.evaluate(technology_name, mode)
		index = index + 1
	end)
	--log("end check no hidden recipe effects for all technologies")
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
		EvaluatingStepStatusHolder.cleanupVisitedTechnologies(mode)
		herselfTechnologyTreeResolvingStep.evaluate(technology_name, mode, technologyPropertiesEvaluatingStep)
		index = index + 1
	end)
	log("end trying to resolve recipe ingredient missing evaluating in technology tree")
end
local function printActiveTechnologyTree(mode, technology_name, level)
	local prefix = ""
	for i = 0, level - 1 do
		prefix = prefix .. "|"
	end
	prefix = prefix .. "-"
	if EvaluatingStepStatusHolder.isVisitedTechnology(mode, technology_name) then
		return
	end
	EvaluatingStepStatusHolder.markTechnologyAsVisited(mode, technology_name)
	local tree = EvaluatingStepStatusHolder.getTreeFromTechnologyStatus(mode, technology_name)
	if not tree or _table.size(tree) == 0 then
		return
	end
	_table.each(tree, function(tree_element_name)
		log(prefix .. tree_element_name)
		printActiveTechnologyTree(mode, tree_element_name, level + 1)
	end)
end
local function printActiveTechnolgyData(technology_names, mode, technology_names_count)
	local index = clearStateBeforeStep(mode)
	log("start print leaf technology data(and it tree, optional)")
	_table.each(technology_names, function(technology_name)
		EvaluatingStepStatusHolder.cleanupVisitedTechnologies(mode)
		log(tostring(index) .. " of " .. tostring(technology_names_count))
		log("technology_name " .. technology_name .. " tree")
		log(technology_name)
		printActiveTechnologyTree(mode, technology_name, 0)
		log("technology data " .. Utils.dump_to_console(data.raw["technology"][technology_name]))
		index = index + 1
	end)
	log("end print leaf technology data(and it tree, optional)")
end

TechnologyLeafHandler.handleLeafTechonologies = function(technology_names, mode)
	EvaluatingStepStatusHolder.initForMode(mode)
	local technology_names_count = #technology_names
	evaluateTechnologyProperties(technology_names, mode, technology_names_count)
	printActiveTechnolgyData(technology_names, mode, technology_names_count)
	validateTechnologyPrerequisitesNoHidden(technology_names, mode, technology_names_count)
	validateTechnologyEffectsNoHidden(technology_names, mode, technology_names_count)
	findUnresolvedRecipeIngredientNamesInHerselfTechnologyTree(technology_names, mode, technology_names_count)
	EvaluatingStepStatusHolder.cleanupForMode(mode)
end

return TechnologyLeafHandler

require("steps.evaluate-step-status-holder")

local TechnologyLeafHandler = {}

local technologyPropertiesEvaluatingStep = require("steps.technology-properties-step")
local herselfTechnologyTreeResolvingStep = require("steps.missed-ingredients-in-tech-tree-step")
local anotherTechnologyTreeResolvingStep = require("steps.another-technology-tree-candidate-resolving-step")
local technologyTreeResolvedValidatingStep = require("steps.technology-tree-resolved-validating-step")
local technologyTreeResettingStep = require("steps.technology-tree-resetting-step")
local function clearStateBeforeStep(mode)
	EvaluatingStepStatusHolder.cleanupVisitedTechnologies(mode)
	return 1
end
TechnologyLeafHandler.handleLeafTechonologies = function(technology_names, mode)
	EvaluatingStepStatusHolder.initForMode(mode)
	local technology_names_count = #technology_names
	local index
	log("start evaluating cache for properties for all technologies")
	index = clearStateBeforeStep(mode)
	_table.each(technology_names, function(technology_name)
		log(tostring(index) .. " of " .. tostring(technology_names_count))
		technologyPropertiesEvaluatingStep.evaluate(technology_name, mode)
		index = index + 1
	end)
	log("end evaluating cache for properties for all technologies")
	index = clearStateBeforeStep(mode)
	log("start trying to resolve recipe ingredient missing evaluating in herself technology tree")
	_table.each(technology_names, function(technology_name)
		log(tostring(index) .. " of " .. tostring(technology_names_count))
		local root_technologies = {}
		herselfTechnologyTreeResolvingStep.evaluate(technology_name, mode, root_technologies)
		index = index + 1
	end)
	log("end trying to resolve recipe ingredient missing evaluating in technology tree")
	index = clearStateBeforeStep(mode)
	log("start trying to resolve recipe ingredient missing evaluating in another technology tree")
	_table.each(technology_names, function(technology_name)
		log(tostring(index) .. " of " .. tostring(technology_names_count))
		anotherTechnologyTreeResolvingStep.evaluate(technology_name, mode, herselfTechnologyTreeResolvingStep)
		index = index + 1
	end)
	log("end trying to resolve recipe ingredient missing evaluating in another technology tree")
	index = clearStateBeforeStep(mode)
	log("start check all unresolved ingredient marked as resolved")
	_table.each(technology_names, function(technology_name)
		log(tostring(index) .. " of " .. tostring(technology_names_count))
		technologyTreeResolvedValidatingStep.evaluate(technology_name, mode)
		index = index + 1
	end)
	log("end check all unresolved ingredient marked as resolved")
	index = clearStateBeforeStep(mode)
	log("start resetting technology trees to technology prototypes")
	_table.each(technology_names, function(technology_name)
		log(tostring(index) .. " of " .. tostring(technology_names_count))
		technologyTreeResettingStep.evaluate(technology_name, mode)
		index = index + 1
	end)
	log("end resetting technology trees to technology prototypes")
	EvaluatingStepStatusHolder.cleanupForMode(mode)
end

return TechnologyLeafHandler

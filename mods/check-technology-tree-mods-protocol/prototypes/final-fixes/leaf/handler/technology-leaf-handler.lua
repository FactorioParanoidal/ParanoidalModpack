require("steps.status-holder.evaluate-step-status-holder")

local TechnologyLeafHandler = {}

local technology_properties_evaluating_step = require("steps.technology-properties-evaluating-step")
local technology_no_hidden_validatning_step = require("steps.technology-no-hidden-validating-step")
local technology_no_hidden_recipe_effects_validatning_step =
	require("steps.technology-no-hidden-recipe-effects-validating-step")
local herself_technology_tree_resolving_step = require("steps.missed-ingredients-in-tech-tree-step")
local function clear_state_before_step(mode)
	EvaluatingStepStatusHolder.cleanup_visited_technologies(mode)
	return 1
end
local function evaluate_technology_properties(technology_names, mode, technology_names_count)
	log("start evaluating cache for properties for all technologies")
	local index = clear_state_before_step(mode)
	_table.each(technology_names, function(technology_name)
		log(tostring(index) .. " of " .. tostring(technology_names_count))
		technology_properties_evaluating_step.evaluate(technology_name, mode)
		index = index + 1
	end)
	log("end evaluating cache for properties for all technologies")
end
local function validate_technology_prerequisites_no_hidden(technology_names, mode, technology_names_count)
	log("start check no hidden prerequisites for all technologies")
	local index = clear_state_before_step(mode)
	_table.each(technology_names, function(technology_name)
		log(tostring(index) .. " of " .. tostring(technology_names_count))
		technology_no_hidden_validatning_step.evaluate(technology_name, mode)
		index = index + 1
	end)
	log("end check no hidden prerequisites for all technologies")
end
local function validate_technology_effects_no_hidden(technology_names, mode, technology_names_count)
	log("start check no hidden recipe effects for all technologies")
	local index = clear_state_before_step(mode)
	_table.each(technology_names, function(technology_name)
		log(tostring(index) .. " of " .. tostring(technology_names_count))
		technology_no_hidden_recipe_effects_validatning_step.evaluate(technology_name, mode)
		index = index + 1
	end)
	log("end check no hidden recipe effects for all technologies")
end
local function find_unresolved_recipe_ingredient_names_in_herself_technology_tree(
	technology_names,
	mode,
	technology_names_count
)
	local index = clear_state_before_step(mode)
	log("start trying to resolve recipe ingredient missing evaluating in herself technology tree")
	_table.each(technology_names, function(technology_name)
		log(tostring(index) .. " of " .. tostring(technology_names_count))
		EvaluatingStepStatusHolder.cleanup_visited_technologies(mode)
		herself_technology_tree_resolving_step.evaluate(technology_name, mode, technology_properties_evaluating_step)
		index = index + 1
	end)
	log("end trying to resolve recipe ingredient missing evaluating in technology tree")
end

TechnologyLeafHandler.handle_leaf_techonologies = function(technology_names, mode)
	EvaluatingStepStatusHolder.init_for_mode(mode)
	local technology_names_count = #technology_names
	evaluate_technology_properties(technology_names, mode, technology_names_count)
	validate_technology_prerequisites_no_hidden(technology_names, mode, technology_names_count)
	validate_technology_effects_no_hidden(technology_names, mode, technology_names_count)
	find_unresolved_recipe_ingredient_names_in_herself_technology_tree(technology_names, mode, technology_names_count)
	EvaluatingStepStatusHolder.cleanup_for_mode(mode)
end

return TechnologyLeafHandler

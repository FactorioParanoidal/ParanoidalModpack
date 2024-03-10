local techUtil = require("__automated-utility-protocol__.util.technology-util")
local TechnologyLeafHandlerTechnologyPropertiesStep = {}

local function write_technology_properties_to_technology_status(technology_name, mode, first_level_parents)
	EvaluatingStepStatusHolder.add_tree_to_technology_status(mode, technology_name, first_level_parents)
	local recipe_ingredients = techUtil.get_all_recipe_ingredients_for_specified_technology(technology_name, mode)
	EvaluatingStepStatusHolder.add_effect_ingredients_to_technology_status(mode, technology_name, recipe_ingredients)
	local recipe_results = techUtil.get_all_recipe_results_for_specified_technology(technology_name, mode)
	EvaluatingStepStatusHolder.add_effect_results_to_technology_status(mode, technology_name, recipe_results)
	local tool_units = techUtil.get_all_tool_units_for_specified_technology(technology_name, mode)
	EvaluatingStepStatusHolder.add_tool_units_to_technology_status(mode, technology_name, tool_units)
	--[[log(
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
	)]]
end

TechnologyLeafHandlerTechnologyPropertiesStep.evaluate = function(technology_name, mode)
	if EvaluatingStepStatusHolder.is_visited_technology(mode, technology_name) then
		return
	end
	EvaluatingStepStatusHolder.mark_technology_as_visited(mode, technology_name)
	EvaluatingStepStatusHolder.init_for_mode_and_technology(mode, technology_name)
	--log("technology_name " .. technology_name)
	local first_level_parents =
		TechnologyTreeUtil.find_prerequisites_for_technology_for_first_level(technology_name, mode)
	write_technology_properties_to_technology_status(technology_name, mode, first_level_parents or {})

	_table.each(first_level_parents, function(dependency_name)
		TechnologyLeafHandlerTechnologyPropertiesStep.evaluate(dependency_name, mode)
	end)
end
return TechnologyLeafHandlerTechnologyPropertiesStep

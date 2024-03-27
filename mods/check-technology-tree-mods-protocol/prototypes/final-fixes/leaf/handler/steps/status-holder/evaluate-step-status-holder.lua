EvaluatingStepStatusHolder = {}

local evaluating_step_status = {}

EvaluatingStepStatusHolder.init_for_mode = function(mode)
	evaluating_step_status[mode] = {
		marked_technologies = {},
		all_found_technologies = {},
	}
end

local function check_mode_status(mode)
	if not evaluating_step_status[mode] then
		error("status for mode " .. mode .. " already destroyed!!")
	end
	return evaluating_step_status[mode]
end

EvaluatingStepStatusHolder.init_for_mode_and_technology = function(mode, technology_name)
	local status = check_mode_status(mode)
	status[technology_name] = {
		tree = {},
		effect_ingredients = {},
		effect_results = {},
		units = {},
		not_found_in_tree_ingredients = {},
		resolved_not_found_in_tree_ingredients = {},
	}
end

local function check_mode_and_technology_status(mode, technology_name)
	local status = check_mode_status(mode)
	if not status[technology_name] then
		error("status for mode " .. mode .. " and technology " .. technology_name .. " already destroyed!!")
	end
	return status[technology_name]
end

EvaluatingStepStatusHolder.mark_technology_as_visited = function(mode, technology_name)
	local status = check_mode_status(mode)
	local sigleton_list = { technology_name }
	_table.insert_all_if_not_exists(status.marked_technologies, sigleton_list)
	_table.insert_all_if_not_exists(status.all_found_technologies, sigleton_list)
end

EvaluatingStepStatusHolder.is_visited_technology = function(mode, technology_name)
	local status = check_mode_status(mode)
	return _table.contains(status.marked_technologies, technology_name)
end

EvaluatingStepStatusHolder.get_all_technology_names_foun_for_mode = function(mode)
	local status = check_mode_status(mode)
	return status.all_found_technologies
end

EvaluatingStepStatusHolder.cleanup_visited_technologies = function(mode)
	local status = check_mode_status(mode)
	_table.clear(status.marked_technologies)
end

EvaluatingStepStatusHolder.add_tree_to_technology_status = function(mode, technology_name, technology_tree)
	local technology_status = check_mode_and_technology_status(mode, technology_name)
	_table.insert_all_if_not_exists(technology_status.tree, technology_tree)
end

EvaluatingStepStatusHolder.get_tree_from_technology_status = function(mode, technology_name)
	local technology_status = check_mode_and_technology_status(mode, technology_name)
	return technology_status.tree
end

EvaluatingStepStatusHolder.add_effect_ingredients_to_technology_status = function(
	mode,
	technology_name,
	evaluated_effect_ingredients
)
	local technology_status = check_mode_and_technology_status(mode, technology_name)
	_table.insert_all_if_not_exists(technology_status.effect_ingredients, evaluated_effect_ingredients)
end

EvaluatingStepStatusHolder.getEffectIngredientsFromTechnologyStatus = function(mode, technology_name)
	local technology_status = check_mode_and_technology_status(mode, technology_name)
	return technology_status.effect_ingredients
end

EvaluatingStepStatusHolder.add_effect_results_to_technology_status = function(
	mode,
	technology_name,
	evaluated_effect_results
)
	local technology_status = check_mode_and_technology_status(mode, technology_name)
	_table.insert_all_if_not_exists(technology_status.effect_results, evaluated_effect_results)
end

EvaluatingStepStatusHolder.get_effect_results_from_technology_status = function(mode, technology_name)
	local technology_status = check_mode_and_technology_status(mode, technology_name)
	return technology_status.effect_results
end

local function unit_table_sorted_function(unit1, unit2)
	return unit1.name < unit2.name
end

EvaluatingStepStatusHolder.add_tool_units_to_technology_status = function(mode, technology_name, evaluated_units)
	local technology_status = check_mode_and_technology_status(mode, technology_name)
	table.sort(evaluated_units, unit_table_sorted_function)
	_table.insert_all_if_not_exists(technology_status.units, evaluated_units)
end

EvaluatingStepStatusHolder.get_tool_units_from_technology_status = function(mode, technology_name)
	local technology_status = check_mode_and_technology_status(mode, technology_name)
	return technology_status.units
end

EvaluatingStepStatusHolder.get_technology_names_with_compatiable_science_pack = function(mode, technology_name)
	local technology_status = check_mode_and_technology_status(mode, technology_name)
	local technology_units = technology_status.units
	local salvaged_science_pack_unit = { type = "item", name = "salvaged-automation-science-pack" }
	_table.insert_all_if_not_exists(technology_units, { salvaged_science_pack_unit })
	local status = evaluating_step_status[mode]
	return _table.filter(status.all_found_technologies, function(found_technology_name)
		local technology_status_filter = status[found_technology_name]
		local technology_status_filter_units = technology_status_filter.units
		local removable_units = _table.deep_copy(technology_status_filter_units)
		_table.each(technology_units, function(removing_unit_candidate)
			_table.remove_item(removable_units, removing_unit_candidate, nil, true)
		end)
		local result = _table.size(removable_units) == 0

		return result
	end)
end
local function get_occurs_technology_in_another_technology_tree0(
	in_which_contain_technology_name,
	contain_technology_candidate_name,
	mode,
	visited_technologies
)
	local result = {}
	if _table.contains(visited_technologies, in_which_contain_technology_name) then
		return result
	end
	table.insert(visited_technologies, in_which_contain_technology_name)
	local technology_status = check_mode_and_technology_status(mode, in_which_contain_technology_name)
	if not technology_status.tree then
		return result
	end

	if
		settings.startup["debug_output"]
		and technology_status.tree
		and _table.contains(technology_status.tree, contain_technology_candidate_name)
	then
		log("in_which_contain_technology_name " .. in_which_contain_technology_name)
		log(
			"technology_status.tree "
				.. Utils.dump_to_console(technology_status.tree)
				.. ", contain_technology_candidate_name"
				.. contain_technology_candidate_name
		)
		table.insert(result, in_which_contain_technology_name)
	end
	_table.each(technology_status.tree, function(parent_name)
		if parent_name ~= contain_technology_candidate_name and parent_name ~= in_which_contain_technology_name then
			_table.insert_all_if_not_exists(
				result,
				get_occurs_technology_in_another_technology_tree0(
					parent_name,
					contain_technology_candidate_name,
					mode,
					visited_technologies
				)
			)
		end
	end)
	return result
end

EvaluatingStepStatusHolder.get_occurs_technology_in_another_technology_tree = function(
	in_which_contain_technology_name,
	contain_technology_candidate_name,
	mode
)
	return get_occurs_technology_in_another_technology_tree0(
		in_which_contain_technology_name,
		contain_technology_candidate_name,
		mode,
		{}
	)
end

local function cleanup_for_mode_and_technology(mode, technology_name)
	local technology_status = check_mode_and_technology_status(mode, technology_name)
	if technology_status then
		_table.clear(technology_status)
		return
	end
	error("for mode " .. mode .. " technology status for " .. technology_name .. " is already destroyed!")
end

EvaluatingStepStatusHolder.cleanup_for_mode = function(mode)
	local status = check_mode_status(mode)
	if status then
		_table.each(status.all_found_technologies, function(technology_name)
			cleanup_for_mode_and_technology(mode, technology_name)
			status[technology_name] = nil
		end)
		local technology_in_progress_count = #check_mode_status(mode)
		if technology_in_progress_count == 0 then
			evaluating_step_status[mode] = nil
			return
		end
	end
	error("step status for mode " .. mode .. " has " .. tostring(technology_in_progress_count) .. " entries!")
end

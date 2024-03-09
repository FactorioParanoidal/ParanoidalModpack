EvaluatingStepStatusHolder = {}

local EvaluatingStepStatus = {}

EvaluatingStepStatusHolder.initForMode = function(mode)
	EvaluatingStepStatus[mode] = {
		marked_technologies = {},
		all_found_technologies = {},
	}
end

EvaluatingStepStatusHolder.initForModeAndTechnology = function(mode, technology_name)
	local status = EvaluatingStepStatus[mode]
	status[technology_name] = {
		tree = {},
		effect_ingredients = {},
		effect_results = {},
		units = {},
		not_found_in_tree_ingredients = {},
		resolved_not_found_in_tree_ingredients = {},
	}
end

local function checkModeStatus(mode)
	if not EvaluatingStepStatus[mode] then
		error("status for mode " .. mode .. " already destroyed!!")
	end
	return EvaluatingStepStatus[mode]
end

local function checkModeTechnologyStatus(mode, technology_name)
	local status = checkModeStatus(mode)
	if not status[technology_name] then
		error("status for mode " .. mode .. " and technology " .. technology_name .. " already destroyed!!")
	end
	return status[technology_name]
end

EvaluatingStepStatusHolder.markTechnologyAsVisited = function(mode, technology_name)
	local status = checkModeStatus(mode)
	local sigleton_list = { technology_name }
	_table.insert_all_if_not_exists(status.marked_technologies, sigleton_list)
	_table.insert_all_if_not_exists(status.all_found_technologies, sigleton_list)
end

local function markTechnologyWithTreeAsUnvisited0(mode, technology_name, visited_unvisited_technology_names)
	if _table.contains(visited_unvisited_technology_names, technology_name) then
		return
	end
	table.insert(visited_unvisited_technology_names, technology_name)
	local status = checkModeStatus(mode)
	log(technology_name)
	_table.remove_item(status.marked_technologies, technology_name, nil, true)
	local technology_status = checkModeTechnologyStatus(mode, technology_name)

	if not technology_status.tree then
		return
	end
	_table.each(technology_status.tree, function(dependency_name)
		markTechnologyWithTreeAsUnvisited0(mode, dependency_name, visited_unvisited_technology_names)
	end)
end
EvaluatingStepStatusHolder.markTechnologyWithTreeAsUnvisited = function(mode, technology_name)
	markTechnologyWithTreeAsUnvisited0(mode, technology_name, {})
end

EvaluatingStepStatusHolder.isVisitedTechnology = function(mode, technology_name)
	local status = checkModeStatus(mode)
	return _table.contains(status.marked_technologies, technology_name)
end

EvaluatingStepStatusHolder.getAllTechnologyNames = function(mode)
	local status = checkModeStatus(mode)
	return status.all_found_technologies
end

EvaluatingStepStatusHolder.cleanup_visited_technologies = function(mode)
	local status = checkModeStatus(mode)
	_table.clear(status.marked_technologies)
end

EvaluatingStepStatusHolder.addTreeToTechnologyStatus = function(mode, technology_name, technology_tree)
	local technology_status = checkModeTechnologyStatus(mode, technology_name)
	_table.insert_all_if_not_exists(technology_status.tree, technology_tree)
end

EvaluatingStepStatusHolder.removeTreeFromTechnologyStatus = function(mode, technology_name, technology_tree)
	local technology_status = checkModeTechnologyStatus(mode, technology_name)
	_table.each(technology_tree, function(technology_item)
		_table.remove_item(technology_status.tree, technology_item)
	end)
end

EvaluatingStepStatusHolder.getTreeFromTechnologyStatus = function(mode, technology_name)
	local technology_status = checkModeTechnologyStatus(mode, technology_name)
	return technology_status.tree
end

EvaluatingStepStatusHolder.addEffectIngredientsToTechnologyStatus = function(
	mode,
	technology_name,
	evaluated_effect_ingredients
)
	local technology_status = checkModeTechnologyStatus(mode, technology_name)
	_table.insert_all_if_not_exists(technology_status.effect_ingredients, evaluated_effect_ingredients)
end

EvaluatingStepStatusHolder.getEffectIngredientsFromTechnologyStatus = function(mode, technology_name)
	local technology_status = checkModeTechnologyStatus(mode, technology_name)
	return technology_status.effect_ingredients
end

EvaluatingStepStatusHolder.addEffectResultsToTechnologyStatus = function(
	mode,
	technology_name,
	evaluated_effect_results
)
	local technology_status = checkModeTechnologyStatus(mode, technology_name)
	_table.insert_all_if_not_exists(technology_status.effect_results, evaluated_effect_results)
end

EvaluatingStepStatusHolder.getEffectResultsFromTechnologyStatus = function(mode, technology_name)
	local technology_status = checkModeTechnologyStatus(mode, technology_name)
	return technology_status.effect_results
end

local function unit_table_sorted_function(unit1, unit2)
	return unit1.name < unit2.name
end

EvaluatingStepStatusHolder.addUnitsToTechnologyStatus = function(mode, technology_name, evaluated_units)
	local technology_status = checkModeTechnologyStatus(mode, technology_name)
	table.sort(evaluated_units, unit_table_sorted_function)
	_table.insert_all_if_not_exists(technology_status.units, evaluated_units)
end

EvaluatingStepStatusHolder.getUnitsFromTechnologyStatus = function(mode, technology_name)
	local technology_status = checkModeTechnologyStatus(mode, technology_name)
	return technology_status.units
end

local function getIngredientName(ingredient)
	return ingredient.name or ingredient[1]
end
EvaluatingStepStatusHolder.getTechnologyNamesWithCompatiableSciencePack = function(mode, technology_name)
	local technology_status = checkModeTechnologyStatus(mode, technology_name)
	local technology_units = technology_status.units
	local salvaged_science_pack_unit = { type = "item", name = "salvaged-automation-science-pack" }
	_table.insert_all_if_not_exists(technology_units, { salvaged_science_pack_unit })
	local status = EvaluatingStepStatus[mode]
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
local function getOccursTechnologyInAnotherTechnologyTree0(
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
	local technology_status = checkModeTechnologyStatus(mode, in_which_contain_technology_name)
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
				getOccursTechnologyInAnotherTechnologyTree0(
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

EvaluatingStepStatusHolder.getOccursTechnologyInAnotherTechnologyTree = function(
	in_which_contain_technology_name,
	contain_technology_candidate_name,
	mode
)
	return getOccursTechnologyInAnotherTechnologyTree0(
		in_which_contain_technology_name,
		contain_technology_candidate_name,
		mode,
		{}
	)
end

EvaluatingStepStatusHolder.hasResolvedStatusForIngredientForTechnology = function(
	effect_ingredient_not_found_in_current_tree,
	technology_name,
	mode
)
	local not_found_inredient_name = effect_ingredient_not_found_in_current_tree.name
		or effect_ingredient_not_found_in_current_tree[1]
	local technology_status = checkModeTechnologyStatus(mode, technology_name)
	if settings.startup["debug_output"] then
		log(
			" for techonology "
				.. technology_name
				.. " for mode "
				.. mode
				.. " technology_status.not_found_in_tree_ingredients["
				.. not_found_inredient_name
				.. "] "
				.. Utils.dump_to_console(technology_status.not_found_in_tree_ingredients[not_found_inredient_name])
		)
	end
	return not technology_status.not_found_in_tree_ingredients[not_found_inredient_name]
end

EvaluatingStepStatusHolder.cleanupForModeAndTechnology = function(mode, technology_name)
	local status = EvaluatingStepStatus[mode]
	if status and status[technology_name] then
		local technology_status = status[technology_name]
		_table.clear(technology_status)
		status[technology_name] = nil
		return
	end
	error("for mode " .. mode .. " technology status for " .. technology_name .. " is already destroyed!")
end

EvaluatingStepStatusHolder.cleanupForMode = function(mode)
	local technology_in_progress_count = #checkModeStatus(mode)
	if technology_in_progress_count == 0 then
		EvaluatingStepStatus[mode] = nil
		return
	end
	error("step status for mode " .. mode .. " has " .. tostring(technology_in_progress_count) .. " entries!")
end

local function print_technology_tree0(mode, technology_name, level)
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
		print_technology_tree0(mode, tree_element_name, level + 1)
	end)
end

EvaluatingStepStatusHolder.print_technology_tree = function(mode, technology_name)
	log("tree of")
	log(technology_name)
	print_technology_tree0(mode, technology_name, 0)
end

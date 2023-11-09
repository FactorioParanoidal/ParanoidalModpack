EvaluatingStepStatusHolder = {}

local EvaluatingStepStatus = {}

EvaluatingStepStatusHolder.initForMode = function(mode)
    EvaluatingStepStatus[mode] = {
        marked_technologies = {},
        all_found_technologies = {},
        cached_for_combinations_technologies = {}
    }
end

EvaluatingStepStatusHolder.initForModeAndTechnology = function(mode,
                                                               technology_name)
    local status = EvaluatingStepStatus[mode]
    status[technology_name] = {
        tree = {},
        effect_ingredients = {},
        effect_results = {},
        units = {},
        not_found_in_tree_ingredients = {},
        resolved_not_found_in_tree_ingredients = {}
    }
end

local function checkModeStatus(mode)
    if not EvaluatingStepStatus[mode] then
        error('status for mode ' .. mode .. ' already destroyed!!')
    end
    return EvaluatingStepStatus[mode]
end

local function checkModeTechnologyStatus(mode,
                                         technology_name)
    local status = checkModeStatus(mode)
    if not status[technology_name] then
        error('status for mode ' .. mode .. ' and technology ' .. technology_name .. ' already destroyed!!')
    end
    return status[technology_name]
end

EvaluatingStepStatusHolder.markTechnologyAsVisited = function(mode,
                                                              technology_name)
    local status = checkModeStatus(mode)
    local sigleton_list = { technology_name }
    _table.insert_all_if_not_exists(status.marked_technologies,
        sigleton_list)
    _table.insert_all_if_not_exists(status.all_found_technologies,
        sigleton_list)
end

EvaluatingStepStatusHolder.isVisitedTechnology = function(mode,
                                                          technology_name)
    local status = checkModeStatus(mode)
    return _table.contains(status.marked_technologies,
        technology_name)
end

EvaluatingStepStatusHolder.getAllTechnologyNames = function(mode)
    local status = checkModeStatus(mode)
    return (status.all_found_technologies)
end

EvaluatingStepStatusHolder.cleanupVisitedTechnologies = function(mode)
    local status = checkModeStatus(mode)
    _table.clear(status.marked_technologies)
end

EvaluatingStepStatusHolder.addTreeToTechnologyStatus = function(mode,
                                                                technology_name,
                                                                technology_tree)
    local technology_status = checkModeTechnologyStatus(mode,
        technology_name)
    _table.insert_all_if_not_exists(technology_status.tree,
        technology_tree)
end

EvaluatingStepStatusHolder.removeTreeFromTechnologyStatus = function(mode,
                                                                     technology_name,
                                                                     technology_tree)
    local technology_status = checkModeTechnologyStatus(mode,
        technology_name)
    _table.each(technology_tree,
        function(technology_item)
            _table.remove_item(technology_status.tree, technology_item)
        end)
end

EvaluatingStepStatusHolder.getTreeFromTechnologyStatus = function(mode,
                                                                  technology_name)
    local technology_status = checkModeTechnologyStatus(mode, technology_name)
    return (technology_status.tree)
end

EvaluatingStepStatusHolder.addEffectIngredientsToTechnologyStatus = function(mode,
                                                                             technology_name,
                                                                             evaluated_effect_ingredients)
    local technology_status = checkModeTechnologyStatus(mode, technology_name)
    _table.insert_all_if_not_exists(technology_status.effect_ingredients,
        evaluated_effect_ingredients)
end

EvaluatingStepStatusHolder.getEffectIngredientsFromTechnologyStatus = function(mode,
                                                                               technology_name)
    local technology_status = checkModeTechnologyStatus(mode, technology_name)
    return (technology_status.effect_ingredients)
end

EvaluatingStepStatusHolder.addEffectResultsToTechnologyStatus = function(mode,
                                                                         technology_name,
                                                                         evaluated_effect_results)
    local technology_status = checkModeTechnologyStatus(mode, technology_name)
    _table.insert_all_if_not_exists(technology_status.effect_results,
        evaluated_effect_results)
end

EvaluatingStepStatusHolder.getEffectResultsFromTechnologyStatus = function(mode,
                                                                           technology_name)
    local technology_status = checkModeTechnologyStatus(mode, technology_name)
    return (technology_status.effect_results)
end

local function unit_table_sorted_function(unit1, unit2)
    return unit1.name < unit2.name
end

EvaluatingStepStatusHolder.addUnitsToTechnologyStatus = function(mode,
                                                                 technology_name,
                                                                 evaluated_units)
    local technology_status = checkModeTechnologyStatus(mode, technology_name)
    table.sort(evaluated_units, unit_table_sorted_function)
    _table.insert_all_if_not_exists(technology_status.units,
        evaluated_units)
end

EvaluatingStepStatusHolder.getUnitsFromTechnologyStatus = function(mode,
                                                                   technology_name)
    local technology_status = checkModeTechnologyStatus(mode, technology_name)
    return (technology_status.units)
end

EvaluatingStepStatusHolder.addNotFoundIngredientToTechnologyStatus = function(mode,
                                                                              technology_name,
                                                                              not_found_inredient)
    local technology_status = checkModeTechnologyStatus(mode, technology_name)
    local not_found_inredient_name = not_found_inredient.name or not_found_inredient[1]
    technology_status.not_found_in_tree_ingredients[not_found_inredient_name] = not_found_inredient
end

EvaluatingStepStatusHolder.getNotFoundIngredientsFromTechnologyStatus = function(mode,
                                                                                 technology_name)
    local technology_status = checkModeTechnologyStatus(mode, technology_name)
    return (technology_status.not_found_in_tree_ingredients)
end

EvaluatingStepStatusHolder.resolveNotFoundIngredientsFromTechnologyStatus = function(mode,
                                                                                     technology_name,
                                                                                     not_found_inredient)
    local technology_status = checkModeTechnologyStatus(mode, technology_name)
    local not_found_inredient_name = not_found_inredient.name or not_found_inredient[1]
    technology_status.not_found_in_tree_ingredients[not_found_inredient_name] = nil
    technology_status.resolved_not_found_in_tree_ingredients[not_found_inredient_name] = not_found_inredient
end

EvaluatingStepStatusHolder.get_all_unit_subsets = function(unit_set)
    local result = { {} }

    _table.each(unit_set,
        function(unit_element)
            local new_subset = _table.deep_copy(result)
            _table.each(new_subset,
                function(new_subset_element)
                    table.insert(new_subset_element, unit_element)
                    table.sort(new_subset_element, unit_table_sorted_function)
                end)
            _table.insert_all_if_not_exists(result, new_subset)
        end)
    return result
end

EvaluatingStepStatusHolder.getTechnologyNamesWithCompatiableSciencePack = function(mode,
                                                                                   technology_name)
    local technology_status = checkModeTechnologyStatus(mode, technology_name)
    local technology_units = technology_status.units
    local status = EvaluatingStepStatus[mode]
    if status.cached_for_combinations_technologies[technology_units] then
        return status.cached_for_combinations_technologies[technology_units]
    end
    local technology_unit_combinations = EvaluatingStepStatusHolder.get_all_unit_subsets(technology_units)
    local result = _table.filter(status.all_found_technologies,
        function(found_technology_name)
            local technology_status_filter = status[found_technology_name]
            local technology_status_filter_units = technology_status_filter.units
            for _, combination in pairs(technology_unit_combinations) do
                local result = _table.deep_compare(technology_status_filter_units, combination)
                if result then
                    return true
                end
            end
            return false
        end)
    status.cached_for_combinations_technologies[technology_units] = result
    return result
end

EvaluatingStepStatusHolder.cleanupForModeAndTechnology = function(mode,
                                                                  technology_name)
    local status = EvaluatingStepStatus[mode]
    if status and status[technology_name] then
        local technology_status = status[technology_name]
        _table.clear(technology_status)
        status[technology_name] = nil
        return
    end
    error('for mode ' .. mode .. ' technology status for ' .. technology_name .. ' is already destroyed!')
end

EvaluatingStepStatusHolder.cleanupForMode = function(mode)
    local technology_in_progress_count = #checkModeStatus(mode)
    if technology_in_progress_count == 0 then
        EvaluatingStepStatus[mode] = nil
        return
    end
    error('step status for mode ' .. mode .. ' has ' .. tostring(technology_in_progress_count) .. ' entries!')
end

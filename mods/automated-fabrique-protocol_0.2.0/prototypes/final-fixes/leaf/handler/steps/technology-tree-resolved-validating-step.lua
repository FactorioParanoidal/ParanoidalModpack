local TechnologyTreeResolvedValidatingStep = {}

local function handleUnresolvedIngredient(technology_name, mode)
    local unresolvedIngredients = EvaluatingStepStatusHolder.getNotFoundIngredientsFromTechnologyStatus(mode,
        technology_name)
    log('technology_name ' ..
        technology_name .. ' mode ' .. mode .. ' unresolvedIngredients' .. Utils.dump_to_console(unresolvedIngredients))
    if _table.size(unresolvedIngredients) > 0 then
        error('technology_name ' .. technology_name .. ' has not resolved ingredient dependencies!')
    end
end

TechnologyTreeResolvedValidatingStep.evaluate = function(technology_name, mode)
    if EvaluatingStepStatusHolder.isVisitedTechnology(mode, technology_name) then
        return
    end
    EvaluatingStepStatusHolder.markTechnologyAsVisited(mode, technology_name)

    handleUnresolvedIngredient(technology_name, mode)

    local dependencies = EvaluatingStepStatusHolder.getTreeFromTechnologyStatus(mode, technology_name)
    if not dependencies then
        return
    end
    _table.each(dependencies,
        function(dependency_name)
            TechnologyTreeResolvedValidatingStep.evaluate(
                dependency_name,
                mode)
        end)
end

return TechnologyTreeResolvedValidatingStep

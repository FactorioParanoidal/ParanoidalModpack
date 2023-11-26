local TechnologyTreeResettingStep = {}

local function getTechnologyObjectForMode(technology_name, mode)
    return Utils.getModedObject(data.raw["technology"][technology_name], mode)
end

local function resetOnTechnologyPrereqisites(technology_name, mode)
    local dependencies = EvaluatingStepStatusHolder.getTreeFromTechnologyStatus(mode, technology_name)
    log('for technology name ' ..
        technology_name .. ' for mode ' .. mode .. ' new prerequisites built:' .. Utils.dump_to_console(dependencies))
    local technologyObject = getTechnologyObjectForMode(technology_name, mode)
    if technologyObject[mode] then
        technologyObject[mode].prerequisites = dependencies
        return
    end
    technologyObject.prerequisites = dependencies
end
TechnologyTreeResettingStep.evaluate = function(technology_name, mode)
    if EvaluatingStepStatusHolder.isVisitedTechnology(mode, technology_name) then
        return
    end
    EvaluatingStepStatusHolder.markTechnologyAsVisited(mode, technology_name)

    resetOnTechnologyPrereqisites(technology_name, mode)

    local dependencies = EvaluatingStepStatusHolder.getTreeFromTechnologyStatus(mode, technology_name)

    if not dependencies then
        return
    end
    _table.each(dependencies,
        function(dependency_name)
            TechnologyTreeResettingStep.evaluate(
                dependency_name,
                mode)
        end)
end
return TechnologyTreeResettingStep

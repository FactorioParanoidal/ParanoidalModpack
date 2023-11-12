require('steps.evaluate-step-status-holder')

local TechnologyLeafHandler = {}

local TechnologyLeafHandlerTechnologyPropertiesStep = require(
    'steps.technology-properties-step')
local TechnologyLeafHandlerMissedIngredientsInTechnologyTreeStep = require(
    'steps.missed-ingredients-in-tech-tree-step')
local AnotherTechnologyTreeResolvingStep = require('steps.another-technology-tree-candidate-resolving-step')
local TechnologyTreeResolvedValidatingStep = require('steps.technology-tree-resolved-validating-step')
local TechnologyTreeResettingStep = require('steps.technology-tree-resetting-step')
local function clearStateBeforeStep(mode)
    EvaluatingStepStatusHolder.cleanupVisitedTechnologies(mode)
    return 1
end
TechnologyLeafHandler.handleLeafTechonologies = function(technology_names, mode)
    EvaluatingStepStatusHolder.initForMode(mode)
    local technology_names_count = #technology_names
    local index
    log('first step')
    index = clearStateBeforeStep(mode)
    _table.each(technology_names,
        function(technology_name)
            log(tostring(index) .. ' of ' .. tostring(technology_names_count))
            TechnologyLeafHandlerTechnologyPropertiesStep.evaluate(technology_name, mode)
            index = index + 1
        end)
    log('second step')
    index = clearStateBeforeStep(mode)
    _table.each(technology_names,
        function(technology_name)
            log(tostring(index) .. ' of ' .. tostring(technology_names_count))
            local root_technologies = {}
            TechnologyLeafHandlerMissedIngredientsInTechnologyTreeStep.evaluate(technology_name, mode, root_technologies)
            index = index + 1
        end)
    index = clearStateBeforeStep(mode)
    log('third step')
    _table.each(technology_names,
        function(technology_name)
            log(tostring(index) .. ' of ' .. tostring(technology_names_count))
            AnotherTechnologyTreeResolvingStep.evaluate(technology_name, mode)
            index = index + 1
        end)
    index = clearStateBeforeStep(mode)
    log('fourth step')
    _table.each(technology_names,
        function(technology_name)
            log(tostring(index) .. ' of ' .. tostring(technology_names_count))
            TechnologyTreeResolvedValidatingStep.evaluate(technology_name, mode)
            index = index + 1
        end)
    index = clearStateBeforeStep(mode)
    log('fifth step')
    _table.each(technology_names,
        function(technology_name)
            log(tostring(index) .. ' of ' .. tostring(technology_names_count))
            TechnologyTreeResettingStep.evaluate(technology_name, mode)
            index = index + 1
        end)

    EvaluatingStepStatusHolder.cleanupForMode(mode)
end

return TechnologyLeafHandler

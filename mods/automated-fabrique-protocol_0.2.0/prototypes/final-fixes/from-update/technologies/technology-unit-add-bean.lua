TechnologyUnitAddBean = {}
TechnologyUnitAddBean.technology_datas = data.raw["technology"]
local function addSciencePacksToTechnologyUnitsByNames(technology_names, mode, unit_ingredient)
    _table.each(technology_names,
        function(technology_name)
            techUtil.addSciencePacksToTechnologyUnits(TechnologyUnitAddBean.technology_datas[technology_name],
                { unit_ingredient },
                mode)
        end)
end
TechnologyUnitAddBean.addAutomationSciencePackToTechnologyUnits = function(technology_names, mode)
    addSciencePacksToTechnologyUnitsByNames(technology_names, mode, { 'automation-science-pack', 1 })
end
TechnologyUnitAddBean.addLogisticSciencePackToTechnologyUnits = function(technology_names, mode)
    addSciencePacksToTechnologyUnitsByNames(technology_names, mode, { 'logistic-science-pack', 1 })
end
TechnologyUnitAddBean.addChemicalSciencePackToTechnologyUnits = function(technology_names, mode)
    addSciencePacksToTechnologyUnitsByNames(technology_names, mode, { 'chemical-science-pack', 1 })
end
TechnologyUnitAddBean.addProductionSciencePackToTechnologyUnits = function(technology_names, mode)
    addSciencePacksToTechnologyUnitsByNames(technology_names, mode, { 'production-science-pack', 1 })
end
TechnologyUnitAddBean.addProductivityProcessorToTechnologyUnits = function(technology_names, mode)
    addSciencePacksToTechnologyUnitsByNames(technology_names, mode, { 'productivity-processor', 1 })
end
TechnologyUnitAddBean.addEffectivityProcessorToTechnologyUnits = function(technology_names, mode)
    addSciencePacksToTechnologyUnitsByNames(technology_names, mode, { 'effectivity-processor', 1 })
end
TechnologyUnitAddBean.addSpeedProcessorToTechnologyUnits = function(technology_names, mode)
    addSciencePacksToTechnologyUnitsByNames(technology_names, mode, { 'speed-processor', 1 })
end
TechnologyUnitAddBean.addTokenBioToTechnologyUnits = function(technology_names, mode)
    addSciencePacksToTechnologyUnitsByNames(technology_names, mode, { "token-bio", 1 })
end

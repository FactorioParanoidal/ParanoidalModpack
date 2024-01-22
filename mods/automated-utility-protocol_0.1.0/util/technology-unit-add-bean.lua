local techUtil = require("echnology-util")
local TechnologyUnitAddBean = {}
TechnologyUnitAddBean.technology_datas = data.raw["technology"]
local function addSciencePacksToTechnologyUnitsByNames(technology_names, mode, unit_ingredient)
	_table.each(technology_names, function(technology_name)
		log(
			" for technology_name " .. technology_name .. " add science pack " .. Utils.dump_to_console(unit_ingredient)
		)
		techUtil.addSciencePacksToTechnologyUnits(
			TechnologyUnitAddBean.technology_datas[technology_name],
			{ unit_ingredient },
			mode
		)
	end)
end
TechnologyUnitAddBean.addAutomationSciencePackToTechnologyUnits = function(technology_names, mode)
	addSciencePacksToTechnologyUnitsByNames(technology_names, mode, { "automation-science-pack", 1 })
end
TechnologyUnitAddBean.addLogisticSciencePackToTechnologyUnits = function(technology_names, mode)
	addSciencePacksToTechnologyUnitsByNames(technology_names, mode, { "logistic-science-pack", 1 })
end
TechnologyUnitAddBean.addChemicalSciencePackToTechnologyUnits = function(technology_names, mode)
	addSciencePacksToTechnologyUnitsByNames(technology_names, mode, { "chemical-science-pack", 1 })
end
TechnologyUnitAddBean.addProductionSciencePackToTechnologyUnits = function(technology_names, mode)
	addSciencePacksToTechnologyUnitsByNames(technology_names, mode, { "production-science-pack", 1 })
end
TechnologyUnitAddBean.addProductivityProcessorToTechnologyUnits = function(technology_names, mode)
	addSciencePacksToTechnologyUnitsByNames(technology_names, mode, { "productivity-processor", 1 })
end
TechnologyUnitAddBean.addEffectivityProcessorToTechnologyUnits = function(technology_names, mode)
	addSciencePacksToTechnologyUnitsByNames(technology_names, mode, { "effectivity-processor", 1 })
end
TechnologyUnitAddBean.addSpeedProcessorToTechnologyUnits = function(technology_names, mode)
	addSciencePacksToTechnologyUnitsByNames(technology_names, mode, { "speed-processor", 1 })
end
TechnologyUnitAddBean.addMilitarySciencePackToTechnologyUnits = function(technology_names, mode)
	addSciencePacksToTechnologyUnitsByNames(technology_names, mode, { "military-science-pack", 1 })
end
TechnologyUnitAddBean.addUtilitySciencePackToTechnologyUnits = function(technology_names, mode)
	addSciencePacksToTechnologyUnitsByNames(technology_names, mode, { "utility-science-pack", 1 })
end
TechnologyUnitAddBean.addTokenBioToTechnologyUnits = function(technology_names, mode)
	addSciencePacksToTechnologyUnitsByNames(technology_names, mode, { "token-bio", 1 })
end
TechnologyUnitAddBean.addAdvancedLogisticSciencePackToTechnologyUnits = function(technology_names, mode)
	addSciencePacksToTechnologyUnitsByNames(technology_names, mode, { "advanced-logistic-science-pack", 1 })
end
TechnologyUnitAddBean.addModuleCaseToTechnologyUnits = function(technology_names, mode)
	addSciencePacksToTechnologyUnitsByNames(technology_names, mode, { "module-case", 1 })
end

TechnologyUnitAddBean.addModuleCircuitBoardToTechnologyUnits = function(technology_names, mode)
	addSciencePacksToTechnologyUnitsByNames(technology_names, mode, { "module-circuit-board", 1 })
end

TechnologyUnitAddBean.addSpaceSciencePackToTechnologyUnits = function(technology_names, mode)
	addSciencePacksToTechnologyUnitsByNames(technology_names, mode, { "space-science-pack", 1 })
end

return TechnologyUnitAddBean

local tech_util = require("__automated-utility-protocol__.util.technology-util")
local TechnologyUnitAddBean = {}
TechnologyUnitAddBean.technology_datas = data.raw["technology"]
local function add_science_packs_to_technology_units_by_names(technology_names, mode, unit_ingredient)
	_table.each(technology_names, function(technology_name)
		log(
			" for technology_name " ..
			technology_name .. ', mode ' .. mode .. " add science pack " .. Utils.dump_to_console(unit_ingredient)
		)
		tech_util.add_science_packs_to_technology_units(
			TechnologyUnitAddBean.technology_datas[technology_name],
			{ unit_ingredient },
			mode
		)
	end)
end
TechnologyUnitAddBean.add_automation_science_pack_to_technology_units = function(technology_names, mode)
	add_science_packs_to_technology_units_by_names(technology_names, mode, { "automation-science-pack", 1 })
end
TechnologyUnitAddBean.add_logistic_science_pack_to_technology_units = function(technology_names, mode)
	add_science_packs_to_technology_units_by_names(technology_names, mode, { "logistic-science-pack", 1 })
end
TechnologyUnitAddBean.add_chemical_science_pack_to_technology_units = function(technology_names, mode)
	add_science_packs_to_technology_units_by_names(technology_names, mode, { "chemical-science-pack", 1 })
end
TechnologyUnitAddBean.add_production_science_pack_to_technology_units = function(technology_names, mode)
	add_science_packs_to_technology_units_by_names(technology_names, mode, { "production-science-pack", 1 })
end
TechnologyUnitAddBean.add_productivity_processor_to_technology_units = function(technology_names, mode)
	add_science_packs_to_technology_units_by_names(technology_names, mode, { "productivity-processor", 1 })
end
TechnologyUnitAddBean.add_effectivity_processor_to_technology_units = function(technology_names, mode)
	add_science_packs_to_technology_units_by_names(technology_names, mode, { "effectivity-processor", 1 })
end
TechnologyUnitAddBean.add_speed_processor_to_technology_units = function(technology_names, mode)
	add_science_packs_to_technology_units_by_names(technology_names, mode, { "speed-processor", 1 })
end
TechnologyUnitAddBean.add_military_science_pack_to_technology_units = function(technology_names, mode)
	add_science_packs_to_technology_units_by_names(technology_names, mode, { "military-science-pack", 1 })
end
TechnologyUnitAddBean.add_utility_science_pack_to_technology_units = function(technology_names, mode)
	add_science_packs_to_technology_units_by_names(technology_names, mode, { "utility-science-pack", 1 })
end
TechnologyUnitAddBean.add_space_science_pack_to_technology_units = function(technology_names, mode)
	add_science_packs_to_technology_units_by_names(technology_names, mode, { "space-science-pack", 1 })
end
TechnologyUnitAddBean.add_token_bio_to_technology_units = function(technology_names, mode)
	add_science_packs_to_technology_units_by_names(technology_names, mode, { "token-bio", 1 })
end
TechnologyUnitAddBean.add_advanced_logistic_science_pack_to_technology_units = function(technology_names, mode)
	add_science_packs_to_technology_units_by_names(technology_names, mode, { "advanced-logistic-science-pack", 1 })
end
TechnologyUnitAddBean.add_module_case_to_technology_units = function(technology_names, mode)
	add_science_packs_to_technology_units_by_names(technology_names, mode, { "module-case", 1 })
end

TechnologyUnitAddBean.add_module_circuit_board_to_technology_units = function(technology_names, mode)
	add_science_packs_to_technology_units_by_names(technology_names, mode, { "module-circuit-board", 1 })
end



return TechnologyUnitAddBean

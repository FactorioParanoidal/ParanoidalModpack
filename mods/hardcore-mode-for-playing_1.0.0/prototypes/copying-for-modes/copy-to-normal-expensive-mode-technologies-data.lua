local technology_data_field_names = {
	"upgrade",
	"enabled",
	"hidden",
	"visible_when_disabled",
	"ignore_tech_cost_multiplier",
	"unit",
	"max_level",
	"prerequisites",
	"effects",
}

local function createTechnologyDataFromGeneralTechnologyData(technology)
	local result = {}
	_table.each(technology_data_field_names, function(technology_data_field_name)
		if type(technology[technology_data_field_name]) == "table" then
			result[technology_data_field_name] = _table.deep_copy(technology[technology_data_field_name])
		else
			result[technology_data_field_name] = technology[technology_data_field_name]
		end
	end)
	return result
end

local technologies = data.raw["technology"]

_table.each(GAME_MODES, function(mode)
	local technology_names = techUtil.getAllTechnologyNamesWithHidden()
	_table.each(technology_names, function(technology_name)
		local technology = technologies[technology_name]
		local technology_data = createTechnologyDataFromGeneralTechnologyData(technology)
		if not technologies[technology_name][mode] then
			technologies[technology_name][mode] = technology_data
			return
		end
		local for_merging_technology_data = technologies[technology_name][mode]
		_table.merge(for_merging_technology_data, technology_data)
	end)
end)
local function clearTechnologyData(technology)
	_table.each(technology_data_field_names, function(technology_data_field_name)
		technology[technology_data_field_name] = nil
	end)
end

_table.each(GAME_MODES, function(mode)
	local technology_names = techUtil.getAllTechnologyNamesWithHidden()
	_table.each(technology_names, function(technology_name)
		local technology = technologies[technology_name]
		clearTechnologyData(technology)
		log(
			"for mode "
				.. mode
				.. " technology named "
				.. technology_name
				.. " is after copying for modes "
				.. Utils.dump_to_console(technology)
		)
	end)
end)

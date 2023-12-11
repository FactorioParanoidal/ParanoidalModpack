local techUtil = require("__automated-utility-protocol__.util.technology-util")
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
local technology_data_field_simple_names = {
	"upgrade",
	"enabled",
	"hidden",
	"visible_when_disabled",
	"ignore_tech_cost_multiplier",
	"max_level",
}
local function createTechnologyDataFromGeneralTechnologyData(technology)
	local result = {}
	_table.each(technology_data_field_names, function(technology_data_field_name)
		if technology[technology_data_field_name] and type(technology[technology_data_field_name]) == "table" then
			result[technology_data_field_name] = _table.deep_copy(technology[technology_data_field_name])
		else
			result[technology_data_field_name] = technology[technology_data_field_name]
		end
	end)
	return result
end

local function mergeTechnologyData(for_merging_technology_data_mode, technology_data_general)
	_table.each(technology_data_field_names, function(technology_data_field_name)
		if _table.contains(technology_data_field_simple_names, technology_data_field_name) then
			if
				type(for_merging_technology_data_mode[technology_data_field_name]) == "boolean"
				or type(technology_data_general[technology_data_field_name]) == "boolean"
			then
				for_merging_technology_data_mode[technology_data_field_name] =
					technology_data_general[technology_data_field_name]
			else
				for_merging_technology_data_mode[technology_data_field_name] = technology_data_general[technology_data_field_name]
					or for_merging_technology_data_mode[technology_data_field_name]
			end
			return
		end
		if not for_merging_technology_data_mode[technology_data_field_name] then
			for_merging_technology_data_mode[technology_data_field_name] =
				technology_data_general[technology_data_field_name]
			return
		end
		if
			for_merging_technology_data_mode[technology_data_field_name]
			and technology_data_general[technology_data_field_name]
		then
			_table.insert_all_if_not_exists(
				for_merging_technology_data_mode[technology_data_field_name],
				technology_data_general[technology_data_field_name]
			)
		end
	end)
end

_table.each(GAME_MODES, function(mode)
	local technologies = data.raw["technology"]
	local technology_names = techUtil.getAllTechnologyNamesWithHidden()
	_table.each(technology_names, function(technology_name)
		local technology = technologies[technology_name]
		local technology_data_general = createTechnologyDataFromGeneralTechnologyData(technology)
		if not technologies[technology_name][mode] then
			technologies[technology_name][mode] = technology_data_general
			return
		end
		local for_merging_technology_data_mode = technologies[technology_name][mode]
		mergeTechnologyData(for_merging_technology_data_mode, technology_data_general)
	end)
end)
local function clearTechnologyData(technology)
	_table.each(technology_data_field_names, function(technology_data_field_name)
		technology[technology_data_field_name] = nil
	end)
end

_table.each(GAME_MODES, function(mode)
	local technologies = data.raw["technology"]
	local technology_names = techUtil.getAllTechnologyNamesWithHidden()
	_table.each(technology_names, function(technology_name)
		local technology = technologies[technology_name]
		clearTechnologyData(technology)
		--[[log(
			"for mode "
				.. mode
				.. " technology named "
				.. technology_name
				.. " is after copying for modes "
				.. Utils.dump_to_console(technology)
		)]]
	end)
end)

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
local function create_technology_data_from_general_technology_data(technology)
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

local function merge_technology_data_and_general_data(for_merging_technology_data_mode, technology_data_general)
	_table.each(technology_data_field_names, function(technology_data_field_name)
		if not technology_data_general[technology_data_field_name] then
			--log("property '" .. technology_data_field_name .. "' not specified in general data!")
			return
		end
		if _table.contains(technology_data_field_simple_names, technology_data_field_name) then
			for_merging_technology_data_mode[technology_data_field_name] =
				technology_data_general[technology_data_field_name]
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

--сначала сливаем 2 режима.
_table.each(GAME_MODES, function(mode)
	_table.each(data.raw["technology"], function(technology)
		local technology_data_general = create_technology_data_from_general_technology_data(technology)
		if not technology[mode] then
			technology[mode] = technology_data_general
			return
		end
		local for_merging_technology_data_mode = technology[mode]
		merge_technology_data_and_general_data(for_merging_technology_data_mode, technology_data_general)
	end)
end)

local function clear_general_technology_data(technology)
	_table.each(technology_data_field_names, function(technology_data_field_name)
		technology[technology_data_field_name] = nil
	end)
end
--затем убираем общее между режима без указания режима.
local technologies = data.raw["technology"]
_table.each(technologies, function(technology)
	clear_general_technology_data(technology)
end)

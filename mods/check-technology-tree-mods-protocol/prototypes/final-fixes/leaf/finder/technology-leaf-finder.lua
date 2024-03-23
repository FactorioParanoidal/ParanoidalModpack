local techUtil = require("__automated-utility-protocol__.util.technology-util")
local TechnologyLeafFinder = {}

local function get_technology_object_for_mode(technology_name, mode)
	return Utils.get_moded_object(data.raw["technology"][technology_name], mode)
end

local function mark_technology_as_leaf(result, technology_name, all_technology_names, mode)
	local count = 0
	local descedants = {}
	_table.each(all_technology_names, function(another_technology_name)
		local another_technology = get_technology_object_for_mode(another_technology_name, mode)
		if another_technology.prerequisites and _table.contains(another_technology.prerequisites, technology_name) then
			count = count + 1
			table.insert(descedants, another_technology_name)
			return
		end
	end)
	if count == 0 then
		if settings.startup["debug_output"] then
			log("leaf technology name " .. technology_name)
		end
		_table.insert(result, technology_name)
	end
end

TechnologyLeafFinder.get_leaf_technologies_for_resetting_dependenies = function(mode)
	local result = {}
	local all_technology_names = techUtil.get_all_active_technology_names(mode)
	local all_technology_name_count = _table.size(all_technology_names)
	if settings.startup["debug_output"] then
		log("all_technology_name_count " .. all_technology_name_count)
		log("all_technology_names " .. Utils.dump_to_console(all_technology_names))
	end
	_table.each(all_technology_names, function(technology_name)
		mark_technology_as_leaf(result, technology_name, all_technology_names, mode)
	end)
	return result
end

return TechnologyLeafFinder

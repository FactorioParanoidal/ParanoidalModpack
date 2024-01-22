require("technology-tree-cache-util")
TechnologyTreeUtil = {}

local MAX_INTEGER = 10000

local function getTechnologyObjectForMode(technology_name, mode)
	return Utils.getModedObject(data.raw["technology"][technology_name], mode)
end

TechnologyTreeUtil.findPrerequisitesForTechnologyForSpecifiedLevel = function(technology_name, level, max_level, mode)
	if type(technology_name) == "table" then
		error(Utils.dump_to_console(technology_name))
	end
	local cached_technology_tree = TechnologyTreeCacheUtil.getTechnologyFromCacheTree(technology_name, mode)
	if cached_technology_tree then
		return cached_technology_tree
	end
	local result = {}
	if level > max_level then
		return result
	end
	local technology_object = getTechnologyObjectForMode(technology_name, mode)
	if not technology_object then
		error("technology object for technology_name " .. technology_name .. " and mode" .. mode .. " not found!")
	end
	local prerequisites = technology_object.prerequisites
	if prerequisites == nil then
		return {}
	end
	_table.each(prerequisites, function(prerequisite_name)
		_table.insert_all_if_not_exists(
			result,
			TechnologyTreeUtil.findPrerequisitesForTechnologyForSpecifiedLevel(
				prerequisite_name,
				level + 1,
				max_level,
				mode
			)
		)
		table.insert(result, prerequisite_name)
	end)
	TechnologyTreeCacheUtil.addTechnologyToCacheTree(technology_name, result, mode)
	return result
end

TechnologyTreeUtil.findPrerequisitesForTechnologyForFirstLevel = function(technology_name, mode)
	local result = TechnologyTreeUtil.findPrerequisitesForTechnologyForSpecifiedLevel(technology_name, 1, 1, mode)
	return result
end

TechnologyTreeUtil.findPrerequisitesForTechnologyForAllLevels = function(technology_name, mode)
	local result =
		TechnologyTreeUtil.findPrerequisitesForTechnologyForSpecifiedLevel(technology_name, 1, MAX_INTEGER, mode)
	return result
end

TechnologyTreeUtil.haveTechnologyInTree = function(technology_name, prerequisite_technology_candidate_name, mode)
	if
		not technology_name
		or not prerequisite_technology_candidate_name
		or prerequisite_technology_candidate_name == technology_name
	then
		return true
	end
	local prerequisites = TechnologyTreeUtil.findPrerequisitesForTechnologyForAllLevels(technology_name, mode)
	return _table.contains(prerequisites, prerequisite_technology_candidate_name)
end

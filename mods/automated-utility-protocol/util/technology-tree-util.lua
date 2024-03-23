require("__automated-utility-protocol__.util.technology-tree-cache-util")
TechnologyTreeUtil = {}

local MAX_INTEGER = 10000

local function get_technology_object_for_mode(technology_name, mode)
	return Utils.get_moded_object(data.raw["technology"][technology_name], mode)
end

TechnologyTreeUtil.find_prerequisites_for_technology_for_specified_level = function(
	technology_name,
	level,
	max_level,
	mode
)
	if type(technology_name) == "table" then
		error(Utils.dump_to_console(technology_name))
	end
	local cached_technology_tree = TechnologyTreeCacheUtil.get_technology_from_cache_tree(technology_name, mode)
	if cached_technology_tree then
		return cached_technology_tree
	end
	local result = {}
	if level > max_level then
		return result
	end
	local technology_object = get_technology_object_for_mode(technology_name, mode)
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
			TechnologyTreeUtil.find_prerequisites_for_technology_for_specified_level(
				prerequisite_name,
				level + 1,
				max_level,
				mode
			)
		)
		table.insert(result, prerequisite_name)
	end)
	TechnologyTreeCacheUtil.add_technology_to_cache_tree(technology_name, result, mode)
	return result
end

TechnologyTreeUtil.find_prerequisites_for_technology_for_first_level = function(technology_name, mode)
	local result = TechnologyTreeUtil.find_prerequisites_for_technology_for_specified_level(technology_name, 1, 1, mode)
	_table.remove_item(result, technology_name, nil, true)
	return result
end

TechnologyTreeUtil.find_prerequisites_for_technology_for_all_levels = function(technology_name, mode)
	local result =
		TechnologyTreeUtil.find_prerequisites_for_technology_for_specified_level(technology_name, 1, MAX_INTEGER, mode)
	_table.remove_item(result, technology_name, nil, true)

	return result
end

TechnologyTreeUtil.have_technology_in_tree = function(technology_name, prerequisite_technology_candidate_name, mode)
	if
		not technology_name
		or not prerequisite_technology_candidate_name
		or prerequisite_technology_candidate_name == technology_name
	then
		return true
	end
	local prerequisites = TechnologyTreeUtil.find_prerequisites_for_technology_for_all_levels(technology_name, mode)
	return _table.contains(prerequisites, prerequisite_technology_candidate_name)
end
local function print_technology_tree0(mode, technology_name, level, visited_technologies)
	local prefix = ""
	for i = 0, level - 1 do
		prefix = prefix .. "|"
	end
	prefix = prefix .. "-"
	if _table.contains(visited_technologies, technology_name) then
		return
	end
	table.insert(visited_technologies, technology_name)
	local tree = TechnologyTreeUtil.find_prerequisites_for_technology_for_first_level(technology_name, mode)
	if not tree or _table.size(tree) == 0 then
		return
	end
	_table.each(tree, function(tree_element_name)
		log(prefix .. tree_element_name)
		print_technology_tree0(mode, tree_element_name, level + 1, visited_technologies)
	end)
end

TechnologyTreeUtil.print_technology_tree = function(mode, technology_name)
	log("tree of")
	log(technology_name)
	print_technology_tree0(mode, technology_name, 0, {})
end

TechnologyTreeUtil = {}

local MAX_INTEGER = 10000

local function get_technology_object_for_mode(technology_name, mode)
    return Utils.get_moded_object("technology", technology_name, mode)
end

--[[TechnologyTreeUtil.find_prerequisites_for_technology_for_first_level = function(technology_name, mode)
	return get_technology_object_for_mode(technology_name, mode).prerequisites or {}
end]]

TechnologyTreeUtil.find_prerequisites_for_technology_for_all_levels = function(technology_name, mode)
    local result = {}
    local technology_tree = TechnologyTreeUtil.get_technology_tree(technology_name, mode)
    _table.each(technology_tree, function(technology_tree_element_table)
        _table.insert_all_if_not_exists(result, technology_tree_element_table)
    end)
    return result
end

local function have_technology_in_tree0(technology_tree, prerequisite_technology_candidate_name)
    local found = false
    _table.each(technology_tree, function(technology_element_table)
        if found then
            return
        end
        found = _table.contains(technology_element_table, prerequisite_technology_candidate_name)
    end)
    return found
end
TechnologyTreeUtil.have_technology_in_tree = function(technology_name, prerequisite_technology_candidate_name, mode)
    if not technology_name or not prerequisite_technology_candidate_name then
        return false
    end
    if prerequisite_technology_candidate_name == technology_name then
        return true
    end
    local technology_tree = TechnologyTreeUtil.get_technology_tree(technology_name, mode)
    return have_technology_in_tree0(technology_tree, prerequisite_technology_candidate_name)
end
local function get_technology_tree0(technology_name, mode, visited_technologies, target_tree)
    local tree = get_technology_object_for_mode(technology_name, mode).prerequisites
    if not visited_technologies[technology_name] then
        visited_technologies[technology_name] = {}
    end
    if not tree or _table.size(tree) == 0 then
        return
    end
    if not target_tree[technology_name] then
        target_tree[technology_name] = {}
    end
    _table.each(tree, function(tree_element_name)
        _table.insert(target_tree[technology_name], tree_element_name)
        if not _table.contains(visited_technologies[technology_name], tree_element_name) then
            get_technology_tree0(tree_element_name, mode, visited_technologies, target_tree)
            _table.insert(visited_technologies[technology_name], tree_element_name)
        end
    end)
end
TechnologyTreeUtil.get_technology_tree = function(technology_name, mode)
    local target_tree = {}
    get_technology_tree0(technology_name, mode, {}, target_tree)
    return target_tree
end
local function print_technology_tree0(technology_name, mode, level, visited_technologies)
    local prefix = ""
    for i = 0, level - 1 do
        prefix = prefix .. "|"
    end
    prefix = prefix .. "-"
    local tree = get_technology_object_for_mode(technology_name, mode).prerequisites

    if not visited_technologies[technology_name] then
        visited_technologies[technology_name] = {}
    end
    if not tree or _table.size(tree) == 0 then
        return
    end
    _table.each(tree, function(tree_element_name)
        log(prefix .. tree_element_name)
        if not _table.contains(visited_technologies[technology_name], tree_element_name) then
            print_technology_tree0(tree_element_name, mode, level + 1, visited_technologies)
            _table.insert(visited_technologies[technology_name], tree_element_name)
        end
    end)
end

TechnologyTreeUtil.print_technology_tree = function(technology_name, mode)
    log("tree of")
    log(technology_name)
    print_technology_tree0(technology_name, mode, 1, {})
end

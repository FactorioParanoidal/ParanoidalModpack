TechnologyTreeUtil = {}

local MAX_INTEGER = 1000

local function getTechnologyObjectForMode(technology_name, mode)
    return Utils.getModedObject(data.raw["technology"][technology_name], mode)
end

TechnologyTreeUtil.findDependenciesForTechnologyForSpecifiedLevel = function(technology_name, level, max_level, mode)
    if (type(technology_name) == "table") then
        error(Utils.dump_to_console(technology_name))
    end
    local cached_technology_tree = TechnologyTreeCacheUtil.getTechnologyFromCacheTree(technology_name, mode)
    if cached_technology_tree then
        return cached_technology_tree
    end
    local result = {}
    if level > max_level then return result end
    local technology_object = getTechnologyObjectForMode(technology_name, mode)
    if not technology_object then
        error('technology object for technology_name ' .. technology_name .. ' and mode' .. mode .. ' not found!')
    end
    local prerequisites = technology_object.prerequisites
    if prerequisites == nil then
        return {}
    end
    local tempResult = {}
    _table.each(prerequisites,
        function(prerequisite_name)
            tempResult[prerequisite_name] = TechnologyTreeUtil.findDependenciesForTechnologyForSpecifiedLevel(
                prerequisite_name,
                level + 1, max_level, mode)
        end)
    _table.each(tempResult,
        function(prerequisite_names, key)
            _table.insert_all_if_not_exists(result, prerequisite_names)
            table.insert(result, key)
        end)
    TechnologyTreeCacheUtil.addTechnologyToCacheTree(technology_name, result, mode)
    return result
end

TechnologyTreeUtil.findParentsForTechnologyForFirstLevel = function(technology_name, mode)
    return TechnologyTreeUtil.findDependenciesForTechnologyForSpecifiedLevel(technology_name, 0, 1, mode)
end


TechnologyTreeUtil.findDependenciesForTechnologyForAllLevels = function(technology_name, mode)
    return TechnologyTreeUtil.findDependenciesForTechnologyForSpecifiedLevel(technology_name, 1, MAX_INTEGER, mode)
end

TechnologyTreeUtil.haveTechnologyInTree = function(technology_name, dependency_technology_name, mode)
    if not technology_name or not dependency_technology_name or dependency_technology_name == technology_name then
        return true
    end
    local dependencies = TechnologyTreeUtil.findDependenciesForTechnologyForAllLevels(technology_name, mode)
    return _table.contains(dependencies, dependency_technology_name)
end

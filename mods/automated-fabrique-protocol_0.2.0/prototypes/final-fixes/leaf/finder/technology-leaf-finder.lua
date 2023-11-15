local TechnologyLeafFinder = {}

local function getTechnologyObjectForMode(technology_name, mode)
    return Utils.getModedObject(data.raw["technology"][technology_name], mode)
end

local function markLeafTechnology(result, technology_name, all_technology_names, mode)
    local count = 0
    local descedants = {}
    _table.each(all_technology_names,
        function(another_technology_name)
            local another_technology = getTechnologyObjectForMode(another_technology_name, mode)
            if another_technology.prerequisites and _table.contains(another_technology.prerequisites, technology_name) then
                count = count + 1
                table.insert(descedants, another_technology_name)
                return
            end
        end)
    if count == 0 then
        _table.insert(result, technology_name)
    end
end

TechnologyLeafFinder.getLeafTechnologiesForResettingDependenies = function(mode)
    local result = {}
    local all_technology_names = techUtil.getAllActiveTechnologyNames()
    local all_technology_name_count = _table.size(all_technology_names)
    log('all_technology_name_count ' .. all_technology_name_count)
    log('all_technology_names ' .. Utils.dump_to_console(all_technology_names))
    _table.each(all_technology_names,
        function(technology_name)
            markLeafTechnology(result, technology_name, all_technology_names, mode)
        end)
    return result
end

return TechnologyLeafFinder

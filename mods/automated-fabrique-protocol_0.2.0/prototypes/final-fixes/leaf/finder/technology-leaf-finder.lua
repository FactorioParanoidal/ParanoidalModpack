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

local function filterTechnologyDataHasRecipes(technology_name, mode)
    local technology = getTechnologyObjectForMode(technology_name, mode)
    return technology
        and technology.effects and _table.size(technology.effects) > 0
        and _table.size(_table.filter(technology.effects,
            function(effect)
                return effect.type == 'unlock-recipe' and effect.recipe
            end)) > 0
end

local function getAllActiveTechnologyNames(mode)
    local result = {}
    _table.each(data.raw["technology"],
        function(technology)
            local technology_name = technology.name
            if not technology.hidden and filterTechnologyDataHasRecipes(technology_name, mode) then
                table.insert(result, technology_name)
            end
        end)
    return result
end


TechnologyLeafFinder.getLeafTechnologiesForResettingDependenies = function(mode)
    local result = {}
    local all_technology_names = getAllActiveTechnologyNames(mode)
    _table.each(all_technology_names,
        function(technology_name)
            markLeafTechnology(result, technology_name, all_technology_names, mode)
        end)
    return result
end

return TechnologyLeafFinder

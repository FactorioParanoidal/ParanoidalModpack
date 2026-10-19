--[[
This file is part of the mod InserterFuelLeech that is licensed under the
GNU GPL-3.0. See the file COPYING for a copy of the GNU GPLv3.0.
]]

local resolveQuality = resolveQuality

--- @type table<string,(fun(a: integer, b: integer): boolean)?>
local qualityComparators = {
    ["="] = function(a, b) return a == b end,
    [">"] = function(a, b) return a > b end,
    ["<"] = function(a, b) return a < b end,
    ["≥"] = function(a, b) return a >= b end,
    ["≤"] = function(a, b) return a <= b end,
    ["≠"] = function(a, b) return a ~= b end,
}

--- @param itemFilter ItemFilter?
--- @param itemName string
--- @param itemQualityLevel integer
--- @return boolean
function isFilterMatching(itemFilter, itemName, itemQualityLevel)
    if not itemFilter then
        return false
    end

    if type(itemFilter) == "string" then
        return itemName == itemFilter
    end
    local filterName = itemFilter.name
    if filterName and itemName ~= itemIdToName(filterName) then
        return false
    end

    local filterQuality = resolveQuality(itemFilter.quality)
    local filterQualityComparator = qualityComparators[itemFilter.comparator]
    if filterQuality and filterQualityComparator then
        local filterQualityLevel = filterQuality.level
        return filterQualityComparator(itemQualityLevel, filterQualityLevel)
    end

    if filterName then
        return true
    end
    return false
end

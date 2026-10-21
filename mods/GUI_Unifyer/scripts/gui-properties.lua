-- Compare live properties rather than caching them: other mods own these elements
-- and may change or recreate them between our updates.
local M = {}

local function equal(a, b)
    if a == b then return true end
    if type(a) ~= "table" or type(b) ~= "table" then return false end
    for key, value in pairs(a) do
        if not equal(value, b[key]) then return false end
    end
    for key in pairs(b) do
        if a[key] == nil then return false end
    end
    return true
end

function M.set(element, property, value)
    if not equal(element[property], value) then
        element[property] = value
    end
end

function M.style(element, name)
    if element.style.name ~= name then
        element.style = name
    end
end

return M

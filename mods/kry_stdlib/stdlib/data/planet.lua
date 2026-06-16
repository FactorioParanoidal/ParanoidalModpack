local Data = require('__kry_stdlib__/stdlib/data/data') --[[@as StdLib.Data]]
local Space = require('__kry_stdlib__/stdlib/data/space')

--- Planet (mainly just a placeholder for Space, to automatically wrap around planets)
--- @class StdLib.Data.Planet : StdLib.Data
local Planet = {
    __class = 'Planet',
}

-- Custom __index function for function inheritance from both Space and Data.
Planet.__index = function(table, key)
    -- Check if the key exists in Space first.
    if Space[key] then
        return Space[key]
    -- If not found in Space, fallback to Data.
    elseif Data[key] then
        return Data[key]
    end
    -- Return nil if key is not found in either Space or Data.
    return nil
end

function Planet:__call(planet)
    local new = self:get(planet, 'planet')
    return new
end

setmetatable(Planet, Planet)

return Planet
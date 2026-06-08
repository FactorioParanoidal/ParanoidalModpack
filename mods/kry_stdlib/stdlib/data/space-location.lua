local Data = require('__kry_stdlib__/stdlib/data/data') --[[@as StdLib.Data]]
local Space = require('__kry_stdlib__/stdlib/data/space')

--- SpaceLocation
--- @class StdLib.Data.SpaceLocation : StdLib.Data.Space
local SpaceLocation = {
    __class = 'SpaceLocation',
}

-- Custom __index function for function inheritance from both Space and Data.
SpaceLocation.__index = function(table, key)
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

function SpaceLocation:__call(space_location)
    local new = self:get(space_location, 'space-location')
    return new
end

setmetatable(SpaceLocation, SpaceLocation)

return SpaceLocation
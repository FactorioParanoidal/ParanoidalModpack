local Data = require('__kry_stdlib__/stdlib/data/data') --[[@as StdLib.Data]]
local Space = require('__kry_stdlib__/stdlib/data/space')

--- SpaceConnection
--- @class StdLib.Data.SpaceConnection : StdLib.Data.Space
local SpaceConnection = {
    __class = 'SpaceConnection',
}

-- Custom __index function for function inheritance from both Space and Data.
SpaceConnection.__index = function(table, key)
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

function SpaceConnection:__call(space_connection)
    local new = self:get(space_connection, 'space-connection')
    return new
end

setmetatable(SpaceConnection, SpaceConnection)

return SpaceConnection
-- For working with chunks.

--- A chunk represents a 32 tile<sup>2</sup> on a surface in Factorio.
--- @class StdLib.Area.Chunk : StdLib.Core
--- @usage local Chunk = require('__kry_stdlib__/stdlib/area/chunk')
--- @see ChunkPosition
local Chunk = {
    __class = 'Chunk',
    __index = require('__kry_stdlib__/stdlib/core')
}
setmetatable(Chunk, Chunk)

local Game = require('__kry_stdlib__/stdlib/game') --[[@as StdLib.Game]]
local Position = require('__kry_stdlib__/stdlib/area/position') --[[@as StdLib.Area.Position]]

local AREA_PATH = '__kry_stdlib__/stdlib/area/area'

Chunk.__call = Position.__call

--- Gets the chunk position of a chunk where the specified position resides.
-- @function Chunk.from_position
-- @see StdLib.Area.Position.to_chunk_position
Chunk.from_position = Position.to_chunk_position

--- Gets the top_left position from a chunk position.
-- @function Chunk.to_position
-- @see StdLib.Area.Position.from_chunk_position
Chunk.to_position = Position.from_chunk_position

--Chunk.to_center_position
--Chunk.to_center_tile_position

-- Hackish function, Factorio lua doesn't allow require inside functions because...
local function load_area(area)
    local Area = package.loaded[AREA_PATH]
    if not Area then
        local log = log or function(_msg_) end
        log('WARNING: Area for Position not found in package.loaded')
    end
    return Area and Area.load(area) or area
end

--- Gets the area of a chunk from the specified chunk position.
--- @param pos ChunkPosition the chunk position
--- @return BoundingBox the chunk's area
function Chunk.to_area(pos)
    local left_top = Chunk.to_position(pos)
    local right_bottom = Position.add(left_top, 32, 32)

    return load_area { left_top = left_top, right_bottom = right_bottom }
end

--- Gets the user data that is associated with a chunk.
-- The user data is stored in the global object and it persists between loads.
--- @param surface LuaSurface the surface on which the user data is looked up
--- @param chunk_pos ChunkPosition the chunk position on which the user data is looked up
--- @param default_value any the user data to set for the chunk and returned if the chunk had no user data
--- @return any? #the user data **OR** *nil* if it does not exist for the chunk and if no default_value was set
function Chunk.get_data(surface, chunk_pos, default_value)
    local surface = Game.get_surface(surface)
    assert(surface, 'invalid surface')
    local key = Position(chunk_pos):to_key()
    return Game.get_or_set_data('_chunk_data', surface.index, key, false, default_value)
end
Chunk.get = Chunk.get_data

--- Associates the user data to a chunk.
-- The user data will be stored in the global object and it will persist between loads.
--- @param surface LuaSurface the surface on which the user data will reside
--- @param chunk_pos ChunkPosition the chunk position to associate with the user data
--- @param value any? the user data to set **OR** *nil* to erase the existing user data for the chunk
--- @return any? #the previous user data associated with the chunk **OR** *nil* if the chunk had no previous user data
function Chunk.set_data(surface, chunk_pos, value)
    local surface = Game.get_surface(surface)
    assert(surface, 'invalid surface')
    local key = Position(chunk_pos):to_key()
    return Game.get_or_set_data('_chunk_data', surface.index, key, true, value)
end
Chunk.set = Chunk.set_data

return Chunk

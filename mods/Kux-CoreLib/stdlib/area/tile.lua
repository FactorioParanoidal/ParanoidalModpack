--- Tools for working with tiles.
--- A tile represents a 1 unit<sup>2</sup> on a surface in Factorio.
--- @class StdLib.Area.Tile : StdLib.Core
--- @usage local Tile = require('__Kux-CoreLib__/stdlib/area/tile')
--- @see LuaTile
local Tile = {
    __class = 'Tile',
    __index = require('__Kux-CoreLib__/stdlib/core') --[[@as StdLib.Core]]
}
setmetatable(Tile, Tile)

local Is = require('__Kux-CoreLib__/stdlib/utils/is') --[[@as StdLib.Utils.Is]]
local Game = require('__Kux-CoreLib__/stdlib/game') --[[@as StdLib.Game]]
local Position = require('__Kux-CoreLib__/stdlib/area/position')--[[@as StdLib.Area.Position]]

Tile.__call = Position.__call

--- Get the @{TilePosition|tile position} of a tile where the given position resides.
-- @function Tile.from_position
-- @see StdLib.Area.Position.floor
Tile.from_position = Position.floor

--- Converts a tile position to the @{BoundingBox|area} of the tile it is in.
-- @function Tile.to_area
-- @see StdLib.Area.Position.to_tile_area
Tile.to_area = Position.to_tile_area

--- Creates an array of tile positions for all adjacent tiles (N, E, S, W) **OR** (N, NE, E, SE, S, SW, W, NW) if diagonal is set to true.
--- @param surface LuaSurface the surface to examine for adjacent tiles
--- @param position TilePosition the tile position of the origin tile
--- @param diagonal boolean? [opt=false] whether to include diagonal tiles
--- @paramtile_name string? [opt] whether to restrict adjacent tiles to a particular tile name (example: "water-tile")
--- @return TilePosition[] #an array of tile positions of the tiles that are adjacent to the origin tile
function Tile.adjacent(surface, position, diagonal, tile_name)
    Is.Assert(surface, 'missing surface argument')
    Is.Assert(position, 'missing position argument')

    local offsets = { { 0, 1 }, { 1, 0 }, { 0, -1 }, { -1, 0 } }
    if diagonal then
        offsets = { { 0, 1 }, { 1, 1 }, { 1, 0 }, { -1, 1 }, { -1, 0 }, { -1, -1 }, { 0, -1 }, { 1, -1 } }
    end
    local adjacent_tiles = {}
    for _, offset in pairs(offsets) do
        local adj_pos = Position.add(position, offset)
        if tile_name then
            local tile = surface.get_tile(adj_pos.x, adj_pos.y)
            if tile and tile.name == tile_name then
                table.insert(adjacent_tiles, adj_pos)
            end
        else
            table.insert(adjacent_tiles, adj_pos)
        end
    end
    return adjacent_tiles
end

--- Gets the user data that is associated with a tile.
-- The user data is stored in the global object and it persists between loads.
--- @param surface LuaSurface the surface on which the user data is looked up
--- @param tile_pos TilePosition the tile position on which the user data is looked up
--- @param default_value any the user data to set for the tile and returned if it did not have user data
--- @return any? #the user data **OR** *nil* if it does not exist for the tile and no default_value was set
function Tile.get_data(surface, tile_pos, default_value)
    local surface = Game.get_surface(surface)
    assert(surface, 'invalid surface')
    local key = Position.to_key(Position.floor(tile_pos))
    return Game.get_or_set_data('_tile_data', surface.index, key, false, default_value)
end
Tile.get = Tile.get_data

--- Associates the user data to a tile.
-- The user data will be stored in the global object and it will persist between loads.
--- @param surface LuaSurface the surface on which the user data will reside
--- @param tile_pos TilePosition the tile position of a tile that will be associated with the user data
--- @param value any? the user data to set **OR** *nil* to erase the existing user data for the tile
--- @return any? #the previous user data associated with the tile **OR** *nil* if the tile had no previous user data
function Tile.set_data(surface, tile_pos, value)
    local surface = Game.get_surface(surface)
    assert(surface, 'invalid surface')
    local key = Position.to_key(Position.floor(tile_pos))
    return Game.get_or_set_data('_tile_data', surface.index, key, true, value)
end
Tile.set = Tile.set_data

return Tile

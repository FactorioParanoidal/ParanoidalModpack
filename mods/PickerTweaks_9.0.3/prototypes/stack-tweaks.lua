--(( Tile stack sizes ))--
local tile_size = settings.startup['picker-tile-stack'].value
if tile_size > 0 then
    for _, tile in pairs(data.raw.item) do
        local is_tile = tile.place_as_tile
        if is_tile and tile.stack_size < tile_size then
            tile.stack_size = tile_size
        end
    end
end
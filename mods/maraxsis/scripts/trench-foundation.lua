local VANILLA_FOUNDATION = "foundation"
local TRENCH_FOUNDATION = "maraxsis-trench-foundation"
local TRENCH_LAVA = "lava-hot-underwater"

--- When foundation is placed, replace it with our special foundation that
--- includes the trench's building rules.
maraxsis.on_event(maraxsis.events.on_built_tile(), function(event)
    if event.tile.name ~= VANILLA_FOUNDATION then return end

    local surface = game.get_surface(event.surface_index)
    if not surface then return end

    local tiles = {}
    for _, tile in pairs(event.tiles) do
        local name = tile.old_tile.name
        if name == TRENCH_LAVA then
            tiles[#tiles + 1] = {name = TRENCH_FOUNDATION, position = tile.position}
        end
    end
    if not tiles[1] then return end

    surface.set_tiles(tiles, true, false, true, false)
end)

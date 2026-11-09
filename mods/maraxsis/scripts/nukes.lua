local BLAST_RADIUS = 12

local TRENCH_FLOOR = {
    "volcanic-folds-underwater",
    "volcanic-cracks-hot-underwater",
    "volcanic-cracks-warm-underwater",
    "nuclear-ground-underwater",
}

local OCEAN_FLOOR = {
    "sand-1-underwater",
    "sand-2-underwater",
    "sand-3-underwater",
    "dirt-5-underwater",
    "lowland-cream-red-underwater",
    "lowland-red-vein-2-underwater",
}

local function set_tiles(surface, tiles)
    if tiles[1] then
        surface.set_tiles(tiles, true, false, true, false)
    end
end

--- The trench glow comes from lamp entities that map generation puts in a 4x4
--- grid over lava. Add any that are missing, so new lava glows too.
local function light_lava(surface, center)
    for _, tile in pairs(surface.find_tiles_filtered {position = center, radius = BLAST_RADIUS, name = "lava-hot-underwater"}) do
        local x, y = tile.position.x, tile.position.y
        if x % 4 == 0 and y % 4 == 0
            and surface.count_entities_filtered {name = "maraxsis-lava-lamp", position = {x, y}, radius = 0.5} == 0 then
            surface.create_entity {name = "maraxsis-lava-lamp", position = {x, y}}
        end
    end
end

--- Floor inside the lava biome becomes lava, and the rest becomes nuked ground.
local function nuke_trench(surface, center)
    local tiles = {}

    local positions = {}
    for i, tile in pairs(surface.find_tiles_filtered {position = center, radius = BLAST_RADIUS, name = TRENCH_FLOOR}) do
        positions[i] = tile.position
    end
    if positions[1] then
        local biome = surface.calculate_tile_properties({"maraxsis_lava_biome"}, positions).maraxsis_lava_biome
        for i, position in pairs(positions) do
            tiles[i] = {name = biome[i] > 0 and "lava-hot-underwater" or "nuclear-ground-underwater", position = position}
        end
    end

    for _, tile in pairs(surface.find_tiles_filtered {position = center, radius = BLAST_RADIUS, name = "maraxsis-trench-foundation"}) do
        tiles[#tiles + 1] = {name = "lava-hot-underwater", position = tile.position}
    end

    set_tiles(surface, tiles)
    light_lava(surface, center)
end

local function nuke_ocean(surface, center)
    local tiles = {}
    for _, tile in pairs(surface.find_tiles_filtered {position = center, radius = BLAST_RADIUS, name = OCEAN_FLOOR}) do
        tiles[#tiles + 1] = {name = "nuclear-ground-underwater", position = tile.position}
    end
    set_tiles(surface, tiles)

    -- Coral's a resource, so it won't get removed unless we do it.
    for _, coral in pairs(surface.find_entities_filtered {position = center, radius = BLAST_RADIUS, name = "maraxsis-coral"}) do
        coral.destroy()
    end
end

--- Raised by the explosions in `prototypes/nuke-effects.lua`, which only appear
--- on Maraxsis and in the trench.
maraxsis.on_event(defines.events.on_script_trigger_effect, function(event)
    if event.effect_id ~= "maraxsis-nuke-effects" then return end

    -- the position of the nuke is on the explosion's entity
    local explosion = event.target_entity
    if not explosion or not explosion.valid then return end
    local surface, center = explosion.surface, explosion.position

    if surface.name == maraxsis_constants.TRENCH_SURFACE_NAME then
        nuke_trench(surface, center)
    elseif surface.name == maraxsis_constants.MARAXSIS_SURFACE_NAME then
        nuke_ocean(surface, center)
    end
end)

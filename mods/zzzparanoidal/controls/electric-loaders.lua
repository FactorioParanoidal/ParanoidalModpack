-- Snapping adapted from Vanilla Loaders 2.2.1, Copyright (c) 2024 Kirazy (MIT).
-- Original upstream notes that the earlier snapping author's identity is unknown.
-- License: graphics/loaders/LICENSE-Vanilla-Loaders.txt.
local snap_targets = {
    "ammo-turret", "artillery-turret", "assembling-machine", "boiler", "container",
    "furnace", "infinity-container", "lab", "linked-container", "logistic-container",
    "mining-drill", "reactor", "rocket-silo", "straight-rail",
}
local directions = defines.direction
local offsets = {
    [directions.north] = { 0, -1 }, [directions.east] = { 1, 0 },
    [directions.south] = { 0, 1 }, [directions.west] = { -1, 0 },
}

local function snap(loader)
    if not settings.global["paranoidal-loader-auto-connect"].value then return end
    local original_direction, original_type = loader.direction, loader.loader_type
    local offset = offsets[original_direction]
    if not offset then return end
    local x, y = loader.position.x, loader.position.y
    local from = { x - offset[1], y - offset[2] }
    local to = { x + offset[1], y + offset[2] }
    local output = original_type == "output"
    local original_side = output and "outputs" or "inputs"
    local other_side = output and "inputs" or "outputs"
    if next(loader.belt_neighbours[original_side]) then return end

    loader.update_connections()
    local was_connected = loader.loader_container ~= nil
    loader.loader_type = output and "input" or "output"
    if next(loader.belt_neighbours[other_side]) then return end
    loader.direction = original_direction
    if next(loader.belt_neighbours[other_side]) then return end
    loader.update_connections()

    local function has_target(position)
        return loader.surface.count_entities_filtered {
            ghost_type = snap_targets, position = position, force = loader.force, limit = 1,
        } > 0 or loader.surface.count_entities_filtered {
            type = "straight-rail", position = position, force = loader.force, limit = 1,
        } > 0
    end
    if was_connected or has_target(output and from or to)
        or (not loader.loader_container and not has_target(output and to or from)) then
        loader.loader_type = original_type
        loader.direction = original_direction
    end
end

-- Event ownership is in loader-shells; export only the unchanged snapping algorithm.
return snap

-- AAI Industry crash scene around {0, 0} on a new map (old AAI crash sequence) with the start
-- contents of the AAI wrecks.
local config = require("shipwreck-config")
local quality = require("scripts.quality")
local M = {}

local function vector(orientation, length)
    return {x = length * math.sin(orientation * 2 * math.pi), y = -length * math.cos(orientation * 2 * math.pi)}
end

local function clear_trees(surface, range)
    for _, tree in pairs(surface.find_entities_filtered({type = "tree", area = {{-range, -range}, {range, range}}})) do
        local distance = math.sqrt(tree.position.x * tree.position.x + tree.position.y * tree.position.y)
        if math.random() > (distance / range) * 3 - 2 then
            -- Keep a few distant trees (the old scene left them for burning trees).
            if not (math.random() < 0.1 and distance > range / 2) then tree.destroy() end
        end
    end
end

local function fill(state, entity)
    local spec = config.wrecks[entity.name]
    if not (spec and spec.items) then return end
    for _, entry in ipairs(spec.items) do
        local count = quality.roll(entry)
        if count > 0 and quality.available(entry[1]) then
            entity.insert({name = entry[1], count = count, quality = quality.of(state, entry[1])})
        end
    end
end

-- The AAI wrecks have no water collision (prototypes/aai-wrecks.lua), so the free position search
-- does not see lakes: the centre and the corners of the big wreck box must be on land.
local PROBE = "aai-big-ship-wreck-1"
local LAND_TRIES = 30

local function on_land(surface, p)
    local probe = prototypes.entity[PROBE]
    if not probe then return true end
    local box = probe.collision_box
    for _, o in ipairs({{0, 0}, {box.left_top.x, box.left_top.y}, {box.right_bottom.x, box.left_top.y},
        {box.left_top.x, box.right_bottom.y}, {box.right_bottom.x, box.right_bottom.y}}) do
        local tile = surface.get_tile(p.x + o[1], p.y + o[2])
        if not tile.valid or tile.collides_with("water_tile") then return false end
    end
    return true
end

-- A free position on land for a part, a little further out on every failed try; the old
-- behaviour (the first free position, else the random point) only when there is no land at all.
local function land_position(surface, part, min_radius)
    local first
    for i = 1, LAND_TRIES do
        local radius = part.radius * (1 + (i - 1) / 10)
        local try_position = vector(math.random(), min_radius + (radius - min_radius) * math.random())
        local position = surface.find_non_colliding_position(PROBE, try_position, part.radius, 1)
        first = first or position or try_position
        if position and on_land(surface, position) then return position end
    end
    return first
end

-- Returns the created start wrecks (containers are also debris targets).
function M.create(state)
    local surface = game.surfaces.nauvis
    if not surface then return {} end
    local scene = config.aai_crash
    -- the land check needs the tiles of the scene
    surface.request_to_generate_chunks({0, 0}, 3)
    surface.force_generate_chunk_requests()
    clear_trees(surface, scene.tree_clear_range)

    local wrecks = {}
    for _, part in ipairs(scene.parts) do
        local min_radius = part.min_radius or 0
        for _ = 1, part.count do
            local position = land_position(surface, part, min_radius)
            for _, name in ipairs(part.names) do
                if prototypes.entity[name] then
                    local entity = surface.create_entity({name = name, position = position, force = "player"})
                    if entity and config.wrecks[name] then
                        fill(state, entity)
                        wrecks[#wrecks + 1] = entity
                    end
                end
            end
        end
    end
    return wrecks
end

return M

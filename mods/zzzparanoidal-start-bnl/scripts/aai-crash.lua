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

-- Returns the created start wrecks (containers are also debris targets).
function M.create(state)
    local surface = game.surfaces.nauvis
    if not surface then return {} end
    local scene = config.aai_crash
    clear_trees(surface, scene.tree_clear_range)

    local wrecks = {}
    for _, part in ipairs(scene.parts) do
        local min_radius = part.min_radius or 0
        for _ = 1, part.count do
            local try_position = vector(math.random(), min_radius + (part.radius - min_radius) * math.random())
            local position = surface.find_non_colliding_position("aai-big-ship-wreck-1", try_position, part.radius, 1)
                or try_position
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

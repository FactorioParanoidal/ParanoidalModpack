local Adjacent = {}

-- Revalidate at each use: earlier callbacks may have changed a saved search result.
function Adjacent.factory_from_hull(entity)
    if entity and entity.valid then return storage.factories_by_entity[entity.unit_number] end
end

local abs = math.abs
local function same_position(a, b)
    return abs(a - b) < 0.000001
end

-- Outside port centres lie half a tile beyond their wall. Match the wall, not those centres:
-- two flush buildings have outside port centres one tile apart, inside the opposite building.
function Adjacent.matches(factory, cpos, other, opos)
    if factory == other or not (factory.built and other.built) or factory.inactive or other.inactive then return false end
    if factory.force ~= other.force or factory.outside_surface ~= other.outside_surface then return false end
    if cpos.indicator_dx ~= -opos.indicator_dx or cpos.indicator_dy ~= -opos.indicator_dy then return false end
    return same_position(factory.outside_x + cpos.outside_x - 0.5 * cpos.indicator_dx,
            other.outside_x + opos.outside_x - 0.5 * opos.indicator_dx)
        and same_position(factory.outside_y + cpos.outside_y - 0.5 * cpos.indicator_dy,
            other.outside_y + opos.outside_y - 0.5 * opos.indicator_dy)
end

-- Short-lived negative filter for a full recheck. Crowded searches fall back to exact point queries.
function Adjacent.neighbor_boxes(factory, bounds)
    local surface = factory.outside_surface
    if not (surface and surface.valid) then return end
    local x, y = factory.outside_x, factory.outside_y
    local limit, margin = 8, 1 / 256 -- Include edge points even on a single-line custom layout.
    local buildings = surface.find_entities_filtered {
        area = {{x + bounds.min_x - margin, y + bounds.min_y - margin},
            {x + bounds.max_x + margin, y + bounds.max_y + margin}},
        type = BUILDING_TYPE,
        force = factory.force,
        limit = limit
    }
    if #buildings >= limit then return end
    local boxes = {}
    for _, building in pairs(buildings) do
        local other = Adjacent.factory_from_hull(building)
        if other and other ~= factory then boxes[#boxes + 1] = building.bounding_box end
    end
    return boxes
end

function Adjacent.find(factory, cpos, boxes)
    local surface = factory.outside_surface
    if not (surface and surface.valid) then return end
    local x, y = factory.outside_x + cpos.outside_x, factory.outside_y + cpos.outside_y
    if boxes then
        local possible
        for _, box in ipairs(boxes) do
            if x >= box.left_top.x and x <= box.right_bottom.x and y >= box.left_top.y and y <= box.right_bottom.y then
                possible = true
                break
            end
        end
        -- A positive result still uses the old point search, including its ordering at a shared port.
        if not possible then return end
    end
    for _, building in pairs(surface.find_entities_filtered {
        position = {x, y},
        type = BUILDING_TYPE,
        force = factory.force
    }) do
        local other = Adjacent.factory_from_hull(building)
        if other and other ~= factory and other.layout then
            for cid, opos in pairs(other.layout.connections) do
                if Adjacent.matches(factory, cpos, other, opos) then
                    return {factory = other, cid = cid, cpos = opos}
                end
            end
        end
    end
end

function Adjacent.neighbor_buildings(factory)
    local surface = factory.outside_surface
    if not (surface and surface.valid) then return end
    local radius = factory.layout.outside_size / 2 + 0.3
    local hulls = {}
    for _, building in pairs(surface.find_entities_filtered {
        area = {{factory.outside_x - radius, factory.outside_y - radius},
            {factory.outside_x + radius, factory.outside_y + radius}},
        type = BUILDING_TYPE,
        force = factory.force
    }) do
        if Adjacent.factory_from_hull(building) then hulls[#hulls + 1] = building end
    end
    return hulls
end

function Adjacent.recheck_neighbors(factory, neighbors)
    for _, building in pairs(neighbors or Adjacent.neighbor_buildings(factory) or {}) do
        local other = Adjacent.factory_from_hull(building)
        if other and other ~= factory and other.built then
            factorissimo.recheck_factory_connections(other, nil, nil, true)
        end
    end
end

return Adjacent

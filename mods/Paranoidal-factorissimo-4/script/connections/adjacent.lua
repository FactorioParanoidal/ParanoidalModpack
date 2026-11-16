local Adjacent = {}

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

function Adjacent.find(factory, cpos)
    local surface = factory.outside_surface
    if not (surface and surface.valid) then return end
    local by_entity = storage.factories_by_entity
    for _, building in pairs(surface.find_entities_filtered {
        position = {factory.outside_x + cpos.outside_x, factory.outside_y + cpos.outside_y},
        type = BUILDING_TYPE,
        force = factory.force
    }) do
        local other = by_entity[building.unit_number]
        if other and other ~= factory and other.layout then
            for cid, opos in pairs(other.layout.connections) do
                if Adjacent.matches(factory, cpos, other, opos) then
                    return {factory = other, cid = cid, cpos = opos}
                end
            end
        end
    end
end

function Adjacent.recheck_neighbors(factory)
    local surface = factory.outside_surface
    if not (surface and surface.valid) then return end
    local radius = factory.layout.outside_size / 2 + 0.3
    for _, building in pairs(surface.find_entities_filtered {
        area = {{factory.outside_x - radius, factory.outside_y - radius},
            {factory.outside_x + radius, factory.outside_y + radius}},
        type = BUILDING_TYPE,
        force = factory.force
    }) do
        local other = storage.factories_by_entity[building.unit_number]
        if other and other ~= factory and other.built then
            factorissimo.recheck_factory_connections(other, nil, nil, true)
        end
    end
end

return Adjacent

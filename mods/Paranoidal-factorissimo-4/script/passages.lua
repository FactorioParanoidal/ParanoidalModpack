local Adjacent = require("script.connections.adjacent")
local Markers = require("script.passage-markers")
local Passages = {revision = 2, marker_revision = Markers.revision} -- Port-aligned walking cells.
local floor = math.floor
local d = defines.direction
local directions = {
    [d.north] = {0, -1}, [d.northeast] = {1, -1}, [d.east] = {1, 0}, [d.southeast] = {1, 1},
    [d.south] = {0, 1}, [d.southwest] = {-1, 1}, [d.west] = {-1, 0}, [d.northwest] = {-1, -1},
}

local function live(factory)
    local building = factory and factory.building
    if not (building and building.valid and factory.built and not factory.inactive
        and factory.layout and factory.inside_surface and factory.inside_surface.valid
        and building.force == factory.force and building.surface == factory.outside_surface) then return false end
    local pos = building.position
    return pos.x == factory.outside_x and pos.y == factory.outside_y
end

local function endpoint(factory, cpos, other, other_id)
    local dx, dy = cpos.indicator_dx, cpos.indicator_dy
    -- On the port axis, one tile in from it: the player need not step onto the logistics entity.
    local x = floor(factory.inside_x + cpos.inside_x - dx)
    local y = floor(factory.inside_y + cpos.inside_y - dy)
    return {x = x, y = y, dx = dx, dy = dy, other = other.id, other_port = other_id}
end

local function cell(index, x, y)
    local column = index and index.cells[x]
    return column and column[y]
end

local function set_cell(index, x, y, value)
    local column = index.cells[x]
    if value and not column then
        column = {}
        index.cells[x] = column
    end
    if column then
        column[y] = value
        if not value and not next(column) then index.cells[x] = nil end
    end
end

local function available(index, e)
    return not (cell(index, e.x, e.y) or cell(index, e.x + e.dx, e.y + e.dy))
end

local function add_end(state, factory, cid, e)
    local index = state[factory.id]
    if not index then
        index = {ports = {}, cells = {}}
        state[factory.id] = index
    end
    e.marker = Markers.draw_arrow(factory, e)
    index.ports[cid] = e
    set_cell(index, e.x, e.y, cid)
    -- Also catch a player who reached the wall between two door checks.
    set_cell(index, e.x + e.dx, e.y + e.dy, cid)
end

local function remove_end(state, id, cid)
    local index = state[id]
    local e = index and index.ports[cid]
    if not e then return end
    Markers.destroy(e.marker)
    set_cell(index, e.x, e.y, nil)
    set_cell(index, e.x + e.dx, e.y + e.dy, nil)
    index.ports[cid] = nil
    if not next(index.ports) then
        Markers.clear_labels(index)
        state[id] = nil
    end
end

local function update_changed_labels(state, changed)
    for id in pairs(changed) do
        local index = state[id]
        if index then Markers.update_labels(storage.factories[id], index) end
    end
end

function Passages.remove(factory)
    local state = storage.factory_passages
    local index = state and state[factory.id]
    if not index then return end
    local changed = {}
    for cid, e in pairs(index.ports) do
        remove_end(state, e.other, e.other_port)
        remove_end(state, factory.id, cid)
        changed[e.other] = true
    end
    update_changed_labels(state, changed)
end

local function add(factory, state, changed, neighbors)
    if not live(factory) then return end
    for _, building in pairs(neighbors or Adjacent.neighbor_buildings(factory) or {}) do
        local other = storage.factories_by_entity[building.unit_number]
        if other ~= factory and live(other) then
            -- Only ports on the opposing wall can match. Keep their original traversal order.
            local walls = {}
            for oid, opos in pairs(other.layout.connections) do
                local dx, dy = opos.indicator_dx, opos.indicator_dy
                local by_y = walls[dx]
                if not by_y then by_y = {}; walls[dx] = by_y end
                local wall = by_y[dy]
                if not wall then wall = {}; by_y[dy] = wall end
                wall[#wall + 1] = oid
            end
            for cid, cpos in pairs(factory.layout.connections) do
                local here = state[factory.id]
                local by_y = walls[-cpos.indicator_dx]
                local wall = by_y and by_y[-cpos.indicator_dy]
                if wall and not (here and here.ports[cid]) then
                    for _, oid in ipairs(wall) do
                        local opos = other.layout.connections[oid]
                        local there = state[other.id]
                        if not (there and there.ports[oid]) and Adjacent.matches(factory, cpos, other, opos) then
                            local e = endpoint(factory, cpos, other, oid)
                            local o = endpoint(other, opos, factory, cid)
                            -- Custom layouts may crowd two passages into one tile. Do not make a one-way pair.
                            if available(here, e) and available(there, o) then
                                add_end(state, factory, cid, e)
                                add_end(state, other, oid, o)
                                changed[factory.id], changed[other.id] = true, true
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

function Passages.add(factory, neighbors)
    local state = storage.factory_passages
    if not state then return end
    local changed = {}
    add(factory, state, changed, neighbors)
    update_changed_labels(state, changed)
end

function Passages.rename_destination(factory)
    local state = storage.factory_passages
    local index = state and state[factory.id]
    if not index then return end
    local changed = {}
    for _, e in pairs(index.ports) do changed[e.other] = true end
    update_changed_labels(state, changed)
end

-- Redraw saved overlays without rediscovering neighbors or changing walking cells.
function Passages.refresh_saved_markers()
    for id, index in pairs(storage.factory_passages) do
        local factory = storage.factories[id]
        local visible = live(factory)
        for _, e in pairs(index.ports) do
            Markers.destroy(e.marker)
            e.marker = visible and Markers.draw_arrow(factory, e) or nil
        end
        if visible then Markers.update_labels(factory, index) else Markers.clear_labels(index) end
    end
    storage.factory_passage_marker_revision = Markers.revision
end

function Passages.rebuild()
    for _, index in pairs(storage.factory_passages or {}) do
        for _, e in pairs(index.ports) do Markers.destroy(e.marker) end
        Markers.clear_labels(index)
    end
    local state, changed = {}, {}
    storage.factory_passages = state
    for _, factory in pairs(storage.factories) do add(factory, state, changed) end
    update_changed_labels(state, changed)
    storage.factory_passage_revision = Passages.revision
    storage.factory_passage_marker_revision = Markers.revision
end

function Passages.destination(factory, position, direction)
    local index = factory and storage.factory_passages[factory.id]
    if not index then return end
    local cid = cell(index, floor(position.x), floor(position.y))
    if not cid then return end
    local e, step = index.ports[cid], directions[direction]
    if not step or e.dx * step[1] + e.dy * step[2] <= 0 then return end

    local other = storage.factories[e.other]
    if not live(factory) or not live(other) then return end
    local opos = other.layout.connections[e.other_port]
    local cpos = factory.layout.connections[cid]
    if not cpos or not opos or not Adjacent.matches(factory, cpos, other, opos) then return end
    local target = storage.factory_passages[other.id]
    local o = target and target.ports[e.other_port]
    if not o or o.other ~= factory.id or o.other_port ~= cid then return end
    return other.inside_surface, {x = o.x + o.dx + 0.5, y = o.y + o.dy + 0.5}, o.dx, o.dy
end

return Passages

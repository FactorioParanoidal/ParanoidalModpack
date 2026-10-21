local const = require("scripts/constants")
local color = const.color
local width = const.width
local dash_length = const.dash_length
local gap_length = const.gap_length
local curved = const.curved
local arc_radius = const.arc_radius
local radius = const.radius
local draw = {}

-- Render objects are kept in an array so they can be destroyed from the end in O(1)
local function store(data, render)
    local n = (data.render_n or 0) + 1
    data.render[n] = render
    data.render_n = n
end

local function get_players(data)
    local players = data.players
    if not players then
        players = {data.index}
        data.players = players
    end
    return players
end

-- Returns true if the shape identified by key was already drawn on this entity
local function already_drawn(data, unit_number, key)
    local shapes = data.drawn_shapes
    if not shapes then
        shapes = {}
        data.drawn_shapes = shapes
    end
    local drawn = shapes[unit_number]
    if not drawn then
        drawn = {}
        shapes[unit_number] = drawn
    end
    if drawn[key] then return true end
    drawn[key] = true
    return false
end

-- All line endpoints of one entity lane are collinear, so a line whose both endpoints
-- are already drawn is covered by existing lines and can be skipped
function draw.line(data, entity, from_offset, to_offset)
    local unit_number = entity.unit_number
    local drawn_offsets = data.drawn_offsets
    if not drawn_offsets then
        drawn_offsets = {}
        data.drawn_offsets = drawn_offsets
    end
    local drawn = drawn_offsets[unit_number]
    if not drawn then
        drawn = {}
        drawn_offsets[unit_number] = drawn
    end
    if drawn[from_offset] and drawn[to_offset] then return end
    drawn[from_offset] = true
    drawn[to_offset] = true
    store(data, rendering.draw_line{
        color = color,
        width = width,
        from = {entity = entity, offset = from_offset},
        to = {entity = entity, offset = to_offset},
        surface = entity.surface_index,
        players = get_players(data),
    })
end

function draw.dash(data, entity, neighbour, from_offset, to_offset)
    if already_drawn(data, entity.unit_number, from_offset) then return end
    store(data, rendering.draw_line{
        color = color,
        width = width,
        from = {entity = entity, offset = from_offset},
        to = {entity = neighbour, offset = to_offset},
        dash_length = dash_length,
        gap_length = gap_length,
        surface = entity.surface_index,
        players = get_players(data),
    })
end

function draw.arc(data, entity, lane, clockwise)
    local unit_number = entity.unit_number
    local drawn_arcs = data.drawn_arcs
    if not drawn_arcs then
        drawn_arcs = {}
        data.drawn_arcs = drawn_arcs
    end
    local drawn = drawn_arcs[unit_number]
    if not drawn then
        drawn = {}
        drawn_arcs[unit_number] = drawn
    end
    if drawn[lane] then return end
    drawn[lane] = true
    local offset = ((clockwise and 4 or 0) + entity.direction) % 16
    lane = clockwise and lane % 2 + 1 or lane
    local radii = arc_radius[lane]
    store(data, rendering.draw_arc{
        color = color,
        min_radius = radii.min,
        max_radius = radii.max,
        start_angle = math.rad(offset * 45 / 2) --[[@as float]],
        angle = math.rad(90) --[[@as float]],
        target = {entity = entity, offset = curved[offset]},
        surface = entity.surface_index,
        players = get_players(data),
    })
end

function draw.circle(data, entity, offset)
    if already_drawn(data, entity.unit_number, offset) then return end
    store(data, rendering.draw_circle{
        color = color,
        radius = radius,
        filled = true,
        target = {entity = entity, offset = offset},
        surface = entity.surface_index,
        players = get_players(data),
    })
end

function draw.rectangle(data, entity, offsets)
    if already_drawn(data, entity.unit_number, offsets) then return end
    store(data, rendering.draw_rectangle{
        color = color,
        filled = true,
        left_top = {entity = entity, offset = offsets.left_top},
        right_bottom = {entity = entity, offset = offsets.right_bottom},
        surface = entity.surface_index,
        players = get_players(data),
    })
end

return draw

local const = require("scripts/constants")
local color = const.color
local width = const.width
local dash_length = const.dash_length
local gap_length = const.gap_length
local curved = const.curved
local arc_radius = const.arc_radius
local radius = const.radius
local draw = {}

function draw.line(data, entity, from_offset, to_offset)
    local drawn = data.drawn_offsets[entity.unit_number]
    if not drawn then
        drawn = {}
        data.drawn_offsets[entity.unit_number] = drawn
    end
    if drawn[from_offset] and drawn[to_offset] then return end
    drawn[from_offset] = true
    drawn[to_offset] = true
    data.ids[rendering.draw_line{
        color = color,
        width = width,
        from = entity,
        to = entity,
        from_offset = from_offset,
        to_offset = to_offset,
        surface = entity.surface,
        players = {data.index},
    }] = true
end

function draw.dash(data, entity, from_offset, to_offset)
    data.ids[rendering.draw_line{
        color = color,
        width = width,
        from = entity,
        to = entity.neighbours,
        from_offset = from_offset,
        to_offset = to_offset,
        dash_length = dash_length,
        gap_length = gap_length,
        surface = entity.surface,
        players = {data.index},
    }] = true
end

function draw.arc(data, entity, lane, clockwise)
    local drawn = data.drawn_arcs[entity.unit_number]
    if not drawn then
        drawn = {}
        data.drawn_arcs[entity.unit_number] = drawn
    end
    if drawn[lane] then return end
    drawn[lane] = true
    local offset = ((clockwise and 2 or 0) + entity.direction) % 8
    lane = clockwise and lane % 2 + 1 or lane
    local radii = arc_radius[lane]
    data.ids[rendering.draw_arc{
        color = color,
        min_radius = radii.min,
        max_radius = radii.max,
        start_angle = math.rad(offset * 45) --[[@as float]],
        angle = math.rad(90) --[[@as float]],
        target = entity,
        target_offset = curved[offset],
        surface = entity.surface,
        players = {data.index},
    }] = true
end

function draw.circle(data, entity, offset)
    data.ids[rendering.draw_circle{
        color = color,
        radius = radius,
        filled = true,
        target = entity,
        target_offset = offset,
        surface = entity.surface,
        players = {data.index},
    }] = true
end

function draw.rectangle(data, entity, offsets)
    data.ids[rendering.draw_rectangle{
        color = color,
        filled = true,
        left_top = entity,
        left_top_offset = offsets.left_top,
        right_bottom = entity,
        right_bottom_offset = offsets.right_bottom,
        surface = entity.surface,
        players = {data.index},
    }] = true
end

return draw
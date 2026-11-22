local Panels = require("script.specialization-indicators")
local Markers = {}
local min, max = math.min, math.max
local color = {r = 0.44, g = 0.95, b = 0.34}
local row_step = 1.4
local arrow_offset = 2.2 -- From the first walking cell: past the port and fully outside the wall.

-- One triangle strip per port. Repeated x coordinates join the two arrowheads to the narrow shaft.
local arrow = {{-0.48, 0}, {-0.22, -0.23}, {-0.22, 0.23}, {-0.22, -0.06}, {-0.22, 0.06},
    {0.22, -0.06}, {0.22, 0.06}, {0.22, -0.23}, {0.22, 0.23}, {0.48, 0}}

function Markers.draw_arrow(factory, endpoint)
    return rendering.draw_polygon {
        vertices = arrow,
        target = {x = endpoint.x + 0.5 + arrow_offset * endpoint.dx, y = endpoint.y + 0.5 + arrow_offset * endpoint.dy},
        orientation = endpoint.dy ~= 0 and 0.25 or 0,
        surface = factory.inside_surface,
        color = color,
        only_in_alt_mode = true,
    }
end

function Markers.destroy(object)
    if object and object.valid then object.destroy() end
end

function Markers.clear_labels(index)
    for _, label in pairs(index.labels or {}) do Markers.destroy(label) end
    index.labels = nil
end

local function wall_number(e)
    if e.dx ~= 0 then return e.dx > 0 and 2 or 4 end
    return e.dy < 0 and 1 or 3
end

local function text_and_width(other)
    if other.name then
        local _, length = other.name:gsub("[^\128-\191]", "")
        -- World-scaled 14px text; conservatively budget wide glyphs and padding, without a client font query.
        return other.name, length * 0.65 + 1.2
    end
    local id = tostring(other.id)
    return {"factorissimo-dispatch.number", id}, (10 + #id) * 0.65 + 1.2
end

local function overlaps(left, right, other_left, other_right)
    return left < other_right and other_left < right
end

local function draw_label(factory, group, wall, rows, reserve)
    local text, width = text_and_width(storage.factories[group.id])
    local x0, y0, edge = factory.inside_x, factory.inside_y, factory.layout.inside_size / 2 + 3
    local x, y, align = x0, y0, "center"
    if wall == 2 or wall == 4 then
        local east = wall == 2
        x, y, align = x0 + (east and edge or -edge), group.center, east and "left" or "right"
    else
        local south = wall == 3
        x = group.center
        local left, right = x - width / 2, x + width / 2
        local row = 1
        if south and (overlaps(left, right, reserve.left, reserve.right)
            or (group.first < factory.inside_door_x and group.last > factory.inside_door_x)) then
            -- Reserve the gate and both bonus panels even before the research makes them visible.
            row = max(1, 1 + math.ceil((reserve.bottom + 1 - (y0 + edge)) / row_step))
        end
        -- Groups are sorted left to right; only the previous right edge of each row matters.
        while rows[row] and left < rows[row] do row = row + 1 end
        rows[row] = right
        y = y0 + (south and 1 or -1) * (edge + (row - 1) * row_step)
    end
    return rendering.draw_text {
        text = text,
        surface = factory.inside_surface,
        target = {x = x, y = y},
        alignment = align,
        vertical_alignment = "middle",
        font = "default-bold",
        scale = 1.15,
        color = color,
        only_in_alt_mode = true,
    }
end

function Markers.update_labels(factory, index)
    Markers.clear_labels(index)
    if not (factory and factory.inside_surface and factory.inside_surface.valid) then return end

    local by_destination, walls = {}, {{}, {}, {}, {}}
    for _, endpoint in pairs(index.ports) do
        local id = endpoint.other
        local wall = wall_number(endpoint)
        local axis = (endpoint.dx == 0 and endpoint.x or endpoint.y) + 0.5
        local group = by_destination[id]
        if not group or wall < group.wall then
            by_destination[id] = {id = id, wall = wall, first = axis, last = axis}
        elseif wall == group.wall then
            group.first, group.last = min(group.first, axis), max(group.last, axis)
        end
    end
    for id, group in pairs(by_destination) do
        if storage.factories[id] then
            local wall = walls[group.wall]
            group.center = (group.first + group.last) / 2
            wall[#wall + 1] = group
        end
    end

    local reserve = Panels.label_reservation(factory)
    index.labels = {}
    for wall, groups in ipairs(walls) do
        table.sort(groups, function(a, b) return a.center < b.center or a.center == b.center and a.id < b.id end)
        local rows = {}
        for _, group in ipairs(groups) do
            index.labels[group.id] = draw_label(factory, group, wall, rows, reserve)
        end
    end
end

return Markers

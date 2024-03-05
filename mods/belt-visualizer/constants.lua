require("util")
local copy = table.deepcopy

local offset = 0.234375 -- 15/64
local width = 3
local color = {1, 1, 0}
-- color = {0.5, 0.5, 0, 0.5}
local radius = width * 1.25 / 32
local size = width * 1.125 / 32

local function empty_offsets(splitter)
    local t = splitter and {left = {}, right = {}} or {}
    return {
        {
            [0] = copy(t),
            [2] = copy(t),
            [4] = copy(t),
            [6] = copy(t),
        },
        {
            [0] = copy(t),
            [2] = copy(t),
            [4] = copy(t),
            [6] = copy(t),
        },
    }
end

local function offsets(data)
    local t = empty_offsets()
    for name, distance in pairs(data) do
        t[1][0][name] = {-offset, -distance}
        t[1][2][name] = {distance, -offset}
        t[1][4][name] = {offset, distance}
        t[1][6][name] = {-distance, offset}
        t[2][0][name] = {offset, -distance}
        t[2][2][name] = {distance, offset}
        t[2][4][name] = {-offset, distance}
        t[2][6][name] = {-distance, -offset}
    end
    return t
end

local function splitter_offsets(data)
    local t = empty_offsets(true)
    for name, v in pairs(data) do
        local distance = v[1]
        local offset_1 = v[2]
        local offset_2 = v[3]
        t[1][0].left[name] = {-offset_1, -distance}
        t[1][0].right[name] = {-offset_2, -distance}
        t[1][2].left[name] = {distance, -offset_1}
        t[1][2].right[name] = {distance, -offset_2}
        t[1][4].left[name] = {offset_1, distance}
        t[1][4].right[name] = {offset_2, distance}
        t[1][6].left[name] = {-distance, offset_1}
        t[1][6].right[name] = {-distance, offset_2}
        t[2][0].left[name] = {offset_2, -distance}
        t[2][0].right[name] = {offset_1, -distance}
        t[2][2].left[name] = {distance, offset_2}
        t[2][2].right[name] = {distance, offset_1}
        t[2][4].left[name] = {-offset_2, distance}
        t[2][4].right[name] = {-offset_1, distance}
        t[2][6].left[name] = {-distance, -offset_2}
        t[2][6].right[name] = {-distance, -offset_1}
    end
    return t
end

local function rectangle(offsets, data)
    local t = empty_offsets()
    for name, v in pairs(data) do
        local offset_name = v[1]
        local size = v[2]
        for lane, directions in pairs(offsets) do
            for direction, lane_offsets in pairs(directions) do
                local offset = lane_offsets[offset_name]
                t[lane][direction][name] = {
                    left_top = {offset[1] - size, offset[2] - size},
                    right_bottom = {offset[1] + size, offset[2] + size},
                }
            end
        end
    end
    return t
end

local sideload = 1 - offset

local straight = offsets{
    input = -0.5,
    output = 0.5,
    sideload = sideload,
}

local curved = {
    [0] = {-0.5, -0.5},
    [2] = {0.5, -0.5},
    [4] = {0.5, 0.5},
    [6] = {-0.5, 0.5},
}

local half_pixel_width = width / 64
local inner_min = 0.5 - offset - half_pixel_width
local inner_max = 0.5 - offset + half_pixel_width
local outer_min = 0.5 + offset - half_pixel_width
local outer_max = 0.5 + offset + half_pixel_width
local arc_radius = {
    {min = inner_min, max = inner_max},
    {min = outer_min, max = outer_max},
}

local dash_length = 3/16
local dash_offset = 0.5 - dash_length / 2
local gap_length = 0.5 - dash_length
local endpoint = 0.5 - (dash_length / 2 + gap_length)
local underground = offsets{
    input = endpoint,
    output = -endpoint,
}
local dash = offsets{
    input = dash_offset,
    output = -dash_offset,
}

local outer_offset = 0.5 + offset
local inner_offset = -0.5 + offset
local outer_line = outer_offset + width / 64
local inner_line = inner_offset - width / 64
local splitter = splitter_offsets{
    input = {-0.5, outer_offset, inner_offset},
    output = {0.5, outer_offset, inner_offset},
    middle = {0, outer_offset, inner_offset},
    sideload = {sideload, outer_offset, inner_offset},
    line = {0, outer_line, inner_line},
}

local loader = offsets{
    input = -1,
    output = 1,
    sideload = sideload + 0.5,
}
loader.rectangle = rectangle(loader, {
    input = {"output", size},
    output = {"input", size},
})

local loader_1x1 = offsets{
    input = -0.5,
    output = 0.5,
    sideload = sideload,
}
loader_1x1.rectangle = rectangle(loader_1x1, {
    input = {"output", size},
    output = {"input", size},
})

local linked_belt = offsets{
    input = -0.5,
    output = 0.5,
    middle = 0,
    sideload = sideload,
}

return {
    width = width,
    color = color,
    radius = radius,
    straight = straight,
    curved = curved,
    arc_radius = arc_radius,
    underground = underground,
    dash = dash,
    dash_length = dash_length,
    gap_length = gap_length,
    splitter = splitter,
    loader = loader,
    loader_1x1 = loader_1x1,
    linked_belt = linked_belt,
}
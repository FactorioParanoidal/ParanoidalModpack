require("util")
local copy = table.deepcopy

local offset = 0.234375 -- 15/64
local width = 3
local radius = width * 1.25 / 32
local color = {1, 1, 0}
-- color = {0.5, 0.5, 0, 0.5}

local connectables = {
    ["transport-belt"] = true,
    ["underground-belt"] = true,
    ["splitter"] = true,
    ["lane-splitter"] = true,
    ["loader"] = true,
    ["loader-1x1"] = true,
    ["linked-belt"] = true,
}

local lane_cycle = {
    {true, true},
    {[1] = true},
    {[2] = true},
}

local side_cycle = {
    both = {left = true, right = true},
    left = {left = true},
    right = {right = true},
}

local function empty_offsets(splitter)
    local t = splitter and {left = {}, right = {}} or {}
    return {{
        [defines.direction.north] = copy(t),
        [defines.direction.east ] = copy(t),
        [defines.direction.south] = copy(t),
        [defines.direction.west ] = copy(t),
    },{
        [defines.direction.north] = copy(t),
        [defines.direction.east ] = copy(t),
        [defines.direction.south] = copy(t),
        [defines.direction.west ] = copy(t),
    }}
end

local function offsets(data)
    local t = empty_offsets()
    for name, distance in pairs(data) do
        t[1][defines.direction.north][name] = {-offset, -distance}
        t[1][defines.direction.east ][name] = {distance, -offset}
        t[1][defines.direction.south][name] = {offset, distance}
        t[1][defines.direction.west ][name] = {-distance, offset}
        t[2][defines.direction.north][name] = {offset, -distance}
        t[2][defines.direction.east ][name] = {distance, offset}
        t[2][defines.direction.south][name] = {-offset, distance}
        t[2][defines.direction.west ][name] = {-distance, -offset}
    end
    return t
end

local function splitter_offsets(data)
    local t = empty_offsets(true)
    for name, v in pairs(data) do
        local distance = v[1]
        local offset_1 = v[2]
        local offset_2 = v[3]
        t[1][defines.direction.north].left [name] = {-offset_1, -distance}
        t[1][defines.direction.north].right[name] = {-offset_2, -distance}
        t[1][defines.direction.east ].left [name] = { distance, -offset_1}
        t[1][defines.direction.east ].right[name] = { distance, -offset_2}
        t[1][defines.direction.south].left [name] = { offset_1,  distance}
        t[1][defines.direction.south].right[name] = { offset_2,  distance}
        t[1][defines.direction.west ].left [name] = {-distance,  offset_1}
        t[1][defines.direction.west ].right[name] = {-distance,  offset_2}
        t[2][defines.direction.north].left [name] = { offset_2, -distance}
        t[2][defines.direction.north].right[name] = { offset_1, -distance}
        t[2][defines.direction.east ].left [name] = { distance,  offset_2}
        t[2][defines.direction.east ].right[name] = { distance,  offset_1}
        t[2][defines.direction.south].left [name] = {-offset_2,  distance}
        t[2][defines.direction.south].right[name] = {-offset_1,  distance}
        t[2][defines.direction.west ].left [name] = {-distance, -offset_2}
        t[2][defines.direction.west ].right[name] = {-distance, -offset_1}
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
    [defines.direction.north] = {-0.5, -0.5},
    [defines.direction.east ] = {0.5, -0.5},
    [defines.direction.south] = {0.5, 0.5},
    [defines.direction.west ] = {-0.5, 0.5},
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

local lane_splitter = offsets{
    input = -0.5,
    output = 0.5,
    sideload = sideload,
}

local size = width * 1.125 / 32
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

-- local speeds = {
--     default = {1, 1, 1},
--     [15/480] = {1, 1, 0},
--     [30/480] = {1, 0, 0},
--     [45/480] = {0, 0.75, 1},
-- }

-- local function generate_colors()
--     local colors = {}
--     local filters = {}
--     local i = 1
--     for ptype in pairs(connectables) do
--         filters[i] = ptype
--         i = i + 1
--     end
--     for name, prototype in pairs(game.get_filtered_entity_prototypes{{filter = "type", type = filters}}) do
--         colors[name] = speeds[prototype.belt_speed] or speeds.default
--     end
--     return colors
-- end

return {
    width = width,
    color = color,
    radius = radius,
    connectables = connectables,
    lane_cycle = lane_cycle,
    side_cycle = side_cycle,
    straight = straight,
    curved = curved,
    arc_radius = arc_radius,
    underground = underground,
    dash = dash,
    dash_length = dash_length,
    gap_length = gap_length,
    splitter = splitter,
    lane_splitter = lane_splitter,
    loader = loader,
    loader_1x1 = loader_1x1,
    linked_belt = linked_belt,
    -- generate_colors = generate_colors,
}
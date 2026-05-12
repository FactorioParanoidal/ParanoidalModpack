local north = defines.direction.north
local east = defines.direction.east
local south = defines.direction.south
local west = defines.direction.west

local opposite = {[north] = south, [east] = west, [south] = north, [west] = east}
local DX = {[north] = 0, [east] = 1, [south] = 0, [west] = -1}
local DY = {[north] = -1, [east] = 0, [south] = 1, [west] = 0}

local make_connection = function(id, outside_x, outside_y, inside_x, inside_y, direction_out)
    return {
        id = id,
        outside_x = outside_x,
        outside_y = outside_y,
        inside_x = inside_x,
        inside_y = inside_y,
        indicator_dx = DX[direction_out],
        indicator_dy = DY[direction_out],
        direction_in = opposite[direction_out],
        direction_out = direction_out,
    }
end

local make_quality_connection = function(id, outside_x, outside_y, inside_x, inside_y, direction_out, quality)
    local connection = make_connection(id, outside_x, outside_y, inside_x, inside_y, direction_out)
    connection.quality = quality
    return connection
end

local layout_generators = {
    ["factory-1"] = {
        name = "factory-1",
        tier = 1,
        inside_size = 30,
        outside_size = 8,
        inside_door_x = 0,
        inside_door_y = 16,
        outside_door_x = 0,
        outside_door_y = 4,
        outside_energy_receiver_type = "factory-power-input-8",
        outside_requester_chest = "factory-requester-chest-factory-1",
        outside_ejector_chest = "factory-eject-chest-factory-1",
        inside_energy_x = -4,
        inside_energy_y = 17,
        overlay_x = 0,
        overlay_y = 3,
        rectangles = {
            {
                x1 = -16, x2 = 16, y1 = -16, y2 = 16, tile = "factory-wall-1"
            },
            {
                x1 = -15, x2 = 15, y1 = -15, y2 = 15, tile = "factory-floor"
            },
            {
                x1 = -3, x2 = 3, y1 = 15, y2 = 18, tile = "factory-wall-1"
            },
            {
                x1 = -2, x2 = 2, y1 = 15, y2 = 18, tile = "factory-entrance"
            },
        },
        mosaics = {
            {
                x1 = -6,
                x2 = 6,
                y1 = -4,
                y2 = 4,
                tile = "factory-pattern-1",
                pattern = {
                    " ++++    ++ ",
                    "++  ++  +++ ",
                    "++  ++ + ++ ",
                    "++ +++   ++ ",
                    "+++ ++   ++ ",
                    "++  ++   ++ ",
                    "++  ++   ++ ",
                    " ++++  +++++",
                }
            },
        },
        connection_tile = "factory-floor",
        connections = {
            w1 = make_connection("w1", -4.5, -2.5, -15.5, -9.5, west),
            w2 = make_connection("w2", -4.5, -1.5, -15.5, -5.5, west),
            w3 = make_connection("w3", -4.5, 1.5, -15.5, 5.5, west),
            w4 = make_connection("w4", -4.5, 2.5, -15.5, 9.5, west),
            w5 = make_quality_connection("w5", -4.5, 0.5, -15.5, 2.5, west, 3),
            w6 = make_quality_connection("w6", -4.5, -0.5, -15.5, -2.5, west, 2),

            e1 = make_connection("e1", 4.5, -2.5, 15.5, -9.5, east),
            e2 = make_connection("e2", 4.5, -1.5, 15.5, -5.5, east),
            e3 = make_connection("e3", 4.5, 1.5, 15.5, 5.5, east),
            e4 = make_connection("e4", 4.5, 2.5, 15.5, 9.5, east),
            e5 = make_quality_connection("e5", 4.5, 0.5, 15.5, 2.5, east, 2),
            e6 = make_quality_connection("e6", 4.5, -0.5, 15.5, -2.5, east, 3),

            n1 = make_connection("n1", -2.5, -4.5, -9.5, -15.5, north),
            n2 = make_connection("n2", -1.5, -4.5, -5.5, -15.5, north),
            n3 = make_connection("n3", 1.5, -4.5, 5.5, -15.5, north),
            n4 = make_connection("n4", 2.5, -4.5, 9.5, -15.5, north),
            n5 = make_quality_connection("n5", -0.5, -4.5, -2.5, -15.5, north, 1),
            n6 = make_quality_connection("n6", 0.5, -4.5, 2.5, -15.5, north, 1),
            n7 = make_quality_connection("n7", -3.5, -4.5, -12.5, -15.5, north, 4),
            n8 = make_quality_connection("n8", 3.5, -4.5, 12.5, -15.5, north, 5),

            s1 = make_connection("s1", -2.5, 4.5, -9.5, 15.5, south),
            s2 = make_connection("s2", -1.5, 4.5, -5.5, 15.5, south),
            s3 = make_connection("s3", 1.5, 4.5, 5.5, 15.5, south),
            s4 = make_connection("s4", 2.5, 4.5, 9.5, 15.5, south),
            s7 = make_quality_connection("s7", -3.5, 4.5, -12.5, 15.5, south, 5),
            s8 = make_quality_connection("s8", 3.5, 4.5, 12.5, 15.5, south, 4),

        },
        overlays = {
            outside_x = 0,
            outside_y = -1,
            outside_w = 8,
            outside_h = 6,
            inside_x = -3.5,
            inside_y = 18.5,
        },
        cerys_radiative_towers = {
            {-10, 10},
            {10,  10},
            {10,  -10},
            {-10, -10},
        },
    },
    ["factory-2"] = {
        name = "factory-2",
        tier = 2,
        inside_size = 46,
        outside_size = 12,
        inside_door_x = 0,
        inside_door_y = 24,
        outside_door_x = 0,
        outside_door_y = 6,
        outside_energy_receiver_type = "factory-power-input-12",
        outside_requester_chest = "factory-requester-chest-factory-2",
        outside_ejector_chest = "factory-eject-chest-factory-2",
        inside_energy_x = -4,
        inside_energy_y = 25,
        overlay_x = 0,
        overlay_y = 5,
        rectangles = {
            {
                x1 = -24, x2 = 24, y1 = -24, y2 = 24, tile = "factory-wall-2"
            },
            {
                x1 = -23, x2 = 23, y1 = -23, y2 = 23, tile = "factory-floor"
            },
            {
                x1 = -3, x2 = 3, y1 = 23, y2 = 26, tile = "factory-wall-2"
            },
            {
                x1 = -2, x2 = 2, y1 = 23, y2 = 26, tile = "factory-entrance"
            },
        },
        mosaics = {
            {
                x1 = -6,
                x2 = 6,
                y1 = -4,
                y2 = 4,
                tile = "factory-pattern-2",
                pattern = {
                    " ++++   +++ ",
                    "++  ++ ++ ++",
                    "++  ++    ++",
                    "++ +++   ++ ",
                    "+++ ++  ++  ",
                    "++  ++ ++   ",
                    "++  ++ ++ ++",
                    " ++++  +++++",
                }
            },
        },
        connection_tile = "factory-floor",
        connections = {
            w1 = make_connection("w1", -6.5, -4.5, -23.5, -18.5, west),
            w2 = make_connection("w2", -6.5, -3.5, -23.5, -13.5, west),
            w3 = make_connection("w3", -6.5, -2.5, -23.5, -8.5, west),
            w4 = make_connection("w4", -6.5, 2.5, -23.5, 8.5, west),
            w5 = make_connection("w5", -6.5, 3.5, -23.5, 13.5, west),
            w6 = make_connection("w6", -6.5, 4.5, -23.5, 18.5, west),
            w7 = make_quality_connection("w7", -6.5, -1.5, -23.5, -4.5, west, 2),
            w8 = make_quality_connection("w8", -6.5, 1.5, -23.5, 4.5, west, 3),
            w9 = make_quality_connection("w9", -6.5, -0.5, -23.5, -1.5, west, 4),
            w10 = make_quality_connection("w10", -6.5, 0.5, -23.5, 1.5, west, 5),

            e1 = make_connection("e1", 6.5, -4.5, 23.5, -18.5, east),
            e2 = make_connection("e2", 6.5, -3.5, 23.5, -13.5, east),
            e3 = make_connection("e3", 6.5, -2.5, 23.5, -8.5, east),
            e4 = make_connection("e4", 6.5, 2.5, 23.5, 8.5, east),
            e5 = make_connection("e5", 6.5, 3.5, 23.5, 13.5, east),
            e6 = make_connection("e6", 6.5, 4.5, 23.5, 18.5, east),
            e7 = make_quality_connection("e7", 6.5, -1.5, 23.5, -4.5, east, 3),
            e8 = make_quality_connection("e8", 6.5, 1.5, 23.5, 4.5, east, 2),
            e9 = make_quality_connection("e9", 6.5, -0.5, 23.5, -1.5, east, 5),
            e10 = make_quality_connection("e10", 6.5, 0.5, 23.5, 1.5, east, 4),

            n1 = make_connection("n1", -4.5, -6.5, -18.5, -23.5, north),
            n2 = make_connection("n2", -3.5, -6.5, -13.5, -23.5, north),
            n3 = make_connection("n3", -2.5, -6.5, -8.5, -23.5, north),
            n4 = make_connection("n4", 2.5, -6.5, 8.5, -23.5, north),
            n5 = make_connection("n5", 3.5, -6.5, 13.5, -23.5, north),
            n6 = make_connection("n6", 4.5, -6.5, 18.5, -23.5, north),
            n7 = make_quality_connection("n7", -1.5, -6.5, -3.5, -23.5, north, 1),
            n8 = make_quality_connection("n8", 1.5, -6.5, 3.5, -23.5, north, 1),

            s1 = make_connection("s1", -4.5, 6.5, -18.5, 23.5, south),
            s2 = make_connection("s2", -3.5, 6.5, -13.5, 23.5, south),
            s3 = make_connection("s3", -2.5, 6.5, -8.5, 23.5, south),
            s4 = make_connection("s4", 2.5, 6.5, 8.5, 23.5, south),
            s5 = make_connection("s5", 3.5, 6.5, 13.5, 23.5, south),
            s6 = make_connection("s6", 4.5, 6.5, 18.5, 23.5, south),
        },
        overlays = {
            outside_x = 0,
            outside_y = -1,
            outside_w = 12,
            outside_h = 10,
            inside_x = -3.5,
            inside_y = 26.5,
        },
        cerys_radiative_towers = {
            {-13, 13},
            {13,  13},
            {13,  -13},
            {-13, -13},
        },
    },
    ["factory-3"] = {
        name = "factory-3",
        tier = 3,
        inside_size = 60,
        outside_size = 16,
        inside_door_x = 0,
        inside_door_y = 31,
        outside_door_x = 0,
        outside_door_y = 8,
        outside_energy_receiver_type = "factory-power-input-16",
        outside_requester_chest = "factory-requester-chest-factory-3",
        outside_ejector_chest = "factory-eject-chest-factory-3",
        inside_energy_x = -4,
        inside_energy_y = 32,
        overlay_x = 0,
        overlay_y = 7,
        rectangles = {
            {
                x1 = -31, x2 = 31, y1 = -31, y2 = 31, tile = "factory-wall-3"
            },
            {
                x1 = -30, x2 = 30, y1 = -30, y2 = 30, tile = "factory-floor"
            },
            {
                x1 = -3, x2 = 3, y1 = 30, y2 = 33, tile = "factory-wall-3"
            },
            {
                x1 = -2, x2 = 2, y1 = 30, y2 = 33, tile = "factory-entrance"
            },
        },
        mosaics = {
            {
                x1 = -6,
                x2 = 6,
                y1 = -4,
                y2 = 4,
                tile = "factory-pattern-3",
                pattern = {
                    " ++++   +++ ",
                    "++  ++ ++ ++",
                    "++  ++    ++",
                    "++ +++   ++ ",
                    "+++ ++    ++",
                    "++  ++    ++",
                    "++  ++ ++ ++",
                    " ++++   +++ ",
                }
            },
        },
        connection_tile = "factory-floor",
        connections = {
            w1 = make_connection("w1", -8.5, -5.5, -30.5, -24.5, west),
            w2 = make_connection("w2", -8.5, -4.5, -30.5, -20.5, west),
            w3 = make_connection("w3", -8.5, -3.5, -30.5, -9.5, west),
            w4 = make_connection("w4", -8.5, -2.5, -30.5, -5.5, west),
            w5 = make_connection("w5", -8.5, 2.5, -30.5, 5.5, west),
            w6 = make_connection("w6", -8.5, 3.5, -30.5, 9.5, west),
            w7 = make_connection("w7", -8.5, 4.5, -30.5, 20.5, west),
            w8 = make_connection("w8", -8.5, 5.5, -30.5, 24.5, west),
            w9 = make_quality_connection("w9", -8.5, -1.5, -30.5, -1.5, west, 2),
            w10 = make_quality_connection("w10", -8.5, 1.5, -30.5, 1.5, west, 2),
            w11 = make_quality_connection("w11", -8.5, -6.5, -30.5, -28.5, west, 3),
            w12 = make_quality_connection("w12", -8.5, 6.5, -30.5, 28.5, west, 3),

            e1 = make_connection("e1", 8.5, -5.5, 30.5, -24.5, east),
            e2 = make_connection("e2", 8.5, -4.5, 30.5, -20.5, east),
            e3 = make_connection("e3", 8.5, -3.5, 30.5, -9.5, east),
            e4 = make_connection("e4", 8.5, -2.5, 30.5, -5.5, east),
            e5 = make_connection("e5", 8.5, 2.5, 30.5, 5.5, east),
            e6 = make_connection("e6", 8.5, 3.5, 30.5, 9.5, east),
            e7 = make_connection("e7", 8.5, 4.5, 30.5, 20.5, east),
            e8 = make_connection("e8", 8.5, 5.5, 30.5, 24.5, east),
            e9 = make_quality_connection("e9", 8.5, -1.5, 30.5, -1.5, east, 2),
            e10 = make_quality_connection("e10", 8.5, 1.5, 30.5, 1.5, east, 2),
            e11 = make_quality_connection("e11", 8.5, -6.5, 30.5, -28.5, east, 3),
            e12 = make_quality_connection("e12", 8.5, 6.5, 30.5, 28.5, east, 3),

            n1 = make_connection("n1", -5.5, -8.5, -24.5, -30.5, north),
            n2 = make_connection("n2", -4.5, -8.5, -20.5, -30.5, north),
            n3 = make_connection("n3", -3.5, -8.5, -9.5, -30.5, north),
            n4 = make_connection("n4", -2.5, -8.5, -5.5, -30.5, north),
            n5 = make_connection("n5", 2.5, -8.5, 5.5, -30.5, north),
            n6 = make_connection("n6", 3.5, -8.5, 9.5, -30.5, north),
            n7 = make_connection("n7", 4.5, -8.5, 20.5, -30.5, north),
            n8 = make_connection("n8", 5.5, -8.5, 24.5, -30.5, north),
            n9 = make_quality_connection("n9", -1.5, -8.5, -1.5, -30.5, north, 1),
            n10 = make_quality_connection("n10", 1.5, -8.5, 1.5, -30.5, north, 1),
            n11 = make_quality_connection("n11", -6.5, -8.5, -28.5, -30.5, north, 4),
            n12 = make_quality_connection("n12", 6.5, -8.5, 28.5, -30.5, north, 4),

            s1 = make_connection("s1", -5.5, 8.5, -24.5, 30.5, south),
            s2 = make_connection("s2", -4.5, 8.5, -20.5, 30.5, south),
            s3 = make_connection("s3", -3.5, 8.5, -9.5, 30.5, south),
            s4 = make_connection("s4", -2.5, 8.5, -5.5, 30.5, south),
            s5 = make_connection("s5", 2.5, 8.5, 5.5, 30.5, south),
            s6 = make_connection("s6", 3.5, 8.5, 9.5, 30.5, south),
            s7 = make_connection("s7", 4.5, 8.5, 20.5, 30.5, south),
            s8 = make_connection("s8", 5.5, 8.5, 24.5, 30.5, south),
            s9 = make_quality_connection("s9", -6.5, 8.5, -28.5, 30.5, south, 5),
            s10 = make_quality_connection("s10", 6.5, 8.5, 28.5, 30.5, south, 5),
        },
        overlays = {
            outside_x = 0,
            outside_y = -1,
            outside_w = 16,
            outside_h = 14,
            inside_x = -3.5,
            inside_y = 33.5,
        },
        cerys_radiative_towers = {
            {-15, 15},
            {15,  15},
            {15,  -15},
            {-15, -15},
        },
    }
}

local function add_space_factories()
    if not settings.startup["Factorissimo2-space-architecture"].value then return end

    local tile_name_mapping = {
        ["factory-wall-1"] = "space-factory-wall-1",
        ["factory-wall-2"] = "space-factory-wall-2",
        ["factory-wall-3"] = "space-factory-wall-3",
        ["factory-pattern-1"] = "space-factory-pattern-1",
        ["factory-pattern-2"] = "space-factory-pattern-2",
        ["factory-pattern-3"] = "space-factory-pattern-3",
        ["factory-floor"] = "space-factory-floor",
        ["factory-entrance"] = "space-factory-entrance",
    }

    local function make_space_layout(original_layout_name)
        local layout = table.deepcopy(layout_generators[original_layout_name])
        layout.name = "space-" .. original_layout_name
        for _, mosaic in pairs(layout.mosaics) do
            mosaic.tile = tile_name_mapping[mosaic.tile] or mosaic.tile
        end
        for _, rect in pairs(layout.rectangles) do
            rect.tile = tile_name_mapping[rect.tile] or rect.tile
        end
        layout.connection_tile = tile_name_mapping[layout.connection_tile] or layout.connection_tile
        layout.surface_override = "space-factory-floor"
        storage.layout_generators[layout.name] = layout
    end
    make_space_layout("factory-1")
    make_space_layout("factory-2")
    make_space_layout("factory-3")
end

--[[
/c __factorissimo-2-notnotmelon__ reload_layouts()
--]]

_G.reload_layouts = function()
    storage.layout_generators = storage.layout_generators or {}
    for name, layout in pairs(layout_generators) do
        storage.layout_generators[name] = layout
    end
    add_space_factories()
end

factorissimo.on_event(factorissimo.events.on_init(), reload_layouts)

local TRENCH_ENTRANCE_ELEVATION = maraxsis_constants.TRENCH_ENTRANCE_ELEVATION

data:extend {{
    type = "noise-expression",
    name = "maraxsis_starting_area",
    expression = "1000"
}}

data:extend {{
    type = "noise-function",
    name = "distance_from_0_0",
    expression = "sqrt(xx * xx + yy * yy)",
    parameters = {"xx", "yy"}
}}

data:extend {{
    type = "noise-function",
    name = "maraxsis_elevation_bonus",
    expression = [[
        (1 - distance_from_0_0(xx, yy) / maraxsis_starting_area)
    ]],
    parameters = {"xx", "yy"}
}}

data:extend {{
    type = "noise-function",
    name = "maraxsis_moisture",
    expression = [[
        abs(multioctave_noise{
            x = maraxsis_wx(xx, yy),
            y = maraxsis_wy(xx, yy),
            persistence = 0.25,
            seed0 = map_seed,
            seed1 = 1,
            octaves = 2,
            input_scale = 1/1300,
            output_scale = 1
        })
    ]],
    parameters = {"xx", "yy"}
}}

data:extend {{
    type = "noise-expression",
    name = "maraxsis_surface_moisture",
    expression = "maraxsis_moisture(x, y)"
}}

data:extend {{ -- distorted x. Also offset grid so that the starting area is in the middle of a cell
    type = "noise-function",
    name = "maraxsis_wx",
    expression = [[
        xx + multioctave_noise{
            x = xx,
            y = yy,
            persistence = 0.7,
            seed0 = map_seed,
            seed1 = 'maraxsis_wobble_x',
            octaves = 4,
            input_scale = 5 / fulgora_grid,
            output_scale = fulgora_grid * 0.07
        } * maraxsis_wobble_mask(xx, yy) + fulgora_grid / 2
    ]],
    parameters = {"xx", "yy"}
}}
data:extend {{ -- distorted y. Also offset grid so that the starting area is in the middle of a cell
    type = "noise-function",
    name = "maraxsis_wy",
    expression = [[
        yy + multioctave_noise{
            x = xx,
            y = yy,
            persistence = 0.7,
            seed0 = map_seed,
            seed1 = 'maraxsis_wobble_y',
            octaves = 4,
            input_scale = 5 / fulgora_grid,
            output_scale = fulgora_grid * 0.07
        } * maraxsis_wobble_mask(xx, yy) + fulgora_grid / 2
    ]],
    parameters = {"xx", "yy"}
}}

data:extend {{ -- We usually want a lot of wobble or none at all, so wobble_influence has a high output scale and then we clamp it.
    type = "noise-function",
    name = "maraxsis_wobble_mask",
    expression = "clamp(wobble_influence + 0.6, 0, 1)",
    parameters = {"xx", "yy"},
    local_expressions = {
        wobble_influence = [[
            multioctave_noise{
                x = xx,
                y = yy,
                persistence = 0.5,
                seed0 = map_seed,
                seed1 = 1,
                octaves = 3,
                input_scale = 128 / fulgora_grid / 20 ,
                output_scale = 3
            }
        ]]
    },
    parameters = {"xx", "yy"}
}}

data:extend {{
    type = "noise-function",
    name = "maraxsis_elevation",
    expression = [[
        1 - (1 - min(1, elevation) + ]] .. TRENCH_ENTRANCE_ELEVATION .. [[) ^ 3 + elevation/3
    ]],
    local_expressions = {
        xx = "xxx - 38",
        yy = "yyy + 14",
        elevation = [[
            if(
                distance_from_0_0(xx, yy) < maraxsis_starting_area,
                maraxsis_moisture(xx, yy) + maraxsis_elevation_bonus(xx, yy),
                maraxsis_moisture(xx, yy)
            )
        ]]
    },
    parameters = {"xxx", "yyy"}
}}

data:extend {{
    type = "noise-expression",
    name = "maraxsis_surface_elevation",
    expression = "maraxsis_elevation(x, y)"
}}

data:extend {{
    type = "noise-expression",
    name = "maraxsis_trench_entrance",
    expression = "maraxsis_surface_elevation < " .. TRENCH_ENTRANCE_ELEVATION
}}

data:extend {{
    type = "noise-function",
    name = "maraxsis_coral_reef",
    expression = "(maraxsis_elevation(xx, yy) > 0.8) * (maraxsis_elevation(xx, yy) < 1.1) * (coral_zones > 0.5) * coral_beds",
    local_expressions = {
        coral_beds = [[
            multioctave_noise{
                x = xx,
                y = yy,
                persistence = 0.5,
                seed0 = map_seed,
                seed1 = 1542,
                octaves = 2,
                input_scale = 0.03,
                output_scale = max(0.65, var("control:maraxsis-coral:size"))
            }
        ]],
        coral_zones = [[
            multioctave_noise{
                x = xx,
                y = yy,
                persistence = 0.5,
                seed0 = map_seed,
                seed1 = 15442,
                octaves = 2,
                input_scale = 0.01,
                output_scale = 1
            } + final_frequency
        ]],
        frequency = [[
            var("control:maraxsis-coral:frequency")
        ]],
        final_frequency = [[
            if (
                frequency > 1,
                (frequency - 1) / 5,
                (frequency - 1) / 2
            )
        ]],
    },
    parameters = {"xx", "yy"}
}}

data:extend {{
    type = "noise-expression",
    name = "maraxsis_coral_ore",
    expression = "((maraxsis_coral_reef(x, y) > 0.65) * coral_spots) > 0.8",
    local_expressions = {
        coral_spots = [[
            multioctave_noise{
                x = x,
                y = y,
                persistence = 0.5,
                seed0 = map_seed,
                seed1 = 154,
                octaves = 6,
                input_scale = 128 / 20,
                output_scale = 3
            }
        ]]
    }
}}

local SPECIES = table_size(maraxsis_constants.TROPICAL_FISH_NAMES)
--- Chance per tile of a fish spawning in coral.
local FISH_IN_CORAL = 0.003 / SPECIES
--- Chance per tile of a fish spawning anywhere else. 2000x smaller than
--- FISH_IN_CORAL so it's way more rare but not unheard of to see a random fish
--- out on the sea bed.
local FISH_IN_OPEN_WATER = 0.0000015 / SPECIES

for i = 1, SPECIES do
    data:extend {{
        type = "noise-expression",
        name = "maraxsis_tropical_fish_" .. i,
        expression = "rand > 1 - (" .. FISH_IN_CORAL .. " * in_coral + " .. FISH_IN_OPEN_WATER .. " * (1 - in_coral))",
        local_expressions = {
            wx = "maraxsis_wx(x, y) + " .. i * 97,
            wy = "maraxsis_wy(x, y) + " .. i * 61,
            seed = "map_seed + " .. i * 100,
            rand = "1 - random_penalty{x = wx, y = wy, seed = seed, source = 1, amplitude = 1}",
            in_coral = "maraxsis_coral_reef(x, y) > 0.45",
        }
    }}
end

data.raw.tile["lowland-cream-red-underwater"].autoplace = {
    probability_expression = [[
        maraxsis_coral_reef(x, y) >= 0.65
    ]],
    order = "a[coral]-a[maraxsis]"
}

data.raw.tile["lowland-red-vein-2-underwater"].autoplace = {
    probability_expression = [[
        maraxsis_coral_reef(x, y) >= 0.45
    ]],
    order = "a[coral]-b[maraxsis]"
}

data.raw.tile["sand-3-underwater"].autoplace = {
    probability_expression = [[
        maraxsis_surface_elevation > (0.9 + ]] .. TRENCH_ENTRANCE_ELEVATION .. [[)
    ]],
    order = "b[sand]-a[maraxsis]"
}

data.raw.tile["sand-2-underwater"].autoplace = {
    probability_expression = [[
        maraxsis_surface_elevation > (0.7 + ]] .. TRENCH_ENTRANCE_ELEVATION .. [[)
    ]],
    order = "b[sand]-b[maraxsis]"
}

data.raw.tile["sand-1-underwater"].autoplace = {
    probability_expression = [[
        maraxsis_surface_elevation > (0.3 + ]] .. TRENCH_ENTRANCE_ELEVATION .. [[)
    ]],
    order = "b[sand]-c[maraxsis]"
}

data.raw.tile["dirt-5-underwater"].autoplace = {
    probability_expression = [[
        1
    ]],
    order = "b[sand]-d[maraxsis]"
}

data.raw["simple-entity"]["big-sand-rock-underwater"].autoplace = {
    probability_expression = [[
        noise * (random_penalty{x = x, y = y, seed = map_seed, source = 1, amplitude = 1} > 0.7)
    ]],
    local_expressions = {
        noise = [[
            multioctave_noise {
                x = x,
                y = y,
                persistence = 0.15,
                seed0 = map_seed,
                seed1 = 239354,
                octaves = 2,
                input_scale = 1 / 40,
                output_scale = 1
            } > 0.9
        ]]
    },
    order = "c[rocks]-a[big-sand-rock-underwater]"
}

data.raw["simple-entity"]["big-sand-rock-underwater"].minable.results = {
    {type = "item", name = maraxsis_constants.SAND_ITEM_NAME, amount_min = 11, amount_max = 15},
    {type = "item", name = "stone",         amount_min = 11, amount_max = 15}
}

data.raw["simple-entity"]["maraxsis-mollusk-husk"].autoplace = {
    probability_expression = [[
        (maraxsis_elevation(x, y) > 1.1) * master_noise * noise * (random_penalty{x = x, y = y, seed = map_seed, source = 1, amplitude = 1} > 0.9)
    ]],
    local_expressions = {
        noise = [[
            multioctave_noise {
                x = x,
                y = y,
                persistence = 0.15,
                seed0 = map_seed,
                seed1 = 31359,
                octaves = 2,
                input_scale = 1 / 20,
                output_scale = 1
            } > 0.95
        ]],
        -- force these to spawn in the starting area as they are used in a trigger technology
        master_noise = [[
            (multioctave_noise {
                x = x,
                y = y,
                persistence = 0.5,
                seed0 = map_seed,
                seed1 = 31359,
                octaves = 4,
                input_scale = 1 / 100,
                output_scale = 1
            } > 0.2) + (distance_from_0_0(x, y) < 30)
        ]],
    },
    order = "c[rocks]-b[mollusk-husk]"
}

data.raw.tree["maraxsis-polylplast"].autoplace = {
    probability_expression = [[
        (maraxsis_coral_reef(x, y) * random_1) + random_2
    ]],
    local_expressions = {
        random_1 = "random_penalty{x = x, y = y, seed = map_seed, source = 1, amplitude = 1} > 0.96",
        random_2 = "random_penalty{x = x, y = y, seed = map_seed, source = 1, amplitude = 1} > 0.9996",
    }
}

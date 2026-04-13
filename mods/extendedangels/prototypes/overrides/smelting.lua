---@param direction "north" | "east" | "south" | "west"
---@param variant "capped" | "connected"
---@param is_flipped boolean?
---@return data.Animation
local function get_pipe_picture(direction, variant, is_flipped)
    local flipped = is_flipped == true and "-flipped" or ""

    ---@type data.Animation
    local animation = {
        layers = {
        util.sprite_load(
            "__angelssmeltinggraphics__/graphics/entity/induction-furnace/induction-furnace-pipe-"
            .. variant
            .. "-"
            .. direction
            .. flipped,
            {
            priority = "high",
            scale = 0.5,
            }
        ),
        util.sprite_load(
            "__angelssmeltinggraphics__/graphics/entity/induction-furnace/induction-furnace-pipe-"
            .. variant
            .. "-"
            .. direction
            .. "-shadow"
            .. flipped,
            {
            priority = "high",
            draw_as_shadow = true,
            scale = 0.5,
            }
        ),
        },
    }

    return animation
end

local function get_secondary_pipe_pictures(is_flipped)
    return {
        always_draw = true,
        north_animation = {
            layers = {
                get_pipe_picture("north", "connected"),
                get_pipe_picture("west", "capped"),
            },
        },
        east_animation = {
            layers = {
                get_pipe_picture("north", "capped"),
                get_pipe_picture("west", "connected"),
            },
        },
        south_animation = {
            layers = {
                get_pipe_picture("north", "connected"),
                get_pipe_picture("west", "capped"),
            },
        },
        west_animation = {
            layers = {
                get_pipe_picture("north", "capped"),
                get_pipe_picture("west", "connected"),
            },
        },
        secondary_draw_order = -1,
    }

end

local function get_primary_pipe_pictures()
    return {
        always_draw = true,
        north_animation = {
            layers = {
                get_pipe_picture("east", "capped"),
                get_pipe_picture("south", "connected"),
                angelsmods.functions.get_vertical_pipe_shadow({ 2, -2 }),
            },
        },
        east_animation = {
            layers = {
                get_pipe_picture("east", "connected"),
                get_pipe_picture("south", "capped"),
                angelsmods.functions.get_horizontal_pipe_shadow({ -2, -2 }),
            },
        },
        south_animation = {
            layers = {
                get_pipe_picture("east", "capped"),
                get_pipe_picture("south", "connected"),
                angelsmods.functions.get_vertical_pipe_shadow({ 2, -2 }),
            },
        },
        west_animation = {
            layers = {
                get_pipe_picture("east", "connected"),
                get_pipe_picture("south", "capped"),
                angelsmods.functions.get_horizontal_pipe_shadow({ -2, -2 }),
            },
        },
    }
end

local function get_secondary_pipe_pictures_flipped()
    local flipped = true
    return {
        always_draw = true,
        north_animation = {
            layers = {
                get_pipe_picture("north", "connected", flipped),
                get_pipe_picture("east", "capped", flipped),
            },
        },
        east_animation = {
            layers = {
                get_pipe_picture("north", "capped", flipped),
                get_pipe_picture("east", "connected", flipped),
            },
        },
        south_animation = {
            layers = {
                get_pipe_picture("north", "connected", flipped),
                get_pipe_picture("east", "capped", flipped),
            },
        },
        west_animation = {
            layers = {
                get_pipe_picture("north", "capped", flipped),
                get_pipe_picture("east", "connected", flipped),
            },
        },
        secondary_draw_order = -1,
    }
end

local function get_primary_pipe_pictures_flipped()
    local flipped = true
    return {
        always_draw = true,
        north_animation = {
            layers = {
                get_pipe_picture("south", "connected", flipped),
                get_pipe_picture("west", "capped", flipped),
            },
        },
        east_animation = {
            layers = {
                get_pipe_picture("south", "capped", flipped),
                get_pipe_picture("west", "connected", flipped),
                angelsmods.functions.get_horizontal_pipe_shadow({ -2, 2 }),
            },
        },
        south_animation = {
            layers = {
                get_pipe_picture("south", "connected", flipped),
                get_pipe_picture("west", "capped", flipped),
            },
        },
        west_animation = {
            layers = {
                get_pipe_picture("south", "capped", flipped),
                get_pipe_picture("west", "connected", flipped),
                angelsmods.functions.get_horizontal_pipe_shadow({ -2, 2 }),
            },
        },
    }
end

local furnace_names = {
    ["angels-induction-furnace"] = false,
    ["angels-induction-furnace-2"] = false,
    ["angels-induction-furnace-3"] = false,
    ["angels-induction-furnace-4"] = true,
}
for name, insert_fluid_box in pairs(furnace_names) do
    if not insert_fluid_box then goto continue end

    local entity = data.raw["assembling-machine"][name]
    if not entity then goto continue end

    -- Add input fluid_box to Induction Furnace
    table.insert(entity.fluid_boxes, {
        production_type = "input",
        pipe_covers = pipecoverspictures(),
        volume = 1000,
        pipe_connections = {
            { flow_direction = "input", position = { -2, 2 }, direction = defines.direction.south }
        },
    })

    -- Update working visualisation pipes. Assume working_visualisation and all layers are present.
    -- Need to update the first two elements.
    entity.graphics_set.working_visualisations[1] = get_secondary_pipe_pictures()
    entity.graphics_set.working_visualisations[2] = get_primary_pipe_pictures()
    entity.graphics_set_flipped.working_visualisations[1] = get_secondary_pipe_pictures_flipped()
    entity.graphics_set_flipped.working_visualisations[2] = get_primary_pipe_pictures_flipped()

    ::continue::
end
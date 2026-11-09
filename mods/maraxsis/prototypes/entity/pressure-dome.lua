local table = require("lib.table")

maraxsis_constants.PRESSURE_DOMES["maraxsis-pressure-dome"] = {
        octagon_size = 16.5,
        corner_size = 7,
        diagonal_offset = 4.75,
        PRESSURE_DOME_TILE = "maraxsis-pressure-dome-tile",
        regulator = "maraxsis-regulator",
        pressure_dome = "maraxsis-pressure-dome",
        dome_collider = "maraxsis-pressure-dome-collision",
        regulator_fluidbox_prefix = "maraxsis-regulator-fluidbox-",
        sprite = "maraxsis-pressure-dome-sprite",
        base_sprite = "maraxsis-pressure-dome-base-sprite",
        lamp = "maraxsis-pressure-dome-lamp",
        combinator = "maraxsis-pressure-dome-combinator",
        recipe = "maraxsis-pressure-dome",
    }
local base_dome_params = maraxsis_constants.PRESSURE_DOMES["maraxsis-pressure-dome"]

local dome = {
    filename = "__maraxsis__/graphics/entity/pressure-dome/pressure-dome-cage.png",
    width = 1344,
    height = 1344,
    scale = 0.935,
    shift = {0, -1.25-8/32},
    flags = {"no-scale"},
}

local dome_base = {
    filename = "__maraxsis__/graphics/entity/pressure-dome/pressure-dome-base.png",
    width = 1344,
    height = 1344,
    scale = 0.935,
    shift = {0, -1.25},
    flags = {"no-scale"},
}

local light_2 = {
    filename = "__core__/graphics/light-medium.png",
    width = 300,
    height = 300,
    scale = base_dome_params.corner_size,
    shift = {0, 0.3},
    draw_as_light = true,
}

local base_shadow = {
    filename = "__maraxsis__/graphics/entity/pressure-dome/base-shadow.png",
    width = 1344,
    height = 1344,
    scale = 0.935,
    shift = {0, -1.25-8/32},
    flags = {"no-scale"},
    draw_as_shadow = true,
}

local cage_shadow = {
    filename = "__maraxsis__/graphics/entity/pressure-dome/pressure-dome-shadow.png",
    width = 1344,
    height = 1344,
    scale = 0.935,
    shift = {0, -1.25-8/32},
    flags = {"no-scale"},
    draw_as_shadow = true,
}

data:extend {{
    type = "item",
    name = "maraxsis-pressure-dome",
    icon = "__maraxsis__/graphics/icons/pressure-dome.png",
    icon_size = 64,
    place_result = "maraxsis-pressure-dome",
    stack_size = 10,
}}

data:extend {{
    type = "recipe",
    name = "maraxsis-pressure-dome",
    enabled = false,
    ingredients = {
        {type = "item", name = "pipe",                 amount = 30},
        {type = "item", name = "maraxsis-glass-panes", amount = 1000},
        {type = "item", name = "tungsten-plate",       amount = 100},
    },
    results = {
        {type = "item", name = "maraxsis-pressure-dome", amount = 1},
    },
    energy_required = 10,
    auto_recycle = true,
    categories = {"maraxsis-hydro-plant" },
}}

local function collision_box() return {{-16, -16}, {16, 16}} end

data:extend {{
    type = "roboport",
    logistics_connection_distance = data.raw.roboport["maraxsis-regulator"].logistics_connection_distance,
    radar_range = data.raw.roboport["maraxsis-regulator"].radar_range,
    logistics_radius = data.raw.roboport["maraxsis-regulator"].logistics_radius,
    construction_radius = data.raw.roboport["maraxsis-regulator"].construction_radius,
    maraxsis_buildability_rules = {water = true, dome = true, coral = true, trench = true, trench_entrance = true, trench_lava = false},
    energy_source = {type = "void"},
    energy_usage = "0W",
    recharge_minimum = "0W",
    charging_energy = "0W",
    spawn_and_station_height = 0,
    charge_approach_distance = 0,
    request_to_open_door_timeout = 0,
    robot_slots_count = 0,
    material_slots_count = 0,
    name = "maraxsis-pressure-dome",
    remove_decoratives = "false",
    icon = "__maraxsis__/graphics/icons/pressure-dome.png",
    icon_size = 64,
    flags = {"placeable-player", "player-creation", "not-on-map"},
    max_health = 10000,
    collision_box = collision_box(),
    minable = {mining_time = 1, result = "maraxsis-pressure-dome"},
    selection_box = {{-base_dome_params.octagon_size, -base_dome_params.octagon_size}, {base_dome_params.octagon_size, base_dome_params.octagon_size}},
    drawing_box = collision_box(),
    collision_mask = {colliding_with_tiles_only = true, layers = {["empty_space"] = true}},
    render_layer = "higher-object-above",
    moc_ignore = true,
    base = {
        layers = table.array_combine({
            cage_shadow,
            base_shadow,
            dome_base,
            dome,
        }, table.deepcopy(data.raw.roboport["maraxsis-regulator"].integration_patch.layers))
    },
    surface_conditions = maraxsis.surface_conditions(),
    build_sound = {
        filename = "__core__/sound/build-ghost-tile.ogg",
        volume = 0
    },
    created_smoke = {
        type = "create-trivial-smoke",
        smoke_name = "maraxsis-invisible-smoke",
    },
}}

data:extend {{
    type = "sprite",
    name = "maraxsis-pressure-dome-sprite",
    layers = {cage_shadow, base_shadow, dome},
},
{
    type = "sprite",
    name = "maraxsis-pressure-dome-base-sprite",
    layers = {dome_base},
}}

data:extend {maraxsis.merge(data.raw["lamp"]["small-lamp"], {
    type = "lamp",
    name = "maraxsis-pressure-dome-lamp",
    factoriopedia_alternative = "maraxsis-pressure-dome",
    quality_indicator_scale = 0,
    localised_description = {"entity-description.maraxsis-pressure-dome"},
    remove_decoratives = "false",
    hidden = true,
    surface_conditions = maraxsis.surface_conditions(),
    minable = "nil",
    flags = {"placeable-player", "player-creation", "not-on-map", "not-blueprintable"},
    max_health = 10000,
    collision_box = collision_box(),
    selection_box = {{-0.01, -0.01}, {0.01, 0.01}},
    selection_priority = 1,
    drawing_box = collision_box(),
    collision_mask = {layers = {}},
    selectable_in_game = true,
    picture_on = maraxsis.empty_image(),
    picture_off = maraxsis.empty_image(),
    circuit_wire_max_distance = 16,
    energy_usage_per_tick = "20kW",
    glow_size = 60,
    light = {
        size = 80,
        color = {
            b = 0.75,
            g = 1,
            r = 1
        },
        intensity = 0.9,
    },
    light_when_colored = {
        color = {
            b = 0.75,
            g = 1,
            r = 1
        },
        intensity = 0,
        size = 55,
    },
})}
data.raw.lamp["maraxsis-pressure-dome-lamp"].energy_source.render_no_network_icon = false
data.raw.lamp["maraxsis-pressure-dome-lamp"].energy_source.render_no_power_icon = false

-- Even Pickier Dollies moves whichever entity the player has selected. The
-- domes' regulator collides with the machines built inside a dome, so EPD
-- refuses to move it. The dome lamp is an invisible entity that does not
-- collide with anything and sits at the exact same position, so when EPD is
-- installed we let it be selected instead and use it as the dome's drag handle.
if mods["even-pickier-dollies"] then
    local dome_lamp = data.raw.lamp["maraxsis-pressure-dome-lamp"]
    dome_lamp.selection_box = {{-2, -2}, {2, 2}}
end

data:extend {maraxsis.merge(data.raw["constant-combinator"]["constant-combinator"], {
    type = "constant-combinator",
    name = "maraxsis-pressure-dome-combinator",
    factoriopedia_alternative = "maraxsis-pressure-dome",
    surface_conditions = maraxsis.surface_conditions(),
    localised_name = {"entity-name.maraxsis-pressure-dome"},
    localised_description = {"entity-description.maraxsis-pressure-dome"},
    remove_decoratives = "false",
    icon = "__maraxsis__/graphics/icons/pressure-dome.png",
    icon_size = 64,
    flags = {"placeable-player", "player-creation", "not-on-map", "not-blueprintable"},
    max_health = 10000,
    minable = "nil",
    hidden = true,
    selectable_in_game = false,
    item_slot_count = 500,
    activity_led_light_offsets = {
        {0, 0},
        {0, 0},
        {0, 0},
        {0, 0}
    },
    circuit_wire_connection_points = {
        {
            shadow = {red = {0, 0}, green = {0, 0}},
            wire = {red = {0, 0}, green = {0, 0}}
        },
        {
            shadow = {red = {0, 0}, green = {0, 0}},
            wire = {red = {0, 0}, green = {0, 0}}
        },
        {
            shadow = {red = {0, 0}, green = {0, 0}},
            wire = {red = {0, 0}, green = {0, 0}}
        },
        {
            shadow = {red = {0, 0}, green = {0, 0}},
            wire = {red = {0, 0}, green = {0, 0}}
        }
    },
    draw_copper_wires = false,
    draw_circuit_wires = false,
    sprites = "nil",
    quality_indicator_scale = 0,
    icon_draw_specification = {scale = 0, scale_for_many = 0},
    activity_led_sprites = "nil",
    activity_led_light = "nil",
    collision_mask = {layers = {}},
})}

local function shift_the_circuit_connection_point(entity, x, y)
    local connection = entity.circuit_connector.points

    local function adjust_shift(vector)
        if not vector then return end
        vector.x = (vector[1] or vector.x or 0) + x
        vector.y = (vector[2] or vector.y or 0) + y
    end

    for _, connection in pairs(connection) do
        for _, color in pairs(connection) do
            adjust_shift(color)
        end
    end

    for _, sprite in pairs(entity.circuit_connector.sprites) do
        adjust_shift(sprite.shift or {})
        for _, layer in pairs(sprite.layers or {}) do
            adjust_shift(layer.shift or {})
        end
        if sprite.picture then
            adjust_shift(sprite.picture.shift or {})
        end
    end
end

shift_the_circuit_connection_point(data.raw["lamp"]["maraxsis-pressure-dome-lamp"], 4, 17)

data:extend {{
    type = "trivial-smoke",
    name = "maraxsis-invisible-smoke",
    duration = 1,
    fade_away_duration = 1,
    spread_duration = 1,
    animation = {
        filename = "__core__/graphics/empty.png",
        priority = "high",
        width = 1,
        height = 1,
        flags = {"smoke"},
        frame_count = 1,
    },
    cyclic = true
}}

data:extend {{
    type = "simple-entity-with-owner",
    name = "maraxsis-pressure-dome-collision",
    factoriopedia_alternative = "maraxsis-pressure-dome",
    localised_name = {"entity-name.maraxsis-pressure-dome"},
    icon = "__maraxsis__/graphics/icons/pressure-dome.png",
    quality_indicator_scale = 0,
    surface_conditions = maraxsis.surface_conditions(),
    icon_size = 64,
    hidden = true,
    flags = {"placeable-player", "player-creation", "placeable-off-grid", "not-on-map", "building-direction-8-way", "not-blueprintable"},
    max_health = 10000,
    collision_box = {{-base_dome_params.corner_size, -0.3}, {base_dome_params.corner_size, 0.3}},
    selection_box = {{-base_dome_params.corner_size, -0.5}, {base_dome_params.corner_size, 0.5}},
    drawing_box = {{0, 0}, {0, 0}},
    collision_mask = {layers = {
        ["water_tile"] = true,
        ["object"] = true,
        ["item"] = true,
        [maraxsis_underwater_collision_mask] = true,
        [maraxsis_dome_collision_mask] = true
    }},
    squeak_behaviour = false,
    minable = {mining_time = 1, result = "maraxsis-pressure-dome"},
    placeable_by = {{item = "maraxsis-pressure-dome", count = 1}},
    resistances = {
        {
            type = "acid",
            percent = 90
        },
        {
            type = "fire",
            percent = 100
        },
    }
}}

data:extend {{
    type = "sprite",
    name = "maraxsis-flooded-warning",
    filename = "__maraxsis__/graphics/icons/flooded-warning.png",
    width = 64,
    height = 64,
    scale = 0.5,
    shift = {0, 0},
    flags = {"no-crop", "no-scale", "icon"},
}}



local new_dome_params = {
    -- ["maraxsis-pressure-dome-large"] = {
    --     octagon_size = 24.5,
    --     --corner_size = 10,
    --     dome_collider = "maraxsis-pressure-dome-collision-large",
    --     diagonal_offset = 7.25,
    --     sprite = "maraxsis-pressure-dome-sprite-large",
    --     base_sprite = "maraxsis-pressure-dome-base-sprite-large",
    -- }
}    

for dome,params in pairs(new_dome_params) do
    params.corner_size = math.floor(((params.octagon_size-0.5)/16)*7)

    local constants = table.deepcopy(maraxsis_constants.PRESSURE_DOMES["maraxsis-pressure-dome"])

    maraxsis_constants.PRESSURE_DOMES[dome] = constants

    

    local item = table.deepcopy(data.raw.item["maraxsis-pressure-dome"])
    local roboport = table.deepcopy(data.raw.roboport["maraxsis-pressure-dome"])
    local recipe = table.deepcopy(data.raw.recipe["maraxsis-pressure-dome"])
    local collider = table.deepcopy(data.raw["simple-entity-with-owner"]["maraxsis-pressure-dome-collision"])

    item.place_result = dome
    roboport.minable.result = dome
    collider.minable.result = dome
    item.name = dome
    item.icon = "__maraxsis__/graphics/icons/pressure-dome-big.png"
    roboport.name = dome
    recipe.name = dome
    recipe.results[1].name = dome
    collider.name = params.dome_collider
    collider.selection_box = {{-params.corner_size, -0.5}, {params.corner_size, 0.5}}
    collider.collision_box = {{-params.corner_size, -0.3}, {params.corner_size, 0.3}}
    roboport.selection_box = {{-params.octagon_size, -params.octagon_size}, {params.octagon_size, params.octagon_size}}
    local sprite_shift_up = 1.25
    local cage_shadow = {
    filename = "__maraxsis__/graphics/entity/pressure-dome-big/pressure-dome-shadow.png",
    width = 1792,
    height = 1792,
    scale = 0.965*(params.octagon_size-0.5)/24,
    shift = {0, -sprite_shift_up-8/32},
    flags = {"no-scale"},
    draw_as_shadow = true,
}
    local dome_sprite = {
        filename = "__maraxsis__/graphics/entity/pressure-dome-big/pressure-dome-cage.png",
        width = 1792,
        height = 1792,
        scale = 0.965*(params.octagon_size-0.5)/24,
        shift = {0, -sprite_shift_up-8/32},
        flags = {"no-scale"},
    }

    local dome_base_sprite = {
        filename = "__maraxsis__/graphics/entity/pressure-dome-big/pressure-dome-base.png",
        width = 1792,
        height = 1792,
        scale = 0.965*(params.octagon_size-0.5)/24,
        shift = {0, -sprite_shift_up},
        flags = {"no-scale"},
    }

    roboport.base = {
        layers = table.array_combine({
            cage_shadow,
            dome_sprite,
            dome_base_sprite,
        }, table.deepcopy(data.raw.roboport["maraxsis-regulator"].integration_patch.layers))
    }

        data:extend {{
        type = "sprite",
        name = params.sprite,
        layers = {cage_shadow, cage_shadow, dome_sprite},
    }}
    data:extend {{
        type = "sprite",
        name = params.base_sprite,
        layers = {dome_base_sprite},
    }
}
    
    data:extend{item,roboport,recipe,collider}
    
    constants.octagon_size = params.octagon_size
    constants.corner_size = params.corner_size
    constants.pressure_dome = dome
    constants.recipe = dome
    constants.dome_collider = params.dome_collider
    constants.diagonal_offset = params.diagonal_offset
    constants.sprite = params.sprite
    constants.base_sprite = params.base_sprite
    maraxsis_constants.PRESSURE_DOMES[dome] = constants
end

for key,dome_data in pairs(maraxsis_constants.PRESSURE_DOMES) do
    dome_data.octagon_diameter = (dome_data.octagon_size - 0.5) * 2
    local dome = data.raw["roboport"][dome_data.pressure_dome]
    dome.custom_tooltips = dome.custom_tooltips or {}
end
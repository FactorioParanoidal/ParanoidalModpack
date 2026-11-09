data:extend {{
    type = "technology",
    name = "maraxsis-sonar",
    icon = "__maraxsis__/graphics/technology/sonar.png",
    icon_size = 256,
    effects = {
        {
            type = "unlock-recipe",
            recipe = "maraxsis-sonar"
        }
    },
    prerequisites = {"maraxsis-project-seadragon", "radar"},
    unit = {
        count = 1000,
        ingredients = {
            {"automation-science-pack",      1},
            {"logistic-science-pack",        1},
            {"military-science-pack",        1},
            {"chemical-science-pack",        1},
            {"space-science-pack",           1},
            {"production-science-pack",      1},
            {"utility-science-pack",         1},
            {"metallurgic-science-pack",     1},
            {"electromagnetic-science-pack", 1},
            {"agricultural-science-pack",    1},
            {"hydraulic-science-pack",       1},
        },
        time = 60,
    },
}}

data:extend {{
    type = "item",
    name = "maraxsis-sonar",
    icon = "__maraxsis__/graphics/icons/sonar.png",
    icon_size = 64,
    stack_size = 10,
    place_result = "maraxsis-sonar",
}}

data:extend {{
    type = "recipe",
    name = "maraxsis-sonar",
    enabled = false,
    ingredients = {
        {type = "item", name = "maraxsis-glass-panes", amount = 10},
        {type = "item", name = "radar",                amount = 1},
        {type = "item", name = "small-lamp",           amount = 2},
    },
    results = {
        {type = "item", name = "maraxsis-sonar", amount = 1},
    },
    energy_required = 10,
    auto_recycle = true,
    categories = {"maraxsis-hydro-plant"},
}}

data:extend {maraxsis.merge(data.raw.radar.radar, {
    type = "radar",
    name = "maraxsis-sonar",
    icon = "__maraxsis__/graphics/icons/sonar.png",
    icon_size = 64,
    localised_description = {"technology-description.maraxsis-sonar"},
    flags = {"placeable-player", "player-creation"},
    minable = {mining_time = 0.5, result = "maraxsis-sonar"},
    max_health = 550,
    circuit_connector = circuit_connector_definitions["maraxsis-sonar"],
    circuit_wire_max_distance = _G.default_circuit_wire_max_distance,
    corpse = "radar-remnants",
    dying_explosion = "radar-explosion",
    resistances = {
        {
            type = "fire",
            percent = 70
        },
        {
            type = "impact",
            percent = 30
        }
    },
    collision_box = {{-2.8, -2.3}, {2.8, 2.3}},
    selection_box = {{-3, -2.5}, {3, 2.5}},
    energy_per_sector = "40MJ",
    maraxsis_buildability_rules = {water = true, dome = true, coral = true, trench = true, trench_entrance = false, trench_lava = false},
    max_distance_of_sector_revealed = 36,
    max_distance_of_nearby_sector_revealed = 6,
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input"
    },
    energy_usage = "900kW",
    pictures = {
        layers = {
            {
                filename = "__maraxsis__/graphics/entity/sonar/sonar.png",
                width = 320,
                height = 384,
                apply_projection = false,
                direction_count = 64,
                line_length = 8,
                scale = .65,
                shift = util.by_pixel(0, -30 - 16),
            },
            {
                filename = "__maraxsis__/graphics/entity/sonar/sonar-shadow.png",
                width = 384,
                height = 192,
                scale = 0.65,
                draw_as_shadow = true,
                direction_count = 64,
                line_length = 8,
                shift = util.by_pixel(30, 20 - 16),
            },
        }
    },
    working_sound = {
        sound = {
            {
                filename = "__maraxsis__/sounds/sonar.ogg",
                speed = 0.5,
                volume = 1
            }
        },
        max_sounds_per_type = 2,
        audible_distance_modifier = 0.8,
        use_doppler_shift = false
    },
    radius_minimap_visualisation_color = {r = 0.059, g = 0.092, b = 0.235, a = 0.275},
    rotation_speed = 0.005,
    water_reflection = {
        pictures = {
            filename = "__base__/graphics/entity/radar/radar-reflection.png",
            priority = "extra-high",
            width = 28,
            height = 32,
            shift = util.by_pixel(5, 35),
            variation_count = 1,
            scale = 5,
        },
        rotate = false,
        orientation_to_variation = false
    }
})}

local light_layers = require "graphics.entity.sonar.lights.lights"
for _, layer in pairs(light_layers) do
    layer.scale = (layer.scale or 1) * 0.65
    layer.shift = {
        x = (layer.shift.x or 0) * 0.65,
        y = (layer.shift.y or 0) * 0.65 - 30 / 32 - 16 / 32,
    }
end
light_layers["hr-light-1-on"].draw_as_glow = true
light_layers["hr-light-2-on"].draw_as_glow = true

light_layers["hr-light-1"].shift.y = light_layers["hr-light-1"].shift.y - 1
light_layers["hr-light-1-on"].shift.y = light_layers["hr-light-1-on"].shift.y - 1
light_layers["hr-light-2"].shift.y = light_layers["hr-light-2"].shift.y + 1
light_layers["hr-light-2-on"].shift.y = light_layers["hr-light-2-on"].shift.y + 1

data:extend {maraxsis.merge(data.raw.lamp["small-lamp"], {
    name = "maraxsis-sonar-light-1",
    collision_box = {},
    localised_name = {"entity-name.maraxsis-sonar"},
    localised_description = {"entity-description.maraxsis-sonar"},
    icon = "__maraxsis__/graphics/icons/sonar.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = "nil",
    max_health = 100,
    corpse = "small-remnants",
    dying_explosion = "nil",
    collision_box = table.deepcopy(data.raw.radar["maraxsis-sonar"].collision_box),
    selection_box = table.deepcopy(data.raw.radar["maraxsis-sonar"].selection_box),
    selectable_in_game = false,
    circuit_wire_connection_point = "nil",
    circuit_wire_max_distance = "nil",
    draw_copper_wires = false,
    draw_circuit_wires = false,
    circuit_connector = "nil",
    hidden = true,
    light_when_colored = "nil",
    picture_on = {
        layers = {
            light_layers["hr-light-1"],
            light_layers["hr-light-1-on"],
        }
    },
    picture_off = {
        layers = {
            light_layers["hr-light-1"],
        }
    },
})}

data:extend {maraxsis.merge(data.raw.lamp["maraxsis-sonar-light-1"], {
    name = "maraxsis-sonar-light-2",
    picture_on = {
        layers = {
            light_layers["hr-light-2"],
            light_layers["hr-light-2-on"],
        }
    },
    picture_off = {
        layers = {
            light_layers["hr-light-2"],
        }
    },
})}

local function shift_collision_box(entity, amount)
    local box = entity.collision_box
    local x1, y1, x2, y2 = box[1].x or box[1][1], box[1].y or box[1][2], box[2].x or box[2][1], box[2].y or box[2][2]
    entity.collision_box = {{x1, y1 + amount}, {x2, y2 + amount}}
    local box = entity.selection_box
    local x1, y1, x2, y2 = box[1].x or box[1][1], box[1].y or box[1][2], box[2].x or box[2][1], box[2].y or box[2][2]
    entity.selection_box = {{x1, y1 + amount}, {x2, y2 + amount}}
end

shift_collision_box(data.raw.lamp["maraxsis-sonar-light-1"], -1)
shift_collision_box(data.raw.lamp["maraxsis-sonar-light-2"], 1)

for _, lamp in pairs {"maraxsis-sonar-light-1", "maraxsis-sonar-light-2"} do
    lamp = data.raw.lamp[lamp]
    lamp.energy_source.render_no_power_icon = false
    lamp.energy_source.render_no_network_icon = false
    local shift = lamp.light.shift or {}
    local x, y = shift.x or shift[1] or 0, shift.y or shift[2] or 0
    x = x + lamp.picture_on.layers[1].shift.x
    y = y + lamp.picture_on.layers[1].shift.y
    lamp.light.shift = {x = x, y = y}
    lamp.light.intensity = lamp.light.intensity / 3
    lamp.light.size = lamp.light.size / 2
end

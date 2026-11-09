data:extend {{
    type = "technology",
    name = "maraxsis-nuclear-submarine",
    icon = "__maraxsis__/graphics/technology/nuclear-submarine.png",
    icon_size = 256,
    effects = {
        {
            type = "unlock-recipe",
            recipe = "maraxsis-nuclear-submarine",
        },
    },
    prerequisites = {"maraxsis-project-seadragon", "maraxsis-sonar", "nuclear-power", "cryogenic-science-pack"},
    unit = {
        count = 3000,
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
            {"cryogenic-science-pack",       1},
        },
        time = 60,
    },
    order = "eh[nuclear-submarine]",
}}

local collision_mask = {
    layers = {
        ["rail"] = true,
    },
    colliding_with_tiles_only = true,
}

local colors = { -- default sub colors before they are tinted at runtime
    {195, 136, 24},
    {144, 31,  15},
    {14,  94,  146},
    {64,  12,  146},
}

local movement_energy_consumption = {
    13000,
    6000,
}

data:extend {{
    type = "fuel-category",
    name = "maraxsis-diesel",
}}

local recipes = {
    ["maraxsis-diesel-submarine"] = {
        {type = "item", name = "tungsten-plate",       amount = 30},
        {type = "item", name = "electric-engine-unit", amount = 10},
        {type = "item", name = "processing-unit",      amount = 10},
        {type = "item", name = "pump",                 amount = 4},
    },
    ["maraxsis-nuclear-submarine"] = {
        {type = "item", name = "tungsten-plate",                   amount = 50},
        {type = "item", name = "maraxsis-sonar",                   amount = 1},
        {type = "item", name = "maraxsis-glass-panes",             amount = 100},
        {type = "item", name = "nuclear-reactor",                  amount = 1},
        {type = "item", name = "pump",                             amount = 8},
        {type = "item", name = "processing-unit",                  amount = 50},
        {type = "item", name = "maraxsis-super-sealant-substance", amount = 100},
    },
}

for i = 1, 2 do
    local name = i == 1 and "maraxsis-diesel-submarine" or "maraxsis-nuclear-submarine"
    local icon = "__maraxsis__/graphics/icons/" .. (i == 1 and "diesel" or "nuclear") .. "-submarine.png"

    if aai_vehicle_exclusions then table.insert(aai_vehicle_exclusions, name) end

    local grid = table.deepcopy(data.raw["equipment-grid"]["spidertron-equipment-grid"])
    grid.height = 3 + 3 * i
    grid.name = name .. "-equipment-grid"
    data:extend {grid}

    local item = {
        type = "item-with-entity-data",
        name = name,
        icon = icon,
        icon_size = 64,
        place_result = name,
        stack_size = 1,
        flags = {"not-stackable"},
    }

    local recipe = {
        type = "recipe",
        name = name,
        ingredients = recipes[name],
        results = {{type = "item", name = name, amount = 1}},
        enabled = false,
        auto_recycle = true,
        energy_required = 10,
        categories = i == 1 and {"maraxsis-hydro-plant", "crafting"} or {"maraxsis-hydro-plant"},
    }

    local lamp_layer = {
        direction_count = 60,
        frame_count = 1,
        ["line_length"] = 7,
        ["lines_per_file"] = 9,
        draw_as_glow = true,
        ["shift"] = {x = 0 / 64, y = -26 / 64},
        scale = 0.5,
        filename = "__maraxsis__/graphics/entity/submarine/lamp.png",
        height = 282,
        width = 366,
    }

    local mask_layer = {
        direction_count = 60,
        frame_count = 1,
        ["line_length"] = 8,
        ["lines_per_file"] = 8,
        ["shift"] = {x = 0 / 64, y = -25.5 / 64},
        scale = 0.5,
        filename = "__maraxsis__/graphics/entity/submarine/mask.png",
        ["height"] = 333,
        ["width"] = 372,
        apply_runtime_tint = true,
        tint = {0.6, 0.6, 0.6},
    }

    local full_body_layer = {
        direction_count = 60,
        ["line_length"] = 8,
        ["lines_per_file"] = 8,
        shift = {x = 0 / 64, y = -25.5 / 64},
        scale = 0.5,
        filename = "__maraxsis__/graphics/entity/submarine/full-body.png",
        height = 333,
        width = 372,
    }

    local shadow_layer = {
        direction_count = 60,
        frame_count = 1,
        ["line_length"] = 8,
        ["lines_per_file"] = 8,
        draw_as_shadow = true,
        scale = 0.9,
        filename = "__maraxsis__/graphics/entity/submarine/shadow.png",
        height = 256,
        width = 256,
        shift = {x = 6, y = 45.5 / 32 + 6},
    }

    local entity = table.deepcopy(data.raw["spider-vehicle"]["spidertron"])
    entity.name = name
    entity.icon = icon
    entity.equipment_grid = grid.name
    entity.maraxsis_buildability_rules = {water = true, dome = true, coral = true, trench = true, trench_entrance = true, trench_lava = true}
    entity.icon_size = 64
    entity.height = 0
    entity.flags = {"placeable-player", "player-creation", "placeable-off-grid", "no-automated-item-removal", "no-automated-item-insertion"}
    entity.torso_bob_speed = 0.4
    entity.minable.result = name
    entity.surface_conditions = maraxsis.surface_conditions()
    entity.max_health = 3000 * 2 ^ (i - 1)
    entity.collision_box = {{-1.1, -1.1}, {1.1, 1.1}}
    entity.selection_box = {{-1.1, -1.1}, {1.1, 1.1}}
    entity.drawing_box = {{-2.8, -2.8}, {2.8, 2.8}}
    entity.light_animation = nil
    entity.tank_driving = true
    entity.collision_mask = collision_mask
    entity.working_sound = {
        apparent_volume = 0.3,
        max_sounds_per_type = 3,
        audible_distance_modifier = 1,
        fade_in_ticks = 60,
        fade_out_ticks = 60,
        match_speed_to_activity = true,
        sound = {
            filename = "__maraxsis__/sounds/submarine.ogg",
            category = "game-effect",
        }
    }
    entity.open_sound = table.deepcopy(data.raw.car.tank.open_sound)
    entity.close_sound = table.deepcopy(data.raw.car.tank.close_sound)

    local submarine_colors = {
        {r = 1, g = 1, b = 1,  a = 0.5},
        {r = 0.2, g = 0.7, b = 0.2, a = 0.5},
    }

    entity.minimap_representation = {
        filename = "__maraxsis__/graphics/entity/submarine/submarine-map-tag.png",
        flags = {"icon"},
        tint = submarine_colors[i],
        size = {64, 64}
    }
    entity.selected_minimap_representation = {
        filename = "__maraxsis__/graphics/entity/submarine/selected-submarine-map-tag.png",
        flags = {"icon"},
        size = {70, 70}
    }
    entity.quality_indicator_scale = 0
    entity.movement_energy_consumption = movement_energy_consumption[i] .. "kW"
    entity.weight = entity.weight / (i + 1) * 4 * movement_energy_consumption[i] / 800
    entity.energy_source = {
        type = "burner",
        fuel_categories = maraxsis_constants.SUBMARINE_FUEL_SOURCES[name],
        effectivity = 1,
        fuel_inventory_size = 4,
        burnt_inventory_size = 4,
        smoke = {
            {
                name = "maraxsis-submarine-bubbles",
                deviation = {0.35, 0.35},
                frequency = 1500,
                position = {0, 0},
                slow_down_factor = 1,
                starting_frame = 3,
                starting_frame_deviation = 50,
                starting_frame_speed = 0,
                starting_frame_speed_deviation = 5,
            }
        }
    }
    entity.guns = table.deepcopy(data.raw["spider-vehicle"]["spidertron"].guns)
    entity.resistances = {
        {type = "fire",   percent = 100},
        {type = "impact", percent = 100},
    }
    entity.has_belt_immunity = true
    entity.immune_to_tree_impacts = true
    if i > 1 then entity.immune_to_rock_impacts = true end
    entity.immune_to_cliff_impacts = true
    entity.inventory_size = i * 30

    entity.factoriopedia_simulation = {
        init = [[
            for x = -10, 10, 1 do
                for y = -6, 6 do
                    game.surfaces[1].set_tiles{{position = {x, y}, name = "sand-1-underwater"}}
                end
            end
            game.simulation.camera_zoom = 1.3
            game.simulation.camera_position = {0, 0}
            game.surfaces[1].create_entity{name = "]] .. name .. [[", position = {0, 0}}.color = ]] .. serpent.line(submarine_colors[i]) .. [[
            game.surfaces[1].create_entity {
                name = "maraxsis-water-shader",
                position = {0, 0},
                create_build_effect_smoke = false
            }
        ]]
    }
    entity.alert_icon_shift = {0, 0}
    entity.drawing_box_vertical_extension = 1
    entity.trash_inventory_size = 10
    entity.turret_animation = nil
    entity.friction = 0.005
    entity.rotation_speed = 0.025 * 0.2 * (i / 2 + 0.5)
    entity.spider_engine.walking_group_overlap = 1
    entity.spider_engine.legs = {leg = "maraxsis-submarine-leg", mount_position = {0, 0.5}, ground_position = {0, 0}, blocking_legs = {}, walking_group = 1}

    local light_cone = {
        filename = "__core__/graphics/light-cone.png",
        flags = {
            "light"
        },
        height = 200,
        priority = "extra-high",
        scale = 2,
        width = 200
    }

    entity.graphics_set.light = {
        {
            color = {
                b = 1,
                g = 1,
                r = 1
            },
            intensity = 0.4,
            size = 25
        },
        {
            color = {1, 1, 1},
            picture = light_cone,
            shift = {0, -15.4 * 1.5},
            size = 3,
            intensity = 0.8,
            type = "oriented"
        },
        {
            color = {1, 1, 1},
            picture = light_cone,
            shift = {0, -8.4 * 1.5},
            size = 1.5,
            intensity = 0.3,
            type = "oriented",
            source_orientation_offset = 0.11,
        },
        {
            color = {1, 1, 1},
            picture = light_cone,
            shift = {0, -8.4 * 1.5},
            size = 1.5,
            intensity = 0.3,
            type = "oriented",
            source_orientation_offset = -0.11,
        },
        {
            color = {1, 1, 1},
            picture = light_cone,
            shift = {0, -7.4 * 1.5},
            size = 1.5,
            intensity = 0.3,
            type = "oriented",
            source_orientation_offset = 0.5+0.15,
        },
        {
            color = {1, 1, 1},
            picture = light_cone,
            shift = {0, -7.4 * 1.5},
            size = 1.5,
            intensity = 0.3,
            type = "oriented",
            source_orientation_offset = 0.5-0.15,
        },
    }
    entity.graphics_set.animation = {
        direction_count = 60,
        layers = {
            lamp_layer,
            full_body_layer,
            mask_layer,
            shadow_layer,
        }
    }
    entity.graphics_set.base_animation = nil
    entity.graphics_set.shadow_base_animation = nil
    entity.graphics_set.shadow_animation = nil
    entity.graphics_set.eye_light = nil
    entity.graphics_set.light_positions = nil
    entity.graphics_set.default_color = submarine_colors[i]

    data:extend {item, recipe, entity}
end

data:extend {{
    type = "custom-input",
    key_sequence = "",
    linked_game_control = "toggle-driving",
    name = "toggle-driving",
}}

data:extend {{
    type = "custom-input",
    key_sequence = "CONTROL + RETURN",
    name = "maraxsis-trench-submerge",
    consuming = "game-only",
    alternative_key_sequence = "",
    controller_key_sequence = "controller-righttrigger + controller-lefttrigger + controller-y",
    controller_alternative_key_sequence = "",
    action = "lua",
}}

local vehicle_leg = table.deepcopy(data.raw["spider-leg"]["spidertron-leg-1"])
vehicle_leg.name = "maraxsis-submarine-leg"
vehicle_leg.maraxsis_buildability_rules = {water = true, dome = true, coral = true, trench = true, trench_entrance = true, trench_lava = true}
vehicle_leg.graphics_set = {}
vehicle_leg.collision_mask = collision_mask
vehicle_leg.target_position_randomisation_distance = 0
vehicle_leg.working_sound = nil
vehicle_leg.minimal_step_size = 0
vehicle_leg.part_length = 2
vehicle_leg.knee_height = 0
vehicle_leg.angle_height = 0
vehicle_leg.stretch_force_scalar = 3
vehicle_leg.movement_based_position_selection_distance = 1.5 -- I have no idea what this does.
vehicle_leg.initial_movement_speed = 0
vehicle_leg.movement_acceleration = 1
vehicle_leg.walking_sound_volume_modifier = 0
vehicle_leg.part_length = 0.1
vehicle_leg.selectable_in_game = false
data:extend {vehicle_leg}

local torpedo_launchers = {}
for i = 1, 6 do
    local launcher                                           = table.deepcopy(data.raw.gun["spidertron-rocket-launcher-1"])
    launcher.localised_name                                  = {"item-name.maraxsis-torpedo-launch-silo"}
    launcher.localised_description                           = nil
    launcher.name                                            = "maraxsis-torpedo-launch-silo-" .. i
    launcher.icon                                            = "__base__/graphics/icons/tank-cannon.png"
    launcher.icon_size                                       = 64
    launcher.attack_parameters.ammo_categories               = {"cannon-shell", "tesla"}
    launcher.attack_parameters.projectile_orientation_offset = 0
    launcher.attack_parameters.projectile_creation_distance  = 3
    launcher.attack_parameters.range                         = 96
    table.insert(torpedo_launchers, launcher)
end
data:extend(torpedo_launchers)

data.raw["spider-vehicle"]["maraxsis-diesel-submarine"].guns = {
    "maraxsis-torpedo-launch-silo-1",
    "maraxsis-torpedo-launch-silo-2",
    "maraxsis-torpedo-launch-silo-3",
    "maraxsis-torpedo-launch-silo-4",
}

data.raw["spider-vehicle"]["maraxsis-nuclear-submarine"].guns = {
    "maraxsis-torpedo-launch-silo-1",
    "maraxsis-torpedo-launch-silo-2",
    "maraxsis-torpedo-launch-silo-3",
    "maraxsis-torpedo-launch-silo-4",
    "maraxsis-torpedo-launch-silo-5",
    "maraxsis-torpedo-launch-silo-6",
}

data:extend {{
    type = "sound",
    name = "maraxsis-submerge",
    category = "game-effect",
    priority = 100,
    filename = "__maraxsis__/sounds/submerge.ogg",
    speed = 0.5
}}

-- https://github.com/notnotmelon/maraxsis/issues/341
local toolbelt_equipment = table.deepcopy(data.raw["inventory-bonus-equipment"]["toolbelt-equipment"])
toolbelt_equipment.name = "maraxsis-toolbelt-equipment"
toolbelt_equipment.shape = {width = 0, height = 0, type = "full"}
toolbelt_equipment.hidden = true
toolbelt_equipment.take_result = "toolbelt-equipment"
toolbelt_equipment.inventory_size_bonus = 1
data:extend{toolbelt_equipment}

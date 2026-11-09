data:extend {{
    type = "technology",
    name = "maraxsis-depth-charges",
    icon = "__maraxsis__/graphics/technology/depth-charges.png",
    icon_size = 256,
    effects = {
        {
            type = "unlock-recipe",
            recipe = "maraxsis-big-cliff-explosives"
        },
        {
            type = "unlock-recipe",
            recipe = "maraxsis-fat-man",
        },
        {
            type = "unlock-recipe",
            recipe = "maraxsis-pipe-bomb"
        }
    },
    prerequisites = {"cliff-explosives", "maraxsis-nuclear-submarine", "atomic-bomb"},
    unit = {
        count = 5000,
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
    order = "eh[depth-charges]",
}}

data:extend {{
    type = "recipe",
    name = "maraxsis-big-cliff-explosives",
    enabled = false,
    energy_required = 10,
    ingredients = {
        {type = "item", name = "cliff-explosives",                 amount = 1},
        {type = "item", name = "atomic-bomb",                      amount = 1},
        {type = "item", name = "maraxsis-super-sealant-substance", amount = 1},
    },
    results = {
        {type = "item", name = "maraxsis-big-cliff-explosives", amount = 1, quality_min = "legendary"},
    },
    auto_recycle = false,
    categories = {"maraxsis-hydro-plant" },
    icons = {
        {
            icon = "__maraxsis__/graphics/icons/big-cliff-explosives.png",
            icon_size = 64,
        },
        {
            icon = data.raw.quality.legendary.icon,
            icon_size = data.raw.quality.legendary.icon_size,
            scale = 0.25,
            shift = {-8, 8},
            floating = true
        },
    },
}}

data:extend {{
    type = "recipe",
    name = "maraxsis-pipe-bomb",
    energy_required = data.raw.recipe["grenade"].energy_required,
    categories = {"maraxsis-hydro-plant"},
    enabled = false,
    results = {
        {type = "item", name = "grenade", amount = 2, quality_change = 1},
    },
    ingredients = {
        {type = "item", name = "explosives", amount = 5},
        {type = "item", name = "pipe",       amount = 5},
    },
    auto_recycle = false,
}}

data:extend {{
    type = "capsule",
    name = "maraxsis-big-cliff-explosives",
    icon = "__maraxsis__/graphics/icons/big-cliff-explosives.png",
    icon_size = 64,
    stack_size = 10,
    capsule_action = {
        type = "destroy-cliffs",
        radius = 100,
        attack_parameters = {
            type = "projectile",
            activation_type = "throw",
            ammo_category = "grenade",
            cooldown = 30,
            projectile_creation_distance = 0.6,
            range = 30,
            ammo_type = {
                category = "grenade",
                target_type = "position",
                action = {
                    type = "direct",
                    action_delivery = {
                        type = "projectile",
                        projectile = "maraxsis-big-cliff-explosives",
                        starting_speed = 0.3
                    }
                }
            }
        }
    },
}}

data:extend {maraxsis.merge(data.raw.projectile["cliff-explosives"], {
    name = "maraxsis-big-cliff-explosives",
    action = {
        {
            action_delivery = {
                target_effects = {
                    {
                        decoratives_with_trigger_only = false,
                        include_decals = true,
                        include_soft_decoratives = true,
                        invoke_decorative_trigger = true,
                        radius = 14,
                        type = "destroy-decoratives"
                    },
                    {
                        apply_projection = true,
                        decorative = "nuclear-ground-patch",
                        spawn_max = 40,
                        spawn_max_radius = 12.5,
                        spawn_min = 30,
                        spawn_min_radius = 11.5,
                        spread_evenly = true,
                        type = "create-decorative"
                    },
                    {
                        explosion = "explosion",
                        radius = 450,
                        type = "destroy-cliffs"
                    },
                    {
                        action = {
                            action_delivery = {
                                projectile = "atomic-bomb-ground-zero-projectile",
                                starting_speed = 1.48,
                                starting_speed_deviation = 0.075,
                                type = "projectile"
                            },
                            radius = 7,
                            repeat_count = 1000,
                            target_entities = false,
                            trigger_from_target = true,
                            type = "area"
                        },
                        type = "nested-result"
                    },
                    {
                        delay = 0,
                        duration = 60,
                        ease_in_duration = 5,
                        ease_out_duration = 255,
                        effect = "screen-burn",
                        full_strength_max_distance = 400,
                        max_distance = 1600,
                        strength = 20,
                        type = "camera-effect"
                    },
                    {
                        audible_distance_modifier = 3,
                        max_distance = 1000,
                        play_on_target_position = false,
                        sound = {
                            aggregation = {
                                max_count = 1,
                                remove = true
                            },
                            game_controller_vibration_data = {
                                duration = 800,
                                low_frequency_vibration_intensity = 1,
                                play_for = "everything"
                            },
                            switch_vibration_data = {
                                filename = "__base__/sound/fight/nuclear-explosion.bnvib",
                                play_for = "everything"
                            },
                            variations = {
                                {
                                    filename = "__base__/sound/fight/nuclear-explosion-1.ogg",
                                    volume = 0.9
                                },
                                {
                                    filename = "__base__/sound/fight/nuclear-explosion-2.ogg",
                                    volume = 0.9
                                },
                                {
                                    filename = "__base__/sound/fight/nuclear-explosion-3.ogg",
                                    volume = 0.9
                                }
                            }
                        },
                        type = "play-sound"
                    },
                    {
                        audible_distance_modifier = 3,
                        max_distance = 1000,
                        play_on_target_position = false,
                        sound = {
                            aggregation = {
                                max_count = 1,
                                remove = true
                            },
                            variations = {
                                {
                                    filename = "__base__/sound/fight/nuclear-explosion-aftershock.ogg",
                                    volume = 0.4
                                }
                            }
                        },
                        type = "play-sound"
                    },
                    {
                        repeat_count = 1,
                        type = "invoke-tile-trigger"
                    },
                    {
                        action = {
                            action_delivery = {
                                projectile = "atomic-bomb-wave-spawns-cluster-nuke-explosion",
                                starting_speed = 0.35,
                                starting_speed_deviation = 0.075,
                                type = "projectile"
                            },
                            radius = 26,
                            repeat_count = 1000,
                            show_in_tooltip = false,
                            target_entities = false,
                            trigger_from_target = true,
                            type = "area"
                        },
                        type = "nested-result"
                    },
                    {
                        action = {
                            action_delivery = {
                                projectile = "atomic-bomb-wave-spawns-fire-smoke-explosion",
                                starting_speed = 1.325,
                                starting_speed_deviation = 0.075,
                                type = "projectile"
                            },
                            radius = 4,
                            repeat_count = 700,
                            show_in_tooltip = false,
                            target_entities = false,
                            trigger_from_target = true,
                            type = "area"
                        },
                        type = "nested-result"
                    },
                    {
                        action = {
                            action_delivery = {
                                projectile = "atomic-bomb-wave-spawns-nuke-shockwave-explosion",
                                starting_speed = 1.325,
                                starting_speed_deviation = 0.075,
                                type = "projectile"
                            },
                            radius = 8,
                            repeat_count = 1000,
                            show_in_tooltip = false,
                            target_entities = false,
                            trigger_from_target = true,
                            type = "area"
                        },
                        type = "nested-result"
                    },
                    {
                        action = {
                            action_delivery = {
                                projectile = "atomic-bomb-wave-spawns-nuclear-smoke",
                                starting_speed = 1.325,
                                starting_speed_deviation = 0.075,
                                type = "projectile"
                            },
                            radius = 26,
                            repeat_count = 300,
                            show_in_tooltip = false,
                            target_entities = false,
                            trigger_from_target = true,
                            type = "area"
                        },
                        type = "nested-result"
                    },
                    {
                        action = {
                            action_delivery = {
                                target_effects = {
                                    {
                                        entity_name = "nuclear-smouldering-smoke-source",
                                        tile_collision_mask = {
                                            layers = {["water_tile"] = true}
                                        },
                                        type = "create-entity"
                                    }
                                },
                                type = "instant"
                            },
                            radius = 8,
                            repeat_count = 10,
                            show_in_tooltip = false,
                            target_entities = false,
                            trigger_from_target = true,
                            type = "area"
                        },
                        type = "nested-result"
                    }
                },
                type = "instant"
            },
            type = "direct"
        }
    },
    animation = {
        filename = "__base__/graphics/entity/cliff-explosives/cliff-explosives.png",
        draw_as_glow = true,
        frame_count = 16,
        line_length = 8,
        animation_speed = 0.250,
        width = 52,
        height = 58,
        shift = util.by_pixel(0.5, -4.5),
        priority = "high",
        scale = 0.5
    },
    shadow = {
        filename = "__base__/graphics/entity/cliff-explosives/cliff-explosives-shadow.png",
        frame_count = 16,
        line_length = 8,
        animation_speed = 0.250,
        width = 74,
        height = 42,
        shift = util.by_pixel(-3.5, 4),
        priority = "high",
        draw_as_shadow = true,
        scale = 0.5
    },
})}

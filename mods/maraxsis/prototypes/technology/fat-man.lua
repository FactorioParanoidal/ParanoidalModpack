local sounds = require("__base__.prototypes.entity.sounds")

data:extend { {
    type = "recipe",
    name = "maraxsis-fat-man",
    categories = {"maraxsis-hydro-plant"},
    ingredients = {
        { type = "item", name = "artillery-shell",                  amount = 1 },
        { type = "item", name = "maraxsis-super-sealant-substance", amount = 1 },
        { type = "item", name = "atomic-bomb",                      amount = 1 },
    },
    results = {
        { type = "item", name = "maraxsis-fat-man", amount = 1 }
    },
    energy_required = 10,
    auto_recycle = true,
    enabled = false,
} }

data:extend { {
    type = "ammo",
    name = "maraxsis-fat-man",
    icon = "__maraxsis__/graphics/icons/fat-man.png",
    icon_size = 64,
    ammo_category = "artillery-shell",
    ammo_type = {
        category = "artillery-shell",
        target_type = "position",
        action = {
            type = "direct",
            action_delivery = {
                type = "artillery",
                projectile = "maraxsis-nuclear-artillery-projectile",
                starting_speed = 1,
                direction_deviation = 0,
                range_deviation = 0,
                source_effects = {
                    type = "create-explosion",
                    entity_name = "artillery-cannon-muzzle-flash"
                }
            }
        }
    },
    subgroup = "ammo",
    order = "d[explosive-cannon-shell]-d[artillery]",
    stack_size = 1
} }

data:extend { {
    type = "artillery-projectile",
    name = "maraxsis-nuclear-artillery-projectile",
    flags = { "not-on-map" },
    reveal_map = true,
    hidden = true,
    map_color = { r = 0.5, g = 1, b = 0.5 },
    picture = {
        filename = "__base__/graphics/entity/artillery-projectile/shell.png",
        draw_as_glow = true,
        width = 64,
        height = 64,
        scale = 0.5
    },
    shadow = {
        filename = "__base__/graphics/entity/artillery-projectile/shell-shadow.png",
        width = 64,
        height = 64,
        scale = 0.5
    },
    chart_picture = {
        filename = "__base__/graphics/entity/artillery-projectile/artillery-shoot-map-visualization.png",
        flags = { "icon" },
        frame_count = 1,
        width = 64,
        height = 64,
        priority = "high",
        scale = 0.25
    },
    action = {
        type = "direct",
        action_delivery = {
            type = "instant",
            target_effects = {
                {
                    type = "destroy-cliffs",
                    radius = 9,
                    explosion = "explosion"
                },
                {
                    type = "create-entity",
                    entity_name = "nuke-explosion"
                },
                {
                    type = "camera-effect",
                    effect = "screen-burn",
                    duration = 60,
                    ease_in_duration = 5,
                    ease_out_duration = 60,
                    delay = 0,
                    strength = 6,
                    full_strength_max_distance = 200,
                    max_distance = 800
                },
                {
                    type = "play-sound",
                    sound = sounds.nuclear_explosion(0.9),
                    play_on_target_position = false,
                    -- min_distance = 200,
                    max_distance = 1000,
                    -- volume_modifier = 1,
                    audible_distance_modifier = 3
                },
                {
                    type = "play-sound",
                    sound = sounds.nuclear_explosion_aftershock(0.4),
                    play_on_target_position = false,
                    -- min_distance = 200,
                    max_distance = 1000,
                    -- volume_modifier = 1,
                    audible_distance_modifier = 3
                },
                {
                    type = "damage",
                    damage = { amount = 400, type = "explosion" }
                },
                {
                    type = "create-entity",
                    entity_name = "huge-scorchmark",
                    offsets = { { 0, -0.5 } },
                    check_buildability = true
                },
                {
                    type = "invoke-tile-trigger",
                    repeat_count = 1
                },
                {
                    type = "destroy-decoratives",
                    include_soft_decoratives = true, -- soft decoratives are decoratives with grows_through_rail_path = true
                    include_decals = true,
                    invoke_decorative_trigger = true,
                    decoratives_with_trigger_only = false, -- if true, destroys only decoratives that have trigger_effect set
                    radius = 14                            -- large radius for demostrative purposes
                },
                {
                    type = "create-decorative",
                    decorative = "nuclear-ground-patch",
                    spawn_min_radius = 11.5,
                    spawn_max_radius = 12.5,
                    spawn_min = 30,
                    spawn_max = 40,
                    apply_projection = true,
                    spread_evenly = true
                },
                {
                    type = "nested-result",
                    action = {
                        type = "area",
                        target_entities = false,
                        trigger_from_target = true,
                        repeat_count = 1000,
                        radius = 7,
                        action_delivery = {
                            type = "projectile",
                            projectile = "atomic-bomb-ground-zero-projectile",
                            starting_speed = 0.6 * 0.8,
                            starting_speed_deviation = nuke_shockwave_starting_speed_deviation
                        }
                    }
                },
                {
                    type = "nested-result",
                    action = {
                        type = "area",
                        target_entities = false,
                        trigger_from_target = true,
                        repeat_count = 1000,
                        radius = 35,
                        action_delivery =
                        {
                            type = "projectile",
                            projectile = "atomic-bomb-wave",
                            starting_speed = 0.5 * 0.7,
                            starting_speed_deviation = nuke_shockwave_starting_speed_deviation
                        }
                    }
                },
                {
                    type = "nested-result",
                    action = {
                        type = "area",
                        show_in_tooltip = false,
                        target_entities = false,
                        trigger_from_target = true,
                        repeat_count = 1000,
                        radius = 26,
                        action_delivery =
                        {
                            type = "projectile",
                            projectile = "atomic-bomb-wave-spawns-cluster-nuke-explosion",
                            starting_speed = 0.5 * 0.7,
                            starting_speed_deviation = nuke_shockwave_starting_speed_deviation
                        }
                    }
                },
                {
                    type = "nested-result",
                    action = {
                        type = "area",
                        show_in_tooltip = false,
                        target_entities = false,
                        trigger_from_target = true,
                        repeat_count = 700,
                        radius = 4,
                        action_delivery = {
                            type = "projectile",
                            projectile = "atomic-bomb-wave-spawns-fire-smoke-explosion",
                            starting_speed = 0.5 * 0.65,
                            starting_speed_deviation = nuke_shockwave_starting_speed_deviation
                        }
                    }
                },
                {
                    type = "nested-result",
                    action = {
                        type = "area",
                        show_in_tooltip = false,
                        target_entities = false,
                        trigger_from_target = true,
                        repeat_count = 1000,
                        radius = 8,
                        action_delivery =
                        {
                            type = "projectile",
                            projectile = "atomic-bomb-wave-spawns-nuke-shockwave-explosion",
                            starting_speed = 0.5 * 0.65,
                            starting_speed_deviation = nuke_shockwave_starting_speed_deviation
                        }
                    }
                },
                {
                    type = "nested-result",
                    action = {
                        type = "area",
                        show_in_tooltip = false,
                        target_entities = false,
                        trigger_from_target = true,
                        repeat_count = 300,
                        radius = 26,
                        action_delivery =
                        {
                            type = "projectile",
                            projectile = "atomic-bomb-wave-spawns-nuclear-smoke",
                            starting_speed = 0.5 * 0.65,
                            starting_speed_deviation = nuke_shockwave_starting_speed_deviation
                        }
                    }
                },
                {
                    type = "nested-result",
                    action = {
                        type = "area",
                        show_in_tooltip = false,
                        target_entities = false,
                        trigger_from_target = true,
                        repeat_count = 10,
                        radius = 8,
                        action_delivery = {
                            type = "instant",
                            target_effects = {
                                {
                                    type = "create-entity",
                                    entity_name = "nuclear-smouldering-smoke-source",
                                    tile_collision_mask = { layers = { water_tile = true } }
                                }
                            }
                        }
                    }
                }
            }
        }
    },
    final_action = {
        type = "direct",
        action_delivery = {
            type = "instant",
            target_effects = {
                {
                    type = "create-entity",
                    entity_name = "medium-scorchmark-tintable",
                    check_buildability = true
                },
                {
                    type = "invoke-tile-trigger",
                    repeat_count = 1
                },
                {
                    type = "destroy-decoratives",
                    from_render_layer = "decorative",
                    to_render_layer = "object",
                    include_soft_decoratives = true, -- soft decoratives are decoratives with grows_through_rail_path = true
                    include_decals = false,
                    invoke_decorative_trigger = true,
                    decoratives_with_trigger_only = false, -- if true, destroys only decoratives that have trigger_effect set
                    radius = 3.5                           -- large radius for demostrative purposes
                }
            }
        }
    },
    height_from_ground = 280 / 64
} }

--- Copy the explosion effects over from the standard nuke.
local function copy_nuke_effects_from_rocket(projectile)
    local target_effects = projectile.action.action_delivery.target_effects
    local index = maraxsis.index_after_destroy_cliffs(target_effects)
    for _, effect in ipairs(data.raw.projectile["atomic-rocket"].action.action_delivery.target_effects) do
        if effect.type == "create-entity" and effect.entity_name:starts_with("nuke-effects-") then
            table.insert(target_effects, index, table.deepcopy(effect))
            index = index + 1
        end
    end
end

copy_nuke_effects_from_rocket(data.raw["artillery-projectile"]["maraxsis-nuclear-artillery-projectile"])

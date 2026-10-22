local constants = require('constants')

local lightgreen = {r = 0.56470588235294, g = 0.93333333333333, b = 0.56470588235294, a = 0.35}

-------------------------------------------------------------------------------
local effects;
if(settings.startup["nanobots-auto"].value) then 
    effects = {{
        type = 'create-entity',
        entity_name = 'nano-cloud-big-levelers',
        trigger_created_entity = false 
    }}
else
    effects = {{
        type = 'script',
        effect_id = 'nano-leveler'
    }}
end

local levelers = {
    type = 'ammo',
    name = 'ammo-nano-levelers',
    icon = '__nanobots-refined__/graphics/icons/nano-ammo-levelers.png',
    icon_size = 64,
    magazine_size = 10, --20
    subgroup = 'tool',
    order = 'c[automated-construction]-g[gun-nano-emitter]-d-levelers',
    stack_size = 100, --100
    ammo_category = 'nano-ammo',
    ammo_type = {
        category = 'nano-ammo',
        target_type = 'position',
        action = {
            type = 'direct',
            action_delivery = {
                type = 'instant',
                target_effects = effects
            }
        }
    }
}

-------------------------------------------------------------------------------
--cloud-big is for the gun, cloud-small is for the individual item.
local cloud_big_levelers = {
    type = 'smoke-with-trigger',
    name = 'nano-cloud-big-levelers',
    flags = {'not-on-map'},
    show_when_smoke_off = true,
    animation = constants.cloud_animation(4),
    affected_by_wind = false,
    cyclic = true,
    duration = 60 * 2,
    fade_away_duration = 60,
    spread_duration = 10,
    color = lightgreen,
    action_cooldown = 60,
    action = {
        type = 'direct',
        action_delivery = {
            type = 'instant',
            source_effects = {
                {
                    type = 'play-sound',
                    sound = {
                        filename = '__nanobots-refined__/sounds/robostep.ogg',
                        volume = 0.75
                    }
                }
            }
        }
    }
}
cloud_big_levelers.animation.scale = 4

-------------------------------------------------------------------------------
local cloud_small_termites = {
    type = 'smoke-with-trigger',
    name = 'nano-cloud-small-termites',
    flags = {'not-on-map'},
    show_when_smoke_off = true,
    animation = constants.cloud_animation(.4),
    affected_by_wind = false,
    cyclic = true,
    duration = 130,
    fade_away_duration = 20,
    spread_duration = 10,
    color = lightgreen,
    action_cooldown = 5,
    movement_slow_down_factor = 0, 
    action = {
        type = 'direct',
        action_delivery = {
            type = 'instant',
            target_effects = {
                {
                    type = 'nested-result',
                    action = {
                        type = 'area',
                        radius = .75,
                        force = 'not-same',
                        entity_flags = {'placeable-neutral'},
                        action_delivery = {
                            type = 'instant',
                            target_effects = {
                                {
                                    type = 'damage',
                                    damage = {amount = 2, type = 'poison'}
                                },
                                {   type = 'play-sound',
                                    play_on_target_position = true,
                                    sound = {
                                        filename = '__nanobots-refined__/sounds/sawing-wood.ogg',
                                        volume = 0.30,
                                        aggregation = {max_count = 1, remove = true, count_already_playing = true}
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

local projectile_termites = {
    type = 'projectile',
    name = 'nano-projectile-termites',
    flags = {'not-on-map'},
    acceleration = 0.005,
    direction_only = false,
    animation = constants.projectile_animation,
    action = nil,
    final_action = {
        type = 'direct',
        action_delivery = {
            type = 'instant',
            target_effects = {
                {
                    type = 'create-entity',
                    entity_name = 'nano-cloud-small-termites',
                    check_buildability = false
                },
                {
                    type = 'script',
                    effect_id = 'nano-auto'
                },
                constants.impact_splat
            }
        }
    }
}
-------------------------------------------------------------------------------
local cloud_lithotrophs = {
    type = 'smoke-with-trigger',
    name = 'nano-cloud-small-lithotrophs',
    flags = {'not-on-map'},
    show_when_smoke_off = true,
    animation = constants.cloud_animation(.4),
    affected_by_wind = false,
    cyclic = true,
    duration = 210,
    fade_away_duration = 20,
    spread_duration = 10,
    color = lightgreen,
    action_cooldown = 1,
    movement_slow_down_factor = 0, 
    action = {
        type = 'direct',
        action_delivery = {
            type = 'instant',
            target_effects = {
                {
                    type = 'nested-result',
                    action = {
                        type = 'area',
                        radius = .75,
                        force = 'not-same',
                        entity_flags = {'placeable-neutral'},
                        action_delivery = {
                            type = 'instant',
                            target_effects = {
                                {
                                    type = 'damage',
                                    damage = {amount = 10, type = 'acid'}
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

local projectile_lithotrophs = {
    type = 'projectile',
    name = 'nano-projectile-lithotrophs',
    flags = {'not-on-map'},
    acceleration = 0.005,
    direction_only = false,
    animation = constants.projectile_animation,
    action = nil,
    final_action = {
        type = 'direct',
        action_delivery = {
            type = 'instant',
            target_effects = {
                {
                    type = 'create-entity',
                    entity_name = 'nano-cloud-small-lithotrophs',
                    check_buildability = false
                },
                {
                    type = 'script',
                    effect_id = 'nano-auto'
                },
                {   type = 'play-sound',
                    play_on_target_position = true,
                    sound = {
                        variations = { { filename = '__base__/sound/burner-mining-drill-1.ogg' },
                                       { filename = '__base__/sound/burner-mining-drill-2.ogg' }},
                        allow_random_repeat = true,
                        volume = 0.15,
                        aggregation = {max_count = 4, remove = true, count_already_playing = true}
                    }
                },
                constants.impact_splat
            }
        }
    }
}
---------------------------------------------------------------------------------
local cloud_pavers = {
    type = 'smoke-with-trigger',
    name = 'nano-cloud-pavers',
    flags = {'not-on-map'},
    show_when_smoke_off = true,
    animation = constants.cloud_animation(.4),
    affected_by_wind = false,
    cyclic = true,
    duration = 60 * 2,
    fade_away_duration = 60,
    spread_duration = 10,
    color = lightgreen,
    action = nil
}

local projectile_pavers = {
    type = 'projectile',
    name = 'nano-projectile-pavers',
    flags = {'not-on-map'},
    acceleration = 0.005,
    direction_only = false,
    animation = constants.projectile_animation,
    final_action = {
        type = 'direct',
        action_delivery = {
            type = 'instant',
            target_effects = {
                {
                    type = 'create-entity',
                    entity_name = 'nano-cloud-pavers',
                    check_buildability = false
                },
                {
                    type = 'script',
                    effect_id = 'nano-pave'
                },
                constants.impact_splat
            }
        }
    }
}
-------------------------------------------------------------------------------
data:extend({
    levelers, 
    cloud_big_levelers, 
    cloud_small_termites, 
    projectile_termites, 
    cloud_lithotrophs, 
    projectile_lithotrophs,
    cloud_pavers,
    projectile_pavers
})



local constants = require('constants')

local red = {r = 1, g = 0, b = 0, a = 0.35}
local lightblue = {r = 0.67843137254902, g = 0.84705882352941, b = 0.90196078431373, a = 0.35}
local darkblue = {r = 0, g = 0, b = 0.54509803921569, a = 0.35}

-------------------------------------------------------------------------------
local effects;
if(settings.startup["nanobots-auto"].value) then 
    effects = {{
        type = 'create-entity',
        entity_name = 'nano-cloud-small-constructors',
        trigger_created_entity = false 
    }}
else
    effects = {{
        type = 'script',
        effect_id = 'nano-constructor'
    }}
end

local constructors = {
    type = 'ammo',
    name = 'ammo-nano-constructors',
    icon = '__nanobots-refined__/graphics/icons/nano-ammo-constructors.png',
    icon_size = 64,
    magazine_size = 10,
    subgroup = 'tool',
    order = 'c[automated-construction]-g[gun-nano-emitter]-a-constructors',
    stack_size = 100,
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
local projectile_constructors = {
    type = 'projectile',
    name = 'nano-projectile-constructors',
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
                    entity_name = 'nano-cloud-small-constructors',
                    check_buildability = false
                },
                {
                    type = 'script',
                    effect_id = 'nano-build'
                },
                constants.impact_splat
            }
        }
    }
}

local projectile_upgraders = {
    type = 'projectile',
    name = 'nano-projectile-upgraders',
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
                    entity_name = 'nano-cloud-small-constructors',
                    check_buildability = false
                },
                {
                    type = 'script',
                    effect_id = 'nano-returners'
                },
                {
                    type = 'script',
                    effect_id = 'nano-upgrade'
                },
                constants.impact_splat
            }
        }
    }
}

local cloud_big_constructors = {
    type = 'smoke-with-trigger',
    name = 'nano-cloud-big-constructors',
    flags = {'not-on-map'},
    show_when_smoke_off = true,
    animation = constants.cloud_animation(4),
    affected_by_wind = false,
    cyclic = true,
    duration = 60 * 2,
    fade_away_duration = 60,
    spread_duration = 10,
    color = lightblue,
    action = nil
}

local cloud_small_constructors = {
    type = 'smoke-with-trigger',
    name = 'nano-cloud-small-constructors',
    flags = {'not-on-map'},
    show_when_smoke_off = true,
    animation = constants.cloud_animation(.4),
    affected_by_wind = false,
    cyclic = true,
    duration = 60 * 2,
    fade_away_duration = 60,
    spread_duration = 10,
    color = {r = 0.67843137254902, g = 0.84705882352941, b = 0.90196078431373, a = 0.35},
    action = nil
}

local projectile_deconstructors = {
    type = 'projectile',
    name = 'nano-projectile-deconstructors',
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
                    entity_name = 'nano-cloud-small-deconstructors',
                    check_buildability = false
                },
                {
                    type = 'script',
                    effect_id = 'nano-returners'
                },
                {
                    type = 'script',
                    effect_id = 'nano-deconstruct'
                },
                constants.impact_splat
            }
        }
    }
}

local cloud_small_deconstructors = {
    type = 'smoke-with-trigger',
    name = 'nano-cloud-small-deconstructors',
    flags = {'not-on-map'},
    show_when_smoke_off = true,
    animation = constants.cloud_animation(.4),
    affected_by_wind = false,
    cyclic = true,
    duration = 60 * 2,
    fade_away_duration = 60,
    spread_duration = 10,
    color = red,
    action_cooldown = 120,
    action = {
        type = 'direct',
        action_delivery = {
            type = 'instant',
            target_effects = {
                {
                    type = 'play-sound',
                    play_on_target_position = true,
                    sound = {
                        filename = '__core__/sound/deconstruct-small.ogg',
                        volume = 0.8,
                        aggregation = {max_count = 3, remove = true, count_already_playing = true}
                    }
                }
            }
        }
    }
}

local projectile_fillers = {
    type = 'projectile',
    name = 'nano-projectile-fillers',
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
                    entity_name = 'nano-cloud-small-constructors',
                    check_buildability = false
                },
                constants.impact_splat
            }
        }
    }
}

local projectile_emptyers = {
    type = 'projectile',
    name = 'nano-projectile-emptyers',
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
                    entity_name = 'nano-cloud-small-deconstructors',
                    check_buildability = false
                },
                {
                    type = 'script',
                    effect_id = 'nano-returners'
                },
                constants.impact_splat
            }
        }
    }
}

local nano_return = {
    type = 'projectile',
    name = 'nano-projectile-return',
    flags = {'not-on-map'},
    acceleration = 0.005,
    direction_only = false,
    action = nil,
    final_action = nil,
    animation = constants.projectile_animation
}

-------------------------------------------------------------------------------
--Projectile for the healers, shoots from player to target,
--release healing cloud.
local projectile_repair = {
    type = 'projectile',
    name = 'nano-projectile-repair',
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
                    entity_name = 'nano-cloud-small-repair',
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

--Healing cloud.
local cloud_small_repair = {
    type = 'smoke-with-trigger',
    name = 'nano-cloud-small-repair',
    flags = {'not-on-map'},
    show_when_smoke_off = true,
    animation = constants.cloud_animation(.4),
    affected_by_wind = false,
    cyclic = true,
    duration = 25,
    fade_away_duration = 5,
    fade_in_duration = 0,
    spread_duration = 15,
    color = darkblue,
    action_cooldown = 1,
    movement_slow_down_factor = 0, 
    action = {
        type = 'direct',
        action_delivery = {
            type = 'instant',
            target_effects = {
                type = 'nested-result',
                action = {
                    {
                        type = 'area',
                        radius = 0.75,
                        force = 'ally',
                        entity_flags = {'player-creation'},
                        action_delivery = {
                            type = 'instant',
                            target_effects = {
                                {
                                    type = 'damage',
                                    damage = {amount = -3, type = 'physical'}
                                },
                                {
                                    type = 'play-sound',
                                    play_on_target_position = true,
                                    sound = {
                                        filename = '__core__/sound/manual-repair-advanced-1.ogg',
                                        volume = .55,
                                        aggregation = {max_count = 5, remove = true, count_already_playing = true}
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

local projectile_cliff_bomb = {
    type = 'projectile',
    name = 'nano-projectile-cliff-bomb',
    flags = {'not-on-map'},
    acceleration = 0.005,
    direction_only = false,
    animation = constants.projectile_animation,
    action = {
        type = 'direct',
        action_delivery = {
            type = 'instant',
            target_effects = {
                --copied straight from cliff explosives :)
                {
                  type = "create-entity",
                  entity_name = "ground-explosion"
                },
                {
                  type = "create-entity",
                  entity_name = "small-scorchmark-tintable",
                  check_buildability = true
                },
                {
                  type = "destroy-cliffs",
                  radius = 1.5,
                  explosion_at_trigger = "explosion"
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
                  radius = 2 -- large radius for demostrative purposes
                }
            }
        }
    }
}
-------------------------------------------------------------------------------
data:extend {
    constructors,
    projectile_constructors,
    cloud_big_constructors,
    cloud_small_constructors,
    projectile_deconstructors,
    cloud_small_deconstructors,
    projectile_upgraders,
    projectile_fillers,
    projectile_emptyers,
    projectile_repair,
    cloud_small_repair,
    projectile_cliff_bomb,
    nano_return
}

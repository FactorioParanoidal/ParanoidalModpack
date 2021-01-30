local constants = require('constants')

local red = {r = 1, g = 0, b = 0, a = 0.35}
local lightblue = {r = 0.67843137254902, g = 0.84705882352941, b = 0.90196078431373, a = 0.35}
local darkblue = {r = 0, g = 0, b = 0.54509803921569, a = 0.35}

local recipe = {
    type = 'recipe',
    name = 'ammo-nano-constructors',
    enabled = false,
    energy_required = 1,
    ingredients = {
        {'iron-stick', 1},
        {'repair-pack', 1}
    },
    results = {
        {type = 'item', name = 'ammo-nano-constructors', amount = 1}
    }
}

-------------------------------------------------------------------------------
local constructors = {
    type = 'ammo',
    name = 'ammo-nano-constructors',
    icon = '__Nanobots__/graphics/icons/nano-ammo-constructors.png',
    icon_size = 32,
    magazine_size = 10,
    subgroup = 'tool',
    order = 'c[automated-construction]-g[gun-nano-emitter]-a-constructors',
    stack_size = 100,
    ammo_type = {
        category = 'nano-ammo',
        target_type = 'position',
        action = {
            type = 'direct',
            action_delivery = {
                type = 'instant',
                target_effects = {
                    {
                        type = 'create-entity',
                        entity_name = 'nano-cloud-big-constructors',
                        trigger_created_entity = false
                    }
                }
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
                }
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
                }
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
                        volume = 0.5,
                        aggregation = {max_count = 3, remove = true, count_already_playing = true}
                    },
                }
            }
        }
    }
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
                }
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
    duration = 200,
    fade_away_duration = 2 * 60,
    spread_duration = 10,
    color = darkblue,
    action_cooldown = 1,
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
                                    damage = {amount = -1, type = 'physical'}
                                },
                                {
                                    type = 'play-sound',
                                    play_on_target_position = true,
                                    sound = {
                                        filename = '__core__/sound/manual-repair-advanced-1.ogg',
                                        volume = 0.15,
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
data:extend {
    recipe,
    constructors,
    projectile_constructors,
    cloud_big_constructors,
    cloud_small_constructors,
    projectile_repair,
    cloud_small_repair,
    projectile_deconstructors,
    cloud_small_deconstructors,
    nano_return
}

local effects = data.raw.technology['nanobots'].effects
effects[#effects + 1] = {type = 'unlock-recipe', recipe = 'ammo-nano-constructors'}

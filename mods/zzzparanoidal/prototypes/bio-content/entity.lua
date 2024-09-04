-- ###############################################################################################
-- set local
local biofarmpipepictures = {
    north = {
        filename = "__core__/graphics/empty.png",
        priority = "low",
        width = 1,
        height = 1
    },
    east = {
        filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/biofarm_pipes/bio_farm-pipe-E.png",
        priority = "extra-high",
        width = 20,
        height = 38,
        shift = util.by_pixel(-25, 1),
        hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/biofarm_pipes/hr_bio_farm-pipe-E.png",
            priority = "extra-high",
            width = 42,
            height = 76,
            shift = util.by_pixel(-24.5, 1),
            scale = 0.5
        }
    },
    south = {
        filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/biofarm_pipes/bio_farm-pipe-S.png",
        priority = "extra-high",
        width = 44,
        height = 31,
        shift = util.by_pixel(0, -31.5),
        hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/biofarm_pipes/hr_bio_farm-pipe-S.png",
            priority = "extra-high",
            width = 88,
            height = 61,
            shift = util.by_pixel(0, -31.25),
            scale = 0.5
        }
    },
    west = {
        filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/biofarm_pipes/bio_farm-pipe-W.png",
        priority = "extra-high",
        width = 19,
        height = 37,
        shift = util.by_pixel(25.5, 1.5),
        hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/biofarm_pipes/hr_bio_farm-pipe-W.png",
            priority = "extra-high",
            width = 39,
            height = 73,
            shift = util.by_pixel(25.75, 1.25),
            scale = 0.5
        }
    }
}

local assembler2pipepicturesBioreactor = {
    north = {
        filename = "__Bio_Industries__/graphics/icons/empty.png",
        priority = "extra-high",
        width = 1,
        height = 1,
        shift = util.by_pixel(2.5, 14),
        hr_version = {
            filename = "__Bio_Industries__/graphics/icons/empty.png",
            priority = "extra-high",
            width = 1,
            height = 1,
            shift = util.by_pixel(2.25, 13.5),
            scale = 0.5
        }
    },
    east = {
        filename = "__base__/graphics/entity/assembling-machine-2/assembling-machine-2-pipe-E.png",
        priority = "extra-high",
        width = 20,
        height = 38,
        shift = util.by_pixel(-25, 1),
        hr_version = {
            filename = "__base__/graphics/entity/assembling-machine-2/hr-assembling-machine-2-pipe-E.png",
            priority = "extra-high",
            width = 42,
            height = 76,
            shift = util.by_pixel(-24.5, 1),
            scale = 0.5
        }
    },
    south = {
        filename = "__base__/graphics/entity/assembling-machine-2/assembling-machine-2-pipe-S.png",
        priority = "extra-high",
        width = 44,
        height = 31,
        shift = util.by_pixel(0, -31.5),
        hr_version = {
            filename = "__base__/graphics/entity/assembling-machine-2/hr-assembling-machine-2-pipe-S.png",
            priority = "extra-high",
            width = 88,
            height = 61,
            shift = util.by_pixel(0, -31.25),
            scale = 0.5
        }
    },
    west = {
        filename = "__base__/graphics/entity/assembling-machine-2/assembling-machine-2-pipe-W.png",
        priority = "extra-high",
        width = 19,
        height = 37,
        shift = util.by_pixel(25.5, 1.5),
        hr_version = {
            filename = "__base__/graphics/entity/assembling-machine-2/hr-assembling-machine-2-pipe-W.png",
            priority = "extra-high",
            width = 39,
            height = 73,
            shift = util.by_pixel(25.75, 1.25),
            scale = 0.5
        }
    }
}

data:extend({ -- ###############################################################################################
-- Greenhouse MK2
{
    type = "assembling-machine",
    name = "bi-bio-greenhouse-2",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/greenhouse-2.png",
    icon_size = 64,
    icon_mipmaps = 4,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {
        hardness = 0.2,
        mining_time = 0.25,
        result = "bi-bio-greenhouse-2"
    },
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    max_health = 350,
    corpse = "medium-remnants",
    dying_explosion = "medium-explosion",
    crafting_categories = {"biofarm-mod-greenhouse", "biofarm-mod-greenhouse-2"},
    crafting_speed = 1.5,
    energy_source = {
        type = "electric",
        usage_priority = "primary-input",
        drain = "15kW",
        emissions_per_minute = -12
    },
    energy_usage = "100kW",
    ingredient_count = 3,
    resistances = {{
        type = "fire",
        percent = 70
    }},
    fluid_boxes = {{
        production_type = "input",
        pipe_picture = {
            north = {
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/pipe/assembling-machine-3-pipe-N.png",
                priority = "extra-high",
                width = 35,
                height = 18,
                shift = util.by_pixel(2.5, 14),
                hr_version = {
                    filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/pipe/hr-assembling-machine-3-pipe-N-exp.png",
                    priority = "extra-high",
                    width = 171,
                    height = 152,
                    shift = util.by_pixel(2.25, 13.5),
                    scale = 0.5
                }
            },
            east = {
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/pipe/assembling-machine-3-pipe-E.png",
                priority = "extra-high",
                width = 20,
                height = 38,
                shift = util.by_pixel(-25, 1),
                hr_version = {
                    filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/pipe/hr-assembling-machine-3-pipe-E.png",
                    priority = "extra-high",
                    width = 42,
                    height = 76,
                    shift = util.by_pixel(-24.5, 1),
                    scale = 0.5
                }
            },
            south = {
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/pipe/assembling-machine-3-pipe-S.png",
                priority = "extra-high",
                width = 44,
                height = 31,
                shift = util.by_pixel(0, -31.5),
                hr_version = {
                    filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/pipe/hr-assembling-machine-3-pipe-S.png",
                    priority = "extra-high",
                    width = 88,
                    height = 61,
                    shift = util.by_pixel(0, -31.25),
                    scale = 0.5
                }
            },
            west = {
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/pipe/assembling-machine-3-pipe-W.png",
                priority = "extra-high",
                width = 19,
                height = 37,
                shift = util.by_pixel(25.5, 1.5),
                hr_version = {
                    filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/pipe/hr-assembling-machine-3-pipe-W.png",
                    priority = "extra-high",
                    width = 39,
                    height = 73,
                    shift = util.by_pixel(25.75, 1.25),
                    scale = 0.5
                }
            }
        },
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{
            type = "input",
            position = {0, -2}
        }}
    }},
    module_specification = {
        module_slots = 2
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    animation = {
        layers = {{
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/bio_greenhouse-2.png",
            width = 96,
            height = 128,
            frame_count = 1,
            line_length = 1,
            repeat_count = 10,
            animation_speed = 0.05,
            scale = 1,
            shift = {0, -0.5},
            hr_version = {
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/hr_bio_greenhouse-2.png",
                width = 192,
                height = 256,
                frame_count = 1,
                line_length = 1,
                repeat_count = 10,
                animation_speed = 0.05,
                scale = 0.5,
                shift = {0, -0.5}
            }
        }, {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/bio_greenhouse_shadow.png",
            width = 128,
            height = 64,
            frame_count = 1,
            line_length = 1,
            repeat_count = 10,
            animation_speed = 0.05,
            scale = 1,
            shift = {0.5, 0.5},
            draw_as_shadow = true,
            hr_version = {
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/hr_bio_greenhouse_shadow.png",
                width = 256,
                height = 128,
                frame_count = 1,
                line_length = 1,
                repeat_count = 10,
                animation_speed = 0.05,
                scale = 0.5,
                shift = {0.5, 0.5},
                draw_as_shadow = true
            }
        }}
    },
    working_visualisations = {{
        draw_as_light = true,
        effect = "flicker",
        apply_recipe_tint = "primary",
        animation = {
            layers = {{
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/bio_greenhouse_light_anim-test.png",
                width = 96,
                height = 128,
                frame_count = 10,
                line_length = 10,
                repeat_count = 1,
                animation_speed = 0.08,
                scale = 1,
                shift = {0, -0.5},
                hr_version = {
                    filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/hr_bio_greenhouse_light_anim-test.png",
                    width = 192,
                    height = 256,
                    frame_count = 10,
                    line_length = 10,
                    repeat_count = 1,
                    animation_speed = 0.08,
                    scale = 0.5,
                    shift = {0, -0.5}
                }
            }}
        }
    }},
    open_sound = {
        filename = "__base__/sound/machine-open.ogg",
        volume = 0.85
    },
    close_sound = {
        filename = "__base__/sound/machine-close.ogg",
        volume = 0.75
    },
    vehicle_impact_sound = {{
        filename = "__base__/sound/car-metal-impact-2.ogg",
        volume = 0.65
    }, {
        filename = "__base__/sound/car-metal-impact-3.ogg",
        volume = 0.65
    }, {
        filename = "__base__/sound/car-metal-impact-4.ogg",
        volume = 0.65
    }, {
        filename = "__base__/sound/car-metal-impact-5.ogg",
        volume = 0.65
    }, {
        filename = "__base__/sound/car-metal-impact-6.ogg",
        volume = 0.65
    }}
}, -- Greenhouse MK3
{
    type = "assembling-machine",
    name = "bi-bio-greenhouse-3",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/greenhouse-3.png",
    icon_size = 64,
    icon_mipmaps = 4,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {
        hardness = 0.2,
        mining_time = 0.25,
        result = "bi-bio-greenhouse-3"
    },
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    max_health = 450,
    corpse = "medium-remnants",
    dying_explosion = "medium-explosion",
    crafting_categories = {"biofarm-mod-greenhouse", "biofarm-mod-greenhouse-2", "biofarm-mod-greenhouse-3"},
    crafting_speed = 2,
    energy_source = {
        type = "electric",
        usage_priority = "primary-input",
        drain = "15kW",
        emissions_per_minute = -18
    },
    energy_usage = "150kW",
    ingredient_count = 3,
    resistances = {{
        type = "fire",
        percent = 70
    }},
    fluid_boxes = {{
        production_type = "input",
        pipe_picture = {
            north = {
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/pipe/assembling-machine-3-pipe-N.png",
                priority = "extra-high",
                width = 35,
                height = 18,
                shift = util.by_pixel(2.5, 14),
                hr_version = {
                    filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/pipe/hr-assembling-machine-3-pipe-N-exp.png",
                    priority = "extra-high",
                    width = 171,
                    height = 152,
                    shift = util.by_pixel(2.25, 13.5),
                    scale = 0.5
                }
            },
            east = {
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/pipe/assembling-machine-3-pipe-E.png",
                priority = "extra-high",
                width = 20,
                height = 38,
                shift = util.by_pixel(-25, 1),
                hr_version = {
                    filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/pipe/hr-assembling-machine-3-pipe-E.png",
                    priority = "extra-high",
                    width = 42,
                    height = 76,
                    shift = util.by_pixel(-24.5, 1),
                    scale = 0.5
                }
            },
            south = {
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/pipe/assembling-machine-3-pipe-S.png",
                priority = "extra-high",
                width = 44,
                height = 31,
                shift = util.by_pixel(0, -31.5),
                hr_version = {
                    filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/pipe/hr-assembling-machine-3-pipe-S.png",
                    priority = "extra-high",
                    width = 88,
                    height = 61,
                    shift = util.by_pixel(0, -31.25),
                    scale = 0.5
                }
            },
            west = {
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/pipe/assembling-machine-3-pipe-W.png",
                priority = "extra-high",
                width = 19,
                height = 37,
                shift = util.by_pixel(25.5, 1.5),
                hr_version = {
                    filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/pipe/hr-assembling-machine-3-pipe-W.png",
                    priority = "extra-high",
                    width = 39,
                    height = 73,
                    shift = util.by_pixel(25.75, 1.25),
                    scale = 0.5
                }
            }
        },
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{
            type = "input",
            position = {0, -2}
        }}
    }},
    module_specification = {
        module_slots = 3
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    animation = {
        layers = {{
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/bio_greenhouse-3.png",
            width = 96,
            height = 128,
            frame_count = 1,
            line_length = 1,
            repeat_count = 10,
            animation_speed = 0.05,
            scale = 1,
            shift = {0, -0.5},
            hr_version = {
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/hr_bio_greenhouse-3.png",
                width = 192,
                height = 256,
                frame_count = 1,
                line_length = 1,
                repeat_count = 10,
                animation_speed = 0.05,
                scale = 0.5,
                shift = {0, -0.5}
            }
        }, {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/bio_greenhouse_shadow.png",
            width = 128,
            height = 64,
            frame_count = 1,
            line_length = 1,
            repeat_count = 10,
            animation_speed = 0.05,
            scale = 1,
            shift = {0.5, 0.5},
            draw_as_shadow = true,
            hr_version = {
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/hr_bio_greenhouse_shadow.png",
                width = 256,
                height = 128,
                frame_count = 1,
                line_length = 1,
                repeat_count = 10,
                animation_speed = 0.05,
                scale = 0.5,
                shift = {0.5, 0.5},
                draw_as_shadow = true
            }
        }}
    },
    working_visualisations = {{
        draw_as_light = true,
        effect = "flicker",
        apply_recipe_tint = "primary",
        animation = {
            layers = {{
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/bio_greenhouse_light_anim-test.png",
                width = 96,
                height = 128,
                frame_count = 10,
                line_length = 10,
                repeat_count = 1,
                animation_speed = 0.08,
                scale = 1,
                shift = {0, -0.5},
                hr_version = {
                    filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_greenhouse/hr_bio_greenhouse_light_anim-test.png",
                    width = 192,
                    height = 256,
                    frame_count = 10,
                    line_length = 10,
                    repeat_count = 1,
                    animation_speed = 0.08,
                    scale = 0.5,
                    shift = {0, -0.5}
                }
            }}
        }
    }},
    open_sound = {
        filename = "__base__/sound/machine-open.ogg",
        volume = 0.85
    },
    close_sound = {
        filename = "__base__/sound/machine-close.ogg",
        volume = 0.75
    },
    vehicle_impact_sound = {{
        filename = "__base__/sound/car-metal-impact-2.ogg",
        volume = 0.65
    }, {
        filename = "__base__/sound/car-metal-impact-3.ogg",
        volume = 0.65
    }, {
        filename = "__base__/sound/car-metal-impact-4.ogg",
        volume = 0.65
    }, {
        filename = "__base__/sound/car-metal-impact-5.ogg",
        volume = 0.65
    }, {
        filename = "__base__/sound/car-metal-impact-6.ogg",
        volume = 0.65
    }}
}, -- ###############################################################################################
-- Bio Farm MK2
{
    type = "assembling-machine",
    name = "bi-bio-farm-2",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/biofarm-2.png",
    icon_size = 64,
    icon_mipmaps = 4,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {
        hardness = 0.2,
        mining_time = 0.5,
        result = "bi-bio-farm-2"
    },
    max_health = 350,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    resistances = {{
        type = "fire",
        percent = 70
    }},
    fluid_boxes = {
        {
            production_type = "input",
            pipe_picture = biofarmpipepictures,
            pipe_covers = pipecoverspictures(),
            base_area = 1,
            base_level = -1,
            pipe_connections = {{
                type = "input",
                position = {-1, -5}
            }}
        },
        {
            production_type = "input",
            pipe_picture = biofarmpipepictures,
            pipe_covers = pipecoverspictures(),
            base_area = 1,
            base_level = -1,
            pipe_connections = {{
                type = "input",
                position = {1, -5}
            }}
        },
        off_when_no_fluid_recipe = true
    },
    collision_box = {{-4.2, -4.2}, {4.2, 4.2}},
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
    scale_entity_info_icon = true,
    animation = {
        layers = {{
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/bio_farm-2.png",
            priority = "high",
            width = 304,
            height = 400,
            shift = {0, -1.5},
            scale = 1,
            hr_version = {
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/hr_bio_farm-2.png",
                priority = "high",
                width = 608,
                height = 800,
                shift = {0, -1.5},
                scale = 0.5
            }
        }, {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/bio_farm_shadow.png",
            priority = "high",
            width = 400,
            height = 400,
            shift = {1.5, -1.5},
            scale = 1,
            draw_as_shadow = true,
            hr_version = {
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/hr_bio_farm_shadow.png",
                priority = "high",
                width = 800,
                height = 800,
                shift = {1.5, -1.5},
                scale = 0.5,
                draw_as_shadow = true
            }
        }}
    },
    working_visualisations = {{
        draw_as_light = true,
        effect = "flicker",
        apply_recipe_tint = "primary",
        animation = {
            layers = {{
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/bio_farm_light.png",
                width = 400,
                height = 400,
                scale = 1,
                shift = {0, -1.5},
                blend_mode = "additive",
                hr_version = {
                    filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/hr_bio_farm_light.png",
                    width = 800,
                    height = 800,
                    scale = 0.5,
                    shift = {0, -1.5},
                    blend_mode = "additive"
                }
            }}
        }
    }},
    crafting_categories = {"biofarm-mod-farm", "biofarm-mod-farm-2"},
    crafting_speed = 1.5,
    energy_source = {
        type = "electric",
        usage_priority = "primary-input",
        drain = "50kW",
        emissions_per_minute = -18
    },
    energy_usage = "200kW",
    ingredient_count = 3,
    open_sound = {
        filename = "__base__/sound/machine-open.ogg",
        volume = 0.85
    },
    close_sound = {
        filename = "__base__/sound/machine-close.ogg",
        volume = 0.75
    },
    vehicle_impact_sound = {{
        filename = "__base__/sound/car-wood-impact.ogg",
        volume = 0.65
    }, {
        filename = "__base__/sound/car-wood-impact-02.ogg",
        volume = 0.65
    }, {
        filename = "__base__/sound/car-wood-impact-03.ogg",
        volume = 0.65
    }, {
        filename = "__base__/sound/car-wood-impact-04.ogg",
        volume = 0.65
    }, {
        filename = "__base__/sound/car-wood-impact-05.ogg",
        volume = 0.65
    }},
    module_specification = {
        module_slots = 2
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"}
}, -- ###############################################################################################
-- Bio Farm MK3
{
    type = "assembling-machine",
    name = "bi-bio-farm-3",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/biofarm-3.png",
    icon_size = 64,
    icon_mipmaps = 4,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {
        hardness = 0.2,
        mining_time = 0.5,
        result = "bi-bio-farm-3"
    },
    max_health = 450,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    resistances = {{
        type = "fire",
        percent = 70
    }},
    fluid_boxes = {
        {
            production_type = "input",
            pipe_picture = biofarmpipepictures,
            pipe_covers = pipecoverspictures(),
            base_area = 1,
            base_level = -1,
            pipe_connections = {{
                type = "input",
                position = {-1, -5}
            }}
        },
        {
            production_type = "input",
            pipe_picture = biofarmpipepictures,
            pipe_covers = pipecoverspictures(),
            base_area = 1,
            base_level = -1,
            pipe_connections = {{
                type = "input",
                position = {1, -5}
            }}
        },
        off_when_no_fluid_recipe = true
    },
    collision_box = {{-4.2, -4.2}, {4.2, 4.2}},
    selection_box = {{-4.5, -4.5}, {4.5, 4.5}},
    scale_entity_info_icon = true,
    animation = {
        layers = {{
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/bio_farm-3.png",
            priority = "high",
            width = 304,
            height = 400,
            shift = {0, -1.5},
            scale = 1,
            hr_version = {
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/hr_bio_farm-3.png",
                priority = "high",
                width = 608,
                height = 800,
                shift = {0, -1.5},
                scale = 0.5
            }
        }, {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/bio_farm_shadow.png",
            priority = "high",
            width = 400,
            height = 400,
            shift = {1.5, -1.5},
            scale = 1,
            draw_as_shadow = true,
            hr_version = {
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/hr_bio_farm_shadow.png",
                priority = "high",
                width = 800,
                height = 800,
                shift = {1.5, -1.5},
                scale = 0.5,
                draw_as_shadow = true
            }
        }}
    },
    working_visualisations = {{
        draw_as_light = true,
        effect = "flicker",
        apply_recipe_tint = "primary",
        animation = {
            layers = {{
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/bio_farm_light.png",
                width = 400,
                height = 400,
                scale = 1,
                shift = {0, -1.5},
                blend_mode = "additive",
                hr_version = {
                    filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/biofarm/hr_bio_farm_light.png",
                    width = 800,
                    height = 800,
                    scale = 0.5,
                    shift = {0, -1.5},
                    blend_mode = "additive"
                }
            }}
        }
    }},
    crafting_categories = {"biofarm-mod-farm", "biofarm-mod-farm-2", "biofarm-mod-farm-3"},
    crafting_speed = 2.0,
    energy_source = {
        type = "electric",
        usage_priority = "primary-input",
        drain = "50kW",
        emissions_per_minute = -27
    },
    energy_usage = "300kW",
    ingredient_count = 3,
    open_sound = {
        filename = "__base__/sound/machine-open.ogg",
        volume = 0.85
    },
    close_sound = {
        filename = "__base__/sound/machine-close.ogg",
        volume = 0.75
    },
    vehicle_impact_sound = {{
        filename = "__base__/sound/car-wood-impact.ogg",
        volume = 0.65
    }, {
        filename = "__base__/sound/car-wood-impact-02.ogg",
        volume = 0.65
    }, {
        filename = "__base__/sound/car-wood-impact-03.ogg",
        volume = 0.65
    }, {
        filename = "__base__/sound/car-wood-impact-04.ogg",
        volume = 0.65
    }, {
        filename = "__base__/sound/car-wood-impact-05.ogg",
        volume = 0.65
    }},
    module_specification = {
        module_slots = 3
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"}
}, -- ###############################################################################################
-- BIOREACTOR MK2
{
    type = "assembling-machine",
    name = "bi-bio-reactor-2",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/bioreactor-2.png",
    icon_size = 64,
    icon_mipmaps = 4,
    se_allow_in_space = true,
    flags = {"placeable-neutral", "player-creation"},
    minable = {
        hardness = 0.2,
        mining_time = 0.5,
        result = "bi-bio-reactor-2"
    },
    max_health = 150,
    corpse = "big-remnants",
    fluid_boxes = {
        {
            production_type = "input",
            pipe_picture = assembler2pipepicturesBioreactor,
            pipe_covers = pipecoverspictures(),
            base_area = 10,
            base_level = -1,
            pipe_connections = {{
                type = "input",
                position = {0, -2}
            }},
            render_layer = "higher-object-under"
        },
        {
            production_type = "input",
            pipe_picture = assembler2pipepicturesBioreactor,
            pipe_covers = pipecoverspictures(),
            base_area = 10,
            base_level = -1,
            pipe_connections = {{
                type = "input",
                position = {2, 0}
            }},
            render_layer = "higher-object-under"
        },
        {
            production_type = "input",
            pipe_picture = assembler2pipepicturesBioreactor,
            pipe_covers = pipecoverspictures(),
            base_area = 10,
            base_level = -1,
            pipe_connections = {{
                type = "input",
                position = {0, 2}
            }},
            render_layer = "higher-object-under"
        },
        {
            production_type = "output",
            pipe_picture = assembler2pipepicturesBioreactor,
            pipe_covers = pipecoverspictures(),
            base_area = 10,
            base_level = 1,
            pipe_connections = {{
                type = "output",
                position = {-2, -1}
            }},
            render_layer = "higher-object-under"
        },
        {
            production_type = "output",
            pipe_picture = assembler2pipepicturesBioreactor,
            pipe_covers = pipecoverspictures(),
            base_area = 10,
            base_level = 1,
            pipe_connections = {{
                type = "output",
                position = {-2, 1}
            }},
            render_layer = "higher-object-under"
        },
        off_when_no_fluid_recipe = true
    },
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    animation = {
        layers = {{
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_reactor/bioreactor_idle-2.png",
            priority = "high",
            width = 91,
            height = 128,
            frame_count = 1,
            line_length = 1,
            repeat_count = 18,
            animation_speed = 0.2,
            scale = 1,
            shift = {0, -0.5},
            hr_version = {
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_reactor/hr_bioreactor_idle-2.png",
                priority = "high",
                width = 182,
                height = 256,
                frame_count = 1,
                line_length = 1,
                repeat_count = 18,
                animation_speed = 0.2,
                scale = 0.5,
                shift = {0, -0.5}
            }

        }, {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_reactor/bioreactor_shadow.png",
            priority = "low",
            width = 135,
            height = 128,
            frame_count = 1,
            line_length = 1,
            repeat_count = 18,
            animation_speed = 0.2,
            scale = 1,
            shift = {0.5, -0.5},
            draw_as_shadow = true,
            hr_version = {
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_reactor/hr_bioreactor_shadow.png",
                priority = "low",
                width = 270,
                height = 256,
                frame_count = 1,
                line_length = 1,
                repeat_count = 18,
                animation_speed = 0.2,
                scale = 0.5,
                shift = {0.5, -0.5},
                draw_as_shadow = true
            }
        }}
    },
    working_visualisations = {{
        effect = "none",
        render_layer = "object",
        animation = {
            layers = {{
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_reactor/bioreactor_anim-2.png",
                priority = "high",
                width = 91,
                height = 128,
                frame_count = 18,
                line_length = 6,
                repeat_count = 1,
                animation_speed = 0.2,
                scale = 1,
                shift = {0, -0.5},
                hr_version = {
                    filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_reactor/hr_bioreactor_anim-2.png",
                    priority = "high",
                    width = 182,
                    height = 256,
                    frame_count = 18,
                    line_length = 6,
                    repeat_count = 1,
                    animation_speed = 0.2,
                    scale = 0.5,
                    shift = {0, -0.5}
                }
            }}
        }
    }},
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input"
    },
    crafting_categories = {"biofarm-mod-bioreactor", "biofarm-mod-bioreactor-2"},
    ingredient_count = 3,
    crafting_speed = 1.5,
    energy_usage = "225kW",
    module_specification = {
        module_slots = 2
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"}
}, -- ###############################################################################################
-- BIOREACTOR MK3
{
    type = "assembling-machine",
    name = "bi-bio-reactor-3",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/bioreactor-3.png",
    icon_size = 64,
    icon_mipmaps = 4,
    se_allow_in_space = true,
    flags = {"placeable-neutral", "player-creation"},
    minable = {
        hardness = 0.2,
        mining_time = 0.5,
        result = "bi-bio-reactor-3"
    },
    max_health = 200,
    corpse = "big-remnants",
    fluid_boxes = {
        {
            production_type = "input",
            pipe_picture = assembler2pipepicturesBioreactor,
            pipe_covers = pipecoverspictures(),
            base_area = 10,
            base_level = -1,
            pipe_connections = {{
                type = "input",
                position = {0, -2}
            }},
            render_layer = "higher-object-under"
        },
        {
            production_type = "input",
            pipe_picture = assembler2pipepicturesBioreactor,
            pipe_covers = pipecoverspictures(),
            base_area = 10,
            base_level = -1,
            pipe_connections = {{
                type = "input",
                position = {2, 0}
            }},
            render_layer = "higher-object-under"
        },
        {
            production_type = "input",
            pipe_picture = assembler2pipepicturesBioreactor,
            pipe_covers = pipecoverspictures(),
            base_area = 10,
            base_level = -1,
            pipe_connections = {{
                type = "input",
                position = {0, 2}
            }},
            render_layer = "higher-object-under"
        },
        {
            production_type = "output",
            pipe_picture = assembler2pipepicturesBioreactor,
            pipe_covers = pipecoverspictures(),
            base_area = 10,
            base_level = 1,
            pipe_connections = {{
                type = "output",
                position = {-2, -1}
            }},
            render_layer = "higher-object-under"
        },
        {
            production_type = "output",
            pipe_picture = assembler2pipepicturesBioreactor,
            pipe_covers = pipecoverspictures(),
            base_area = 10,
            base_level = 1,
            pipe_connections = {{
                type = "output",
                position = {-2, 1}
            }},
            render_layer = "higher-object-under"
        },
        off_when_no_fluid_recipe = true
    },
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    animation = {
        layers = {{
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_reactor/bioreactor_idle-3.png",
            priority = "high",
            width = 91,
            height = 128,
            frame_count = 1,
            line_length = 1,
            repeat_count = 18,
            animation_speed = 0.2,
            scale = 1,
            shift = {0, -0.5},
            hr_version = {
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_reactor/hr_bioreactor_idle-3.png",
                priority = "high",
                width = 182,
                height = 256,
                frame_count = 1,
                line_length = 1,
                repeat_count = 18,
                animation_speed = 0.2,
                scale = 0.5,
                shift = {0, -0.5}
            }

        }, {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_reactor/bioreactor_shadow.png",
            priority = "low",
            width = 135,
            height = 128,
            frame_count = 1,
            line_length = 1,
            repeat_count = 18,
            animation_speed = 0.2,
            scale = 1,
            shift = {0.5, -0.5},
            draw_as_shadow = true,
            hr_version = {
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_reactor/hr_bioreactor_shadow.png",
                priority = "low",
                width = 270,
                height = 256,
                frame_count = 1,
                line_length = 1,
                repeat_count = 18,
                animation_speed = 0.2,
                scale = 0.5,
                shift = {0.5, -0.5},
                draw_as_shadow = true
            }
        }}
    },
    working_visualisations = {{
        effect = "none",
        render_layer = "object",
        animation = {
            layers = {{
                filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_reactor/bioreactor_anim-3.png",
                priority = "high",
                width = 91,
                height = 128,
                frame_count = 18,
                line_length = 6,
                repeat_count = 1,
                animation_speed = 0.2,
                scale = 1,
                shift = {0, -0.5},
                hr_version = {
                    filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/bio_reactor/hr_bioreactor_anim-3.png",
                    priority = "high",
                    width = 182,
                    height = 256,
                    frame_count = 18,
                    line_length = 6,
                    repeat_count = 1,
                    animation_speed = 0.2,
                    scale = 0.5,
                    shift = {0, -0.5}
                }
            }}
        }
    }},
    energy_source = {
        type = "electric",
        usage_priority = "secondary-input"
    },
    crafting_categories = {"biofarm-mod-bioreactor", "biofarm-mod-bioreactor-2", "biofarm-mod-bioreactor-3"},
    ingredient_count = 3,
    crafting_speed = 2,
    energy_usage = "300W",
    module_specification = {
        module_slots = 3
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"}
}})

-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if mods["classic-beacon"] then return end
if not mods["bobmodules"] then return end
if reskins.lib.setting("reskins-bobs-do-bobmodules") == false then return end

-- Set input parameters
local inputs = {
    type = "beacon",
    icon_name = "beacon",
    base_entity = "beacon",
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "modules",
    particles = {["small"] = 3},
}

local tier_map = {
    ["beacon"] = {1, 3},
    ["beacon-2"] = {2, 4},
    ["beacon-3"] = {3, 5},
}

local empty_fill_layer = {
    pictures = {
        filename = "__core__/graphics/empty.png",
        priority = "high",
        size = 1,
        line_length = 1,
        variation_count = 1,
    }
}

local function setup_module_slot(parameters)
    local shift_x, shift_y = 0, 0
    if parameters.shift then
        shift_x = parameters.shift[1]
        shift_y = parameters.shift[2]
    end

    local num_lights = parameters.lights or 8

    -- Setup slots
    if parameters.is_slot_2 then
        -- Slot 2 (Top Right)
        slot = {
            {
              has_empty_slot = true,
              render_layer = "lower-object",
              pictures =
              {
                filename = inputs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/2/beacon-module-slot-2.png",
                line_length = num_lights + 1,
                width = 23,
                height = 22,
                variation_count = num_lights + 1,
                shift = util.by_pixel(19 + shift_x, -12 + shift_y),
                hr_version =
                {
                  filename = inputs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/2/hr-beacon-module-slot-2.png",
                  line_length = num_lights + 1,
                  width = 46,
                  height = 44,
                  variation_count = num_lights + 1,
                  scale = 0.5,
                  shift = util.by_pixel(19 + shift_x, -12 + shift_y),
                }
              }
            },
            {
              apply_module_tint = "primary",
              render_layer = "lower-object",
              pictures =
              {
                filename = inputs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/2/beacon-module-mask-box-2.png",
                line_length = num_lights,
                width = 18,
                height = 14,
                variation_count = num_lights,
                shift = util.by_pixel(20.5 + shift_x, -12 + shift_y),
                hr_version =
                {
                  filename = inputs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/2/hr-beacon-module-mask-box-2.png",
                  line_length = num_lights,
                  width = 36,
                  height = 28,
                  variation_count = num_lights,
                  scale = 0.5,
                  shift = util.by_pixel(20.5 + shift_x, -12 + shift_y),
                }
              }
            },
            {
              apply_module_tint = "secondary",
              render_layer = "lower-object-above-shadow",
              pictures =
              {
                filename = inputs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/2/beacon-module-mask-lights-2.png",
                line_length = num_lights,
                width = 12,
                height = 8,
                variation_count = num_lights,
                shift = util.by_pixel(21.5 + shift_x, -15.5 + shift_y),
                hr_version =
                {
                  filename = inputs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/2/hr-beacon-module-mask-lights-2.png",
                  line_length = num_lights,
                  width = 24,
                  height = 16,
                  variation_count = num_lights,
                  scale = 0.5,
                  shift = util.by_pixel(21.5 + shift_x, -15.5 + shift_y),
                }
              }
            },
            {
              apply_module_tint = "secondary",
              draw_as_light = true,
              draw_as_sprite = false,
              pictures =
              {
                filename = inputs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/2/beacon-module-lights-2.png",
                line_length = num_lights,
                width = 33,
                height = 23,
                variation_count = num_lights,
                shift = util.by_pixel(22 + shift_x, -16 + shift_y),
                hr_version = {
                  filename = inputs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/2/hr-beacon-module-lights-2.png",
                  line_length = num_lights,
                  width = 66,
                  height = 46,
                  variation_count = num_lights,
                  shift = util.by_pixel(22 + shift_x, -16 + shift_y),
                  scale = 0.5
                }
              }
            }
        }
    else
        -- Slot 1 (Bottom Left)
        slot = {
            -- Slot Base
            {
                has_empty_slot = true,
                render_layer = "lower-object",
                pictures = {
                    filename = inputs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/1/beacon-module-slot-1.png",
                    line_length = num_lights + 1,
                    width = 25,
                    height = 33,
                    variation_count = num_lights + 1,
                    shift = util.by_pixel(-16 + shift_x, 14.5 + shift_y),
                    hr_version = {
                        filename = inputs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/1/hr-beacon-module-slot-1.png",
                        line_length = num_lights + 1,
                        width = 50,
                        height = 66,
                        variation_count = num_lights + 1,
                        scale = 0.5,
                        shift = util.by_pixel(-16 + shift_x, 14.5 + shift_y),
                    }
                }
            },
            -- Slot Mask
            {
                apply_module_tint = "primary",
                render_layer = "lower-object",
                pictures = {
                    filename = inputs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/1/beacon-module-mask-box-1.png",
                    line_length = num_lights,
                    width = 18,
                    height = 16,
                    variation_count = num_lights,
                    shift = util.by_pixel(-17 + shift_x, 15 + shift_y),
                    hr_version = {
                        filename = inputs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/1/hr-beacon-module-mask-box-1.png",
                        line_length = num_lights,
                        width = 36,
                        height = 32,
                        variation_count = num_lights,
                        scale = 0.5,
                        shift = util.by_pixel(-17 + shift_x, 15 + shift_y),
                    }
                }
            },
            -- Slot Lights Count
            {
                apply_module_tint = "secondary",
                render_layer = "lower-object-above-shadow",
                pictures = {
                    filename = inputs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/1/beacon-module-mask-lights-1.png",
                    line_length = num_lights,
                    width = 13,
                    height = 8,
                    variation_count = num_lights,
                    shift = util.by_pixel(-18 + shift_x, 13 + shift_y),
                    hr_version = {
                        filename = inputs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/1/hr-beacon-module-mask-lights-1.png",
                        line_length = num_lights,
                        width = 26,
                        height = 16,
                        variation_count = num_lights,
                        scale = 0.5,
                        shift = util.by_pixel(-18.5 + shift_x, 13 + shift_y),
                    }
                }
            },
            -- Slot Lights Radiance
            {
                apply_module_tint = "secondary",
                draw_as_light = true,
                draw_as_sprite = false,
                pictures = {
                    filename = inputs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/1/beacon-module-lights-1.png",
                    line_length = num_lights,
                    width = 28,
                    height = 21,
                    variation_count = num_lights,
                    shift = util.by_pixel(-18 + shift_x, 13 + shift_y),
                    hr_version = {
                        filename = inputs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/1/hr-beacon-module-lights-1.png",
                        line_length = num_lights,
                        width = 56,
                        height = 42,
                        variation_count = num_lights,
                        shift = util.by_pixel(-18 + shift_x, 13 + shift_y),
                        scale = 0.5
                    }
                }
            }
        }
    end

    -- Fix interleaved render orders
    if parameters.needs_padding then
        table.insert(slot, 1, empty_fill_layer)
    end

    return slot
end

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Fix order shenanigans
    if name == "beacon" then
        data.raw["item"][name].order = "a[beacon]-1"
        entity.order = "z-a[beacon]-1"
    end
    
    -- Parse map
    local tier = map[1]
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map[2]
    end
    local beacon_base = map[1]

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index["tier-"..tier]
  
    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Fetch remnant
    local remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin remnants
    remnant.animation = make_rotated_animation_variations_from_sheet (2, {
        layers = {
            -- Base
            {
                filename = "__base__/graphics/entity/beacon/remnants/beacon-remnants.png",
                line_length = 1,
                width = 106,
                height = 104,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(1, 5),
                hr_version = {
                    filename = "__base__/graphics/entity/beacon/remnants/hr-beacon-remnants.png",
                    line_length = 1,
                    width = 212,
                    height = 206,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(1, 5),
                    scale = 0.5,
                },
            },
            -- Mask
            {
                filename = inputs.directory.."/graphics/entity/modules/beacon/remnants/beacon-remnants-mask.png",
                line_length = 1,
                width = 106,
                height = 104,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(1, 5),
                tint = inputs.tint,
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/modules/beacon/remnants/hr-beacon-remnants-mask.png",
                    line_length = 1,
                    width = 212,
                    height = 206,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(1, 5),
                    tint = inputs.tint,
                    scale = 0.5,
                },
            },
            -- Highlights
            {
                filename = inputs.directory.."/graphics/entity/modules/beacon/remnants/beacon-remnants-highlights.png",
                line_length = 1,
                width = 106,
                height = 104,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(1, 5),
                blend_mode = "additive",
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/modules/beacon/remnants/hr-beacon-remnants-highlights.png",
                    line_length = 1,
                    width = 212,
                    height = 206,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(1, 5),
                    blend_mode = "additive",
                    scale = 0.5,
                },
            },
        }
    })

    -- Reskin entities
    entity.graphics_set.animation_list =
    {
        -- Beacon Base
        {
            render_layer = "floor-mechanics",
            always_draw = true,
            animation = {
                layers = {
                    -- Base
                    {
                        filename = inputs.directory.."/graphics/entity/modules/beacon/beacon-"..beacon_base.."-bottom.png",
                        width = 106,
                        height = 96,
                        shift = util.by_pixel(0, 1),
                        hr_version = {
                            filename = inputs.directory.."/graphics/entity/modules/beacon/hr-beacon-"..beacon_base.."-bottom.png",
                            width = 212,
                            height = 192,
                            scale = 0.5,
                            shift = util.by_pixel(0.5, 1),
                        }
                    },
                    -- Mask
                    {
                        filename = inputs.directory.."/graphics/entity/modules/beacon/beacon-"..beacon_base.."-bottom-mask.png",
                        width = 106,
                        height = 96,
                        shift = util.by_pixel(0, 1),
                        tint = inputs.tint,
                        hr_version = {
                            filename = inputs.directory.."/graphics/entity/modules/beacon/hr-beacon-"..beacon_base.."-bottom-mask.png",
                            width = 212,
                            height = 192,
                            shift = util.by_pixel(0.5, 1),
                            tint = inputs.tint,
                            scale = 0.5,
                        }
                    },
                    -- Highlights
                    {
                        filename = inputs.directory.."/graphics/entity/modules/beacon/beacon-"..beacon_base.."-bottom-highlights.png",
                        width = 106,
                        height = 96,
                        shift = util.by_pixel(0, 1),
                        blend_mode = "additive",
                        hr_version = {
                            filename = inputs.directory.."/graphics/entity/modules/beacon/hr-beacon-"..beacon_base.."-bottom-highlights.png",
                            width = 212,
                            height = 192,
                            shift = util.by_pixel(0.5, 1),
                            blend_mode = "additive",
                            scale = 0.5,
                        }
                    },
                    -- Shadow
                    {
                        filename = "__base__/graphics/entity/beacon/beacon-shadow.png",
                        width = 122,
                        height = 90,
                        draw_as_shadow = true,
                        shift = util.by_pixel(12, 1),
                        hr_version = {
                            filename = "__base__/graphics/entity/beacon/hr-beacon-shadow.png",
                            width = 244,
                            height = 176,
                            scale = 0.5,
                            draw_as_shadow = true,
                            shift = util.by_pixel(12.5, 0.5),
                        }
                    }
                }
            }
        },
        -- Beacon Antenna
        {
            render_layer = "object",
            always_draw = true,
            animation = {
                filename = inputs.directory.."/graphics/entity/modules/beacon/beacon-"..beacon_base.."-top.png",
                width = 48,
                height = 70,
                repeat_count = 45,
                animation_speed = 0.5,
                shift = util.by_pixel(3, -19),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/modules/beacon/hr-beacon-"..beacon_base.."-top.png",
                    width = 96,
                    height = 140,
                    scale = 0.5,
                    repeat_count = 45,
                    animation_speed = 0.5,
                    shift = util.by_pixel(3, -19),
                }
            }
        },
        -- Beacon Light Animation
        {
            render_layer = "object",
            apply_tint = true,
            draw_as_sprite = true,
            draw_as_light = true,
            always_draw = false,
            animation = {
                filename = "__base__/graphics/entity/beacon/beacon-light.png",
                line_length = 9,
                width = 56,
                height = 94,
                frame_count = 45,
                animation_speed = 0.5,
                shift = util.by_pixel(1, -18),
                blend_mode = "additive",
                hr_version = {
                    filename = "__base__/graphics/entity/beacon/hr-beacon-light.png",
                    line_length = 9,
                    width = 110,
                    height = 186,
                    frame_count = 45,
                    animation_speed = 0.5,
                    scale = 0.5,
                    shift = util.by_pixel(0.5, -18),
                    blend_mode = "additive",
                }
            }
        },
    }

    -- Handle module slots
    if beacon_base == 1 then
        -- 8 light modules
        table.insert(entity.graphics_set.module_visualisations, {
            art_style = "artisan-reskin",
            use_for_empty_slots = true,
            tier_offset = 0,
            slots = {
                setup_module_slot({}),
                setup_module_slot({is_slot_2 = true}),
            }
        })
        -- 5 light modules
        -- table.insert(entity.graphics_set.module_visualisations, {
        --     art_style = "artisan-reskin-5-lights",
        --     use_for_empty_slots = true,
        --     tier_offset = 0,
        --     slots = {
        --         setup_module_slot({lights = 5}),
        --         setup_module_slot({lights = 5, is_slot_2 = true}),
        --     }
        -- })
    elseif beacon_base == 2 then
        -- 8 light modules
        table.insert(entity.graphics_set.module_visualisations, {
            art_style = "artisan-reskin",
            use_for_empty_slots = true,
            tier_offset = 0,
            slots = {
                setup_module_slot({shift = {-3, -2.5}}), -- Slot 1, shifted left and up, below other module slot
                setup_module_slot({shift = {-8.5, -5.5}, is_slot_2 = true}), -- Slot 2, shifted left and up, below other module slot
                setup_module_slot({shift = {12, 5}}), -- Slot 1, shifted right and down, above other module slot
                setup_module_slot({shift = {2, 5}, is_slot_2 = true}), -- Slot 2, shifted right and down, above other module slot
            }
        })
        -- 5 light modules
        -- table.insert(entity.graphics_set.module_visualisations, {
        --     art_style = "artisan-reskin-5-lights",
        --     use_for_empty_slots = true,
        --     tier_offset = 0,
        --     slots = {
        --         setup_module_slot({lights = 5, shift = {-3, -2.5}}), -- Slot 1, shifted left and up, below other module slot
        --         setup_module_slot({lights = 5, shift = {-8.5, -5.5}, is_slot_2 = true}), -- Slot 2, shifted left and up, below other module slot
        --         setup_module_slot({lights = 5, shift = {12, 5}}), -- Slot 1, shifted right and down, above other module slot
        --         setup_module_slot({lights = 5, shift = {2, 5}, is_slot_2 = true}), -- Slot 2, shifted right and down, above other module slot
        --     }
        -- })

        -- Module slot overlay
        table.insert(entity.graphics_set.animation_list, {
            render_layer = "transport-belt-circuit-connector", -- Above modules, below lights
            always_draw = true,
            animation = {
                layers = {
                    -- Base
                    {
                        filename = inputs.directory.."/graphics/entity/modules/beacon/beacon-2-bottom-slot-overlay.png",
                        width = 106,
                        height = 96,
                        shift = util.by_pixel(0, 1),
                        hr_version = {
                            filename = inputs.directory.."/graphics/entity/modules/beacon/hr-beacon-2-bottom-slot-overlay.png",
                            width = 212,
                            height = 192,
                            scale = 0.5,
                            shift = util.by_pixel(0.5, 1),
                        }
                    }
                }
            }
        })
    elseif beacon_base == 3 then
        -- 8 light modules
        table.insert(entity.graphics_set.module_visualisations, {
            art_style = "artisan-reskin",
            use_for_empty_slots = true,
            tier_offset = 0,
            slots = {
                setup_module_slot({shift = {-10.5, -11}}), -- Slot 1, shifted left and up, below all
                setup_module_slot({shift = {7.5, -2}, is_slot_2 = true}), -- Slot 2, shifted right and up, below all
                setup_module_slot({shift = {-1.5, 7}}), -- Slot 1, shifted left and down, middle
                setup_module_slot({shift = {-11, -6.5}, is_slot_2 = true}), -- Slot 2, shifted left and up, middle
                setup_module_slot({shift = {17, 3}}), -- Slot 1, shifted right and down, above all
                setup_module_slot({shift = {4.5, 8}, is_slot_2 = true, needs_padding = true}), -- Slot 2, shifted right and down, above all
            }
        })
        -- 5 light modules
        -- table.insert(entity.graphics_set.module_visualisations, {
        --     art_style = "artisan-reskin-5-lights",
        --     use_for_empty_slots = true,
        --     tier_offset = 0,
        --     slots = {
        --         setup_module_slot({lights = 5, shift = {-10.5, -11}}), -- Slot 1, shifted left and up, below all
        --         setup_module_slot({lights = 5, shift = {7.5, -2}, is_slot_2 = true}), -- Slot 2, shifted right and up, below all
        --         setup_module_slot({lights = 5, shift = {-1.5, 7}}), -- Slot 1, shifted left and down, middle
        --         setup_module_slot({lights = 5, shift = {-11, -6.5}, is_slot_2 = true}), -- Slot 2, shifted left and up, middle
        --         setup_module_slot({lights = 5, shift = {17, 3}}), -- Slot 1, shifted right and down, above all
        --         setup_module_slot({lights = 5, shift = {4.5, 8}, is_slot_2 = true, needs_padding = true}), -- Slot 2, shifted right and down, above all
        --     }
        -- })

        -- Module slot overlay
        table.insert(entity.graphics_set.animation_list, {
            render_layer = "transport-belt-circuit-connector", -- Above modules, below lights
            always_draw = true,
            animation = {
                layers = {
                    -- Base
                    {
                        filename = inputs.directory.."/graphics/entity/modules/beacon/beacon-3-bottom-slot-overlay.png",
                        width = 106,
                        height = 96,
                        shift = util.by_pixel(0, 1),
                        hr_version = {
                            filename = inputs.directory.."/graphics/entity/modules/beacon/hr-beacon-3-bottom-slot-overlay.png",
                            width = 212,
                            height = 192,
                            scale = 0.5,
                            shift = util.by_pixel(0.5, 1),
                        }
                    },
                    -- Mask
                    {
                        filename = inputs.directory.."/graphics/entity/modules/beacon/beacon-3-bottom-slot-overlay-mask.png",
                        width = 106,
                        height = 96,
                        shift = util.by_pixel(0, 1),
                        tint = inputs.tint,
                        hr_version = {
                            filename = inputs.directory.."/graphics/entity/modules/beacon/hr-beacon-3-bottom-slot-overlay-mask.png",
                            width = 212,
                            height = 192,
                            scale = 0.5,
                            shift = util.by_pixel(0.5, 1),
                            tint = inputs.tint,
                        }
                    },
                    -- Highlights
                    {
                        filename = inputs.directory.."/graphics/entity/modules/beacon/beacon-3-bottom-slot-overlay-highlights.png",
                        width = 106,
                        height = 96,
                        shift = util.by_pixel(0, 1),
                        blend_mode = "additive",
                        hr_version = {
                            filename = inputs.directory.."/graphics/entity/modules/beacon/hr-beacon-3-bottom-slot-overlay-highlights.png",
                            width = 212,
                            height = 192,
                            scale = 0.5,
                            shift = util.by_pixel(0.5, 1),
                            blend_mode = "additive",
                        }
                    }
                }
            }
        })
    end

    -- Label to skip to next iteration
    ::continue::
end
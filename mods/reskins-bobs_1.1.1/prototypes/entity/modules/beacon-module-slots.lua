-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if mods["classic-beacon"] then return end
if not mods["bobmodules"] then return end
if reskins.lib.setting("reskins-bobs-do-bobmodules") == false then return end

local empty_fill_layer = {
    pictures = {
        filename = "__core__/graphics/empty.png",
        priority = "high",
        size = 1,
        line_length = 1,
        variation_count = 1,
    }
}

-- Artisanal Reskins module slot
local function setup_module_slot(parameters)
    local shift_x, shift_y = 0, 0
    if parameters.shift then
        shift_x = parameters.shift[1]
        shift_y = parameters.shift[2]
    end

    local num_lights = parameters.lights or 8

    -- Setup slots
    local slot = {}
    if parameters.is_slot_2 then
        -- Slot 2 (Top Right)
        slot = {
            {
                has_empty_slot = true,
                render_layer = "lower-object",
                pictures = {
                    filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/2/beacon-module-slot-2.png",
                    line_length = num_lights + 1,
                    width = 23,
                    height = 22,
                    variation_count = num_lights + 1,
                    shift = util.by_pixel(19 + shift_x, -12 + shift_y),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/2/hr-beacon-module-slot-2.png",
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
                pictures = {
                    filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/2/beacon-module-mask-box-2.png",
                    line_length = num_lights,
                    width = 18,
                    height = 14,
                    variation_count = num_lights,
                    shift = util.by_pixel(20.5 + shift_x, -12 + shift_y),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/2/hr-beacon-module-mask-box-2.png",
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
                pictures = {
                    filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/2/beacon-module-mask-lights-2.png",
                    line_length = num_lights,
                    width = 12,
                    height = 8,
                    variation_count = num_lights,
                    shift = util.by_pixel(21.5 + shift_x, -15.5 + shift_y),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/2/hr-beacon-module-mask-lights-2.png",
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
                pictures = {
                    filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/2/beacon-module-lights-2.png",
                    line_length = num_lights,
                    width = 33,
                    height = 23,
                    variation_count = num_lights,
                    shift = util.by_pixel(22 + shift_x, -16 + shift_y),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/2/hr-beacon-module-lights-2.png",
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
                    filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/1/beacon-module-slot-1.png",
                    line_length = num_lights + 1,
                    width = 25,
                    height = 33,
                    variation_count = num_lights + 1,
                    shift = util.by_pixel(-16 + shift_x, 14.5 + shift_y),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/1/hr-beacon-module-slot-1.png",
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
                    filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/1/beacon-module-mask-box-1.png",
                    line_length = num_lights,
                    width = 18,
                    height = 16,
                    variation_count = num_lights,
                    shift = util.by_pixel(-17 + shift_x, 15 + shift_y),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/1/hr-beacon-module-mask-box-1.png",
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
                    filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/1/beacon-module-mask-lights-1.png",
                    line_length = num_lights,
                    width = 13,
                    height = 8,
                    variation_count = num_lights,
                    shift = util.by_pixel(-18 + shift_x, 13 + shift_y),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/1/hr-beacon-module-mask-lights-1.png",
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
                    filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/1/beacon-module-lights-1.png",
                    line_length = num_lights,
                    width = 28,
                    height = 21,
                    variation_count = num_lights,
                    shift = util.by_pixel(-18 + shift_x, 13 + shift_y),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/slots/"..num_lights.."-lights/1/hr-beacon-module-lights-1.png",
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

-- Vanilla module slot
local function setup_vanilla_module_slot(parameters)
    local shift_x, shift_y = 0, 0
    if parameters.shift then
        shift_x = parameters.shift[1]
        shift_y = parameters.shift[2]
    end

    -- Setup slots
    if parameters.is_slot_2 then
        -- Slot 2 (Top Right)
        slot = {
            {
                has_empty_slot = true,
                render_layer = "lower-object",
                pictures =
                {
                    filename = "__base__/graphics/entity/beacon/beacon-module-slot-2.png",
                    line_length = 4,
                    width = 24,
                    height = 22,
                    variation_count = 4,
                    shift = util.by_pixel(19 + shift_x, -12 + shift_y),
                    hr_version =
                    {
                        filename = "__base__/graphics/entity/beacon/hr-beacon-module-slot-2.png",
                        line_length = 4,
                        width = 46,
                        height = 44,
                        variation_count = 4,
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
                    filename = "__base__/graphics/entity/beacon/beacon-module-mask-box-2.png",
                    line_length = 3,
                    width = 18,
                    height = 14,
                    variation_count = 3,
                    shift = util.by_pixel(20 + shift_x, -12 + shift_y),
                    hr_version =
                    {
                        filename = "__base__/graphics/entity/beacon/hr-beacon-module-mask-box-2.png",
                        line_length = 3,
                        width = 36,
                        height = 26,
                        variation_count = 3,
                        scale = 0.5,
                        shift = util.by_pixel(20.5 + shift_x, -12 + shift_y),
                    }
                }
            },
            {
                apply_module_tint = "secondary",
                render_layer = "lower-object-above-shadow",
                pictures = {
                    filename = "__base__/graphics/entity/beacon/beacon-module-mask-lights-2.png",
                    line_length = 3,
                    width = 12,
                    height = 8,
                    variation_count = 3,
                    shift = util.by_pixel(22 + shift_x, -15 + shift_y),
                    hr_version = {
                        filename = "__base__/graphics/entity/beacon/hr-beacon-module-mask-lights-2.png",
                        line_length = 3,
                        width = 24,
                        height = 14,
                        variation_count = 3,
                        scale = 0.5,
                        shift = util.by_pixel(22 + shift_x, -15.5 + shift_y),
                    }
                }
            },
            {
                apply_module_tint = "secondary",
                draw_as_light = true,
                draw_as_sprite = false,
                pictures = {
                    filename = "__base__/graphics/entity/beacon/beacon-module-lights-2.png",
                    line_length = 3,
                    width = 34,
                    height = 24,
                    variation_count = 3,
                    shift = util.by_pixel(22 + shift_x, -16 + shift_y),
                    hr_version = {
                        filename = "__base__/graphics/entity/beacon/hr-beacon-module-lights-2.png",
                        line_length = 3,
                        width = 66,
                        height = 46,
                        variation_count = 3,
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
                    filename = "__base__/graphics/entity/beacon/beacon-module-slot-1.png",
                    line_length = 4,
                    width = 26,
                    height = 34,
                    variation_count = 4,
                    shift = util.by_pixel(-16 + shift_x, 15 + shift_y),
                    hr_version = {
                        filename = "__base__/graphics/entity/beacon/hr-beacon-module-slot-1.png",
                        line_length = 4,
                        width = 50,
                        height = 66,
                        variation_count = 4,
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
                    filename = "__base__/graphics/entity/beacon/beacon-module-mask-box-1.png",
                    line_length = 3,
                    width = 18,
                    height = 16,
                    variation_count = 3,
                    shift = util.by_pixel(-17 + shift_x, 15 + shift_y),
                    hr_version = {
                        filename = "__base__/graphics/entity/beacon/hr-beacon-module-mask-box-1.png",
                        line_length = 3,
                        width = 36,
                        height = 32,
                        variation_count = 3,
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
                    filename = "__base__/graphics/entity/beacon/beacon-module-mask-lights-1.png",
                    line_length = 3,
                    width = 14,
                    height = 6,
                    variation_count = 3,
                    shift = util.by_pixel(-18 + shift_x, 13 + shift_y),
                    hr_version = {
                        filename = "__base__/graphics/entity/beacon/hr-beacon-module-mask-lights-1.png",
                        line_length = 3,
                        width = 26,
                        height = 12,
                        variation_count = 3,
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
                    filename = "__base__/graphics/entity/beacon/beacon-module-lights-1.png",
                    line_length = 3,
                    width = 28,
                    height = 22,
                    variation_count = 3,
                    shift = util.by_pixel(-18 + shift_x, 13 + shift_y),
                    hr_version = {
                        filename = "__base__/graphics/entity/beacon/hr-beacon-module-lights-1.png",
                        line_length = 3,
                        width = 56,
                        height = 42,
                        variation_count = 3,
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

-- List of beacons
local beacons = {"beacon", "beacon-2", "beacon-3"}

-- Setup module slots
for _, name in pairs(beacons) do
    -- Fetch entity
    local entity = data.raw["beacon"][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    if name == "beacon" then
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
    elseif name == "beacon-2" then
        -- Setup vanilla slots
        entity.graphics_set.module_visualisations[1] = {
            art_style = "vanilla",
            use_for_empty_slots = true,
            tier_offset = 0,
            slots = {
                setup_vanilla_module_slot({shift = {-3, -2.5}}), -- Slot 1, shifted left and up, below other module slot
                setup_vanilla_module_slot({shift = {-8.5, -5.5}, is_slot_2 = true}), -- Slot 2, shifted left and up, below other module slot
                setup_vanilla_module_slot({shift = {12, 5}}), -- Slot 1, shifted right and down, above other module slot
                setup_vanilla_module_slot({shift = {2, 5}, is_slot_2 = true}), -- Slot 2, shifted right and down, above other module slot
            }
        }

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
    else
        -- Setup vanilla slots
        entity.graphics_set.module_visualisations[1] = {
            art_style = "vanilla",
            use_for_empty_slots = true,
            tier_offset = 0,
            slots = {
                setup_vanilla_module_slot({shift = {-10.5, -11}}), -- Slot 1, shifted left and up, below all
                setup_vanilla_module_slot({shift = {7.5, -2}, is_slot_2 = true}), -- Slot 2, shifted right and up, below all
                setup_vanilla_module_slot({shift = {-1.5, 7}}), -- Slot 1, shifted left and down, middle
                setup_vanilla_module_slot({shift = {-11, -6.5}, is_slot_2 = true}), -- Slot 2, shifted left and up, middle
                setup_vanilla_module_slot({shift = {17, 3}}), -- Slot 1, shifted right and down, above all
                setup_vanilla_module_slot({shift = {4.5, 8}, is_slot_2 = true, needs_padding = true}), -- Slot 2, shifted right and down, above all
            }
        }

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
    end

    -- Label to skip to next iteration
    ::continue::
end
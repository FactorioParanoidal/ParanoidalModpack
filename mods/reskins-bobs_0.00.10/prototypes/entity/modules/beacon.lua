-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobmodules"] then return end
if reskins.lib.setting("reskins-bobs-do-bobmodules") == false then return end

local function setup_module_slot(shift, is_top)
    local shift_x, shift_y = 0, 0
    if shift then
        shift_x = shift[1]
        shift_y = shift[2]
    end

    -- Setup slots
    local slot
    if is_top then
        -- Slot 2 (Top Right)
        slot = {
            {
              has_empty_slot = true,
              render_layer = "lower-object",
              pictures =
              {
                filename = inputs.directory.."/graphics/entity/modules/beacon/slots/2/beacon-module-slot-2.png",
                line_length = 4,
                width = 24,
                height = 22,
                variation_count = 4,
                shift = util.by_pixel(19 + shift_x, -12 + shift_y),
                hr_version =
                {
                  filename = inputs.directory.."/graphics/entity/modules/beacon/slots/2/hr-beacon-module-slot-2.png",
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
                filename = inputs.directory.."/graphics/entity/modules/beacon/slots/2/beacon-module-mask-box-2.png",
                line_length = 3,
                width = 18,
                height = 14,
                variation_count = 3,
                shift = util.by_pixel(20 + shift_x, -12 + shift_y),
                hr_version =
                {
                  filename = inputs.directory.."/graphics/entity/modules/beacon/slots/2/hr-beacon-module-mask-box-2.png",
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
              pictures =
              {
                filename = inputs.directory.."/graphics/entity/modules/beacon/slots/2/beacon-module-mask-lights-2.png",
                line_length = 3,
                width = 12,
                height = 8,
                variation_count = 3,
                shift = util.by_pixel(22 + shift_x, -15 + shift_y),
                hr_version =
                {
                  filename = inputs.directory.."/graphics/entity/modules/beacon/slots/2/hr-beacon-module-mask-lights-2.png",
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
              pictures =
              {
                filename = inputs.directory.."/graphics/entity/modules/beacon/slots/2/beacon-module-lights-2.png",
                line_length = 3,
                width = 34,
                height = 24,
                variation_count = 3,
                shift = util.by_pixel(22 + shift_x, -16 + shift_y),
                hr_version = {
                  filename = inputs.directory.."/graphics/entity/modules/beacon/slots/2/hr-beacon-module-lights-2.png",
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
                    filename = inputs.directory.."/graphics/entity/modules/beacon/slots/1/beacon-module-slot-1.png",
                    line_length = 9,
                    width = 25,
                    height = 33,
                    variation_count = 9,
                    shift = util.by_pixel(-16 + shift_x, 14.5 + shift_y),
                    hr_version = {
                        filename = inputs.directory.."/graphics/entity/modules/beacon/slots/1/hr-beacon-module-slot-1.png",
                        line_length = 9,
                        width = 50,
                        height = 66,
                        variation_count = 9,
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
                    filename = inputs.directory.."/graphics/entity/modules/beacon/slots/1/beacon-module-mask-box-1.png",
                    line_length = 8,
                    width = 18,
                    height = 16,
                    variation_count = 8,
                    shift = util.by_pixel(-17 + shift_x, 15 + shift_y),
                    hr_version = {
                        filename = inputs.directory.."/graphics/entity/modules/beacon/slots/1/hr-beacon-module-mask-box-1.png",
                        line_length = 8,
                        width = 36,
                        height = 32,
                        variation_count = 8,
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
                    filename = inputs.directory.."/graphics/entity/modules/beacon/slots/1/beacon-module-mask-lights-1.png",
                    line_length = 8,
                    width = 13,
                    height = 8,
                    variation_count = 8,
                    shift = util.by_pixel(-18 + shift_x, 13 + shift_y),
                    hr_version = {
                        filename = inputs.directory.."/graphics/entity/modules/beacon/slots/1/hr-beacon-module-mask-lights-1.png",
                        line_length = 8,
                        width = 26,
                        height = 16,
                        variation_count = 8,
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
                    filename = inputs.directory.."/graphics/entity/modules/beacon/slots/1/beacon-module-lights-1.png",
                    line_length = 8,
                    width = 28,
                    height = 21,
                    variation_count = 8,
                    shift = util.by_pixel(-18 + shift_x, 13 + shift_y),
                    hr_version = {
                        filename = inputs.directory.."/graphics/entity/modules/beacon/slots/1/hr-beacon-module-lights-1.png",
                        line_length = 8,
                        width = 56,
                        height = 42,
                        variation_count = 8,
                        shift = util.by_pixel(-18 + shift_x, 13 + shift_y),
                        scale = 0.5
                    }
                }
            }
        }
    end

    return slot
end

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

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
    -- Fetch entity
    entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Fix order shenanigans
    if name == "beacon" then
        data.raw["item"][name].order = "a[beacon]-1"
        entity.order = "z-a[beacon]-1"
    end
    
    -- Parse map
    if reskins.lib.setting("reskins-lib-tier-mapping") == "name-map" then
        tier = map[1]
    else
        tier = map[2]
    end
    beacon_base = map[1]

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index["tier-"..tier]
  
    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Fetch remnant
    remnant = data.raw["corpse"][name.."-remnants"]

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
        {
            render_layer = "floor-mechanics",
            always_draw = true,
            animation = {
                layers = {
                    -- Base
                    {
                        filename = "__base__/graphics/entity/beacon/beacon-bottom.png",
                        width = 106,
                        height = 96,
                        shift = util.by_pixel(0, 1),
                        hr_version = {
                            filename = "__base__/graphics/entity/beacon/hr-beacon-bottom.png",
                            width = 212,
                            height = 192,
                            scale = 0.5,
                            shift = util.by_pixel(0.5, 1),
                        }
                    },
                    -- Mask
                    {
                        filename = inputs.directory.."/graphics/entity/modules/beacon/beacon-bottom-mask.png",
                        width = 106,
                        height = 96,
                        shift = util.by_pixel(0, 1),
                        tint = inputs.tint,
                        hr_version = {
                            filename = inputs.directory.."/graphics/entity/modules/beacon/hr-beacon-bottom-mask.png",
                            width = 212,
                            height = 192,
                            shift = util.by_pixel(0.5, 1),
                            tint = inputs.tint,
                            scale = 0.5,
                        }
                    },
                    -- Highlights
                    {
                        filename = inputs.directory.."/graphics/entity/modules/beacon/beacon-bottom-highlights.png",
                        width = 106,
                        height = 96,
                        shift = util.by_pixel(0, 1),
                        blend_mode = "additive",
                        hr_version = {
                            filename = inputs.directory.."/graphics/entity/modules/beacon/hr-beacon-bottom-highlights.png",
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
        {
            render_layer = "object",
            always_draw = true,
            animation = {
                filename = "__base__/graphics/entity/beacon/beacon-top.png",
                width = 48,
                height = 70,
                repeat_count = 45,
                animation_speed = 0.5,
                shift = util.by_pixel(3, -19),
                hr_version = {
                    filename = "__base__/graphics/entity/beacon/hr-beacon-top.png",
                    width = 96,
                    height = 140,
                    scale = 0.5,
                    repeat_count = 45,
                    animation_speed = 0.5,
                    shift = util.by_pixel(3, -19),
                }
            }
        },
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
        }
    }

    -- Handle module slots
    if beacon_base == 1 then
        table.insert(entity.graphics_set.module_visualisations, {
            art_style = "artisan-reskin",
            use_for_empty_slots = true,
            tier_offset = 0,
            slots = {
                setup_module_slot(),
                setup_module_slot(nil, true),
            }
        })
    elseif beacon_base == 2 then
        table.insert(entity.graphics_set.module_visualisations, {
            art_style = "artisan-reskin",
            use_for_empty_slots = true,
            tier_offset = 0,
            slots = {
                setup_module_slot({-8, -8}), -- Bottom, shifted left and up
                setup_module_slot({8, 8}, true), -- Top, shifted right and down
                setup_module_slot({8, 8}), -- Bottom, shifted right and down
                setup_module_slot({-8, -8}, true), -- Top, shifted left and up
            }
        })
    elseif beacon_base == 3 then
        table.insert(entity.graphics_set.module_visualisations, {
            art_style = "artisan-reskin",
            use_for_empty_slots = true,
            tier_offset = 0,
            slots = {
                setup_module_slot({-8, 8}), -- Bottom, shifted left and down
                setup_module_slot({8, -8}, true), -- Top, shifted right and up
                setup_module_slot({8, 8}), -- Bottom, shifted right and down
                setup_module_slot({-8, -8}, true), -- Top, shifted left and up
                setup_module_slot({-8, -8}), -- Bottom, shifted left and up
                setup_module_slot({8, 8}, true), -- Top, shifted right and down
            }
        })
    end

    -- Label to skip to next iteration
    ::continue::
end
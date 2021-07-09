-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if mods["classic-beacon"] then return end
if not (reskins.bobs and reskins.bobs.triggers.modules.entities) then return end

-- Flag available for Mini-Machines compatibility pass
if reskins.compatibility then reskins.compatibility.triggers.minimachines.beacons = true end

-- Set input parameters
local inputs = {
    type = "beacon",
    icon_name = "beacon",
    base_entity = "beacon",
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
    inputs.tint = reskins.lib.tint_index[tier]

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
                filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/remnants/beacon-remnants-mask.png",
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
                    filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/remnants/hr-beacon-remnants-mask.png",
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
                filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/remnants/beacon-remnants-highlights.png",
                line_length = 1,
                width = 106,
                height = 104,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(1, 5),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/remnants/hr-beacon-remnants-highlights.png",
                    line_length = 1,
                    width = 212,
                    height = 206,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(1, 5),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
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
                        filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/beacon-"..beacon_base.."-bottom.png",
                        width = 106,
                        height = 96,
                        shift = util.by_pixel(0, 1),
                        hr_version = {
                            filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/hr-beacon-"..beacon_base.."-bottom.png",
                            width = 212,
                            height = 192,
                            scale = 0.5,
                            shift = util.by_pixel(0.5, 1),
                        }
                    },
                    -- Mask
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/beacon-"..beacon_base.."-bottom-mask.png",
                        width = 106,
                        height = 96,
                        shift = util.by_pixel(0, 1),
                        tint = inputs.tint,
                        hr_version = {
                            filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/hr-beacon-"..beacon_base.."-bottom-mask.png",
                            width = 212,
                            height = 192,
                            shift = util.by_pixel(0.5, 1),
                            tint = inputs.tint,
                            scale = 0.5,
                        }
                    },
                    -- Highlights
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/beacon-"..beacon_base.."-bottom-highlights.png",
                        width = 106,
                        height = 96,
                        shift = util.by_pixel(0, 1),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        hr_version = {
                            filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/hr-beacon-"..beacon_base.."-bottom-highlights.png",
                            width = 212,
                            height = 192,
                            shift = util.by_pixel(0.5, 1),
                            blend_mode = reskins.lib.blend_mode, -- "additive",
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
                filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/beacon-"..beacon_base.."-top.png",
                width = 48,
                height = 70,
                repeat_count = 45,
                animation_speed = 0.5,
                shift = util.by_pixel(3, -19),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/hr-beacon-"..beacon_base.."-top.png",
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

    -- Handle module slot overlays
    if beacon_base == 2 then
        -- Module slot overlay
        table.insert(entity.graphics_set.animation_list, {
            render_layer = "transport-belt-circuit-connector", -- Above modules, below lights
            always_draw = true,
            animation = {
                layers = {
                    -- Base
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/beacon-2-bottom-slot-overlay.png",
                        width = 106,
                        height = 96,
                        shift = util.by_pixel(0, 1),
                        hr_version = {
                            filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/hr-beacon-2-bottom-slot-overlay.png",
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
        -- Module slot overlay
        table.insert(entity.graphics_set.animation_list, {
            render_layer = "transport-belt-circuit-connector", -- Above modules, below lights
            always_draw = true,
            animation = {
                layers = {
                    -- Base
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/beacon-3-bottom-slot-overlay.png",
                        width = 106,
                        height = 96,
                        shift = util.by_pixel(0, 1),
                        hr_version = {
                            filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/hr-beacon-3-bottom-slot-overlay.png",
                            width = 212,
                            height = 192,
                            scale = 0.5,
                            shift = util.by_pixel(0.5, 1),
                        }
                    },
                    -- Mask
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/beacon-3-bottom-slot-overlay-mask.png",
                        width = 106,
                        height = 96,
                        shift = util.by_pixel(0, 1),
                        tint = inputs.tint,
                        hr_version = {
                            filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/hr-beacon-3-bottom-slot-overlay-mask.png",
                            width = 212,
                            height = 192,
                            scale = 0.5,
                            shift = util.by_pixel(0.5, 1),
                            tint = inputs.tint,
                        }
                    },
                    -- Highlights
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/beacon-3-bottom-slot-overlay-highlights.png",
                        width = 106,
                        height = 96,
                        shift = util.by_pixel(0, 1),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        hr_version = {
                            filename = reskins.bobs.directory.."/graphics/entity/modules/beacon/hr-beacon-3-bottom-slot-overlay-highlights.png",
                            width = 212,
                            height = 192,
                            scale = 0.5,
                            shift = util.by_pixel(0.5, 1),
                            blend_mode = reskins.lib.blend_mode, -- "additive",
                        }
                    }
                }
            }
        })
    end

    -- Label to skip to next iteration
    ::continue::
end
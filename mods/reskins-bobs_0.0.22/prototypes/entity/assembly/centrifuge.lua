-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobassembly"] then return end
if reskins.lib.setting("reskins-bobs-do-bobassembly") == false then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "centrifuge",
    base_entity = "centrifuge",
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "assembly",
    particles = {["big"] = 1, ["medium"] = 2},
}

local tier_map = {
    ["centrifuge"] = {1, 3},
    ["centrifuge-2"] = {2, 4},
    ["centrifuge-3"] = {3, 5},
}

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end
    
    -- Parse map
    local tier = map[1]
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map[2]
    end

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index["tier-"..tier]
  
    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Fetch remnant
    local remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin remnants
    remnant.animation = make_rotated_animation_variations_from_sheet(1, {
        layers = {
            -- Base
            {
                filename = "__base__/graphics/entity/centrifuge/remnants/centrifuge-remnants.png",
                line_length = 1,
                width = 144,
                height = 142,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(7, 4),
                hr_version = {
                    filename = "__base__/graphics/entity/centrifuge/remnants/hr-centrifuge-remnants.png",
                    line_length = 1,
                    width = 286,
                    height = 284,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(7, 4),
                    scale = 0.5,
                },
            },
            -- Mask
            {
                filename = inputs.directory.."/graphics/entity/assembly/centrifuge/remnants/centrifuge-remnants-mask.png",
                line_length = 1,
                width = 144,
                height = 142,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(7, 4),
                tint = inputs.tint,
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/assembly/centrifuge/remnants/hr-centrifuge-remnants-mask.png",
                    line_length = 1,
                    width = 286,
                    height = 284,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(7, 4),
                    tint = inputs.tint,
                    scale = 0.5,
                },
            },
            -- Highlights
            {
                filename = inputs.directory.."/graphics/entity/assembly/centrifuge/remnants/centrifuge-remnants-highlights.png",
                line_length = 1,
                width = 144,
                height = 142,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(7, 4),
                blend_mode = "additive",
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/assembly/centrifuge/remnants/hr-centrifuge-remnants-highlights.png",
                    line_length = 1,
                    width = 286,
                    height = 284,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(7, 4),
                    blend_mode = "additive",
                    scale = 0.5,
                },
            }
        }
    })

    -- Reskin entities
    entity.idle_animation = {
        layers = {
            -- Centrifuge C
            {
                filename = "__base__/graphics/entity/centrifuge/centrifuge-C.png",
                priority = "high",
                line_length = 8,
                width = 119,
                height = 107,
                frame_count = 64,
                shift = util.by_pixel(-0.5, -26.5),
                hr_version = {
                    filename = "__base__/graphics/entity/centrifuge/hr-centrifuge-C.png",
                    priority = "high",
                    scale = 0.5,
                    line_length = 8,
                    width = 237,
                    height = 214,
                    frame_count = 64,
                    shift = util.by_pixel(-0.25, -26.5)
                }
            },
            {
                filename = "__base__/graphics/entity/centrifuge/centrifuge-C-shadow.png",
                draw_as_shadow = true,
                priority = "high",
                line_length = 8,
                width = 132,
                height = 74,
                frame_count = 64,
                shift = util.by_pixel(20, -10),
                hr_version = {
                    filename = "__base__/graphics/entity/centrifuge/hr-centrifuge-C-shadow.png",
                    draw_as_shadow = true,
                    priority = "high",
                    scale = 0.5,
                    line_length = 8,
                    width = 279,
                    height = 152,
                    frame_count = 64,
                    shift = util.by_pixel(16.75, -10)
                }
            },
            -- Centrifuge B
            {
                filename = "__base__/graphics/entity/centrifuge/centrifuge-B.png",
                priority = "high",
                line_length = 8,
                width = 78,
                height = 117,
                frame_count = 64,
                shift = util.by_pixel(23, 6.5),
                hr_version = {
                    filename = "__base__/graphics/entity/centrifuge/hr-centrifuge-B.png",
                    priority = "high",
                    scale = 0.5,
                    line_length = 8,
                    width = 156,
                    height = 234,
                    frame_count = 64,
                    shift = util.by_pixel(23, 6.5)
                }
            },
            {
                filename = inputs.directory.."/graphics/entity/assembly/centrifuge/centrifuge-B-mask.png",
                priority = "high",
                tint = inputs.tint,
                line_length = 8,
                width = 78,
                height = 117,
                frame_count = 64,
                shift = util.by_pixel(23, 6.5),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/assembly/centrifuge/hr-centrifuge-B-mask.png",
                    priority = "high",
                    tint = inputs.tint,
                    scale = 0.5,
                    line_length = 8,
                    width = 156,
                    height = 234,
                    frame_count = 64,
                    shift = util.by_pixel(23, 6.5)
                }
            },
            {
                filename = inputs.directory.."/graphics/entity/assembly/centrifuge/centrifuge-B-highlights.png",
                priority = "high",
                blend_mode = "additive",
                line_length = 8,
                width = 78,
                height = 117,
                frame_count = 64,
                shift = util.by_pixel(23, 6.5),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/assembly/centrifuge/hr-centrifuge-B-highlights.png",
                    priority = "high",
                    blend_mode = "additive",
                    scale = 0.5,
                    line_length = 8,
                    width = 156,
                    height = 234,
                    frame_count = 64,
                    shift = util.by_pixel(23, 6.5)
                }
            },
            {
                filename = "__base__/graphics/entity/centrifuge/centrifuge-B-shadow.png",
                draw_as_shadow = true,
                priority = "high",
                line_length = 8,
                width = 124,
                height = 74,
                frame_count = 64,
                shift = util.by_pixel(63, 16),
                hr_version = {
                    filename = "__base__/graphics/entity/centrifuge/hr-centrifuge-B-shadow.png",
                    draw_as_shadow = true,
                    priority = "high",
                    scale = 0.5,
                    line_length = 8,
                    width = 251,
                    height = 149,
                    frame_count = 64,
                    shift = util.by_pixel(63.25, 15.25)
                }
            },
            -- Centrifuge A
            {
                filename = "__base__/graphics/entity/centrifuge/centrifuge-A.png",
                priority = "high",
                line_length = 8,
                width = 70,
                height = 123,
                frame_count = 64,
                shift = util.by_pixel(-26, 3.5),
                hr_version = {
                    filename = "__base__/graphics/entity/centrifuge/hr-centrifuge-A.png",
                    priority = "high",
                    scale = 0.5,
                    line_length = 8,
                    width = 139,
                    height = 246,
                    frame_count = 64,
                    shift = util.by_pixel(-26.25, 3.5)
                }
            },
            {
                filename = inputs.directory.."/graphics/entity/assembly/centrifuge/centrifuge-A-mask.png",
                priority = "high",
                tint = inputs.tint,
                line_length = 8,
                width = 70,
                height = 123,
                frame_count = 64,
                shift = util.by_pixel(-26, 3.5),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/assembly/centrifuge/hr-centrifuge-A-mask.png",
                    priority = "high",
                    tint = inputs.tint,
                    scale = 0.5,
                    line_length = 8,
                    width = 139,
                    height = 246,
                    frame_count = 64,
                    shift = util.by_pixel(-26.25, 3.5)
                }
            },
            {
                filename = inputs.directory.."/graphics/entity/assembly/centrifuge/centrifuge-A-highlights.png",
                priority = "high",
                blend_mode = "additive",
                line_length = 8,
                width = 70,
                height = 123,
                frame_count = 64,
                shift = util.by_pixel(-26, 3.5),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/assembly/centrifuge/hr-centrifuge-A-highlights.png",
                    priority = "high",
                    blend_mode = "additive",
                    scale = 0.5,
                    line_length = 8,
                    width = 139,
                    height = 246,
                    frame_count = 64,
                    shift = util.by_pixel(-26.25, 3.5)
                }
            },
            {
                filename = "__base__/graphics/entity/centrifuge/centrifuge-A-shadow.png",
                priority = "high",
                draw_as_shadow = true,
                line_length = 8,
                width = 108,
                height = 54,
                frame_count = 64,
                shift = util.by_pixel(6, 27),
                hr_version = {
                    filename = "__base__/graphics/entity/centrifuge/hr-centrifuge-A-shadow.png",
                    priority = "high",
                    draw_as_shadow = true,
                    scale = 0.5,
                    line_length = 8,
                    width = 230,
                    height = 124,
                    frame_count = 64,
                    shift = util.by_pixel(8.5, 23.5)
                }
            }
        }
    }

    -- Label to skip to next iteration
    ::continue::
end
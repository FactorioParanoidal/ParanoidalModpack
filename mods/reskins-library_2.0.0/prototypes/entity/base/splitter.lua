-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE in the project directory for license information.

-- Check if reskinning needs to be done
if reskins.bobs and (reskins.bobs.triggers.logistics.entities == false) then return end

-- We reskin the base entities only if we're doing custom colors
local use_custom_colors = reskins.lib.setting("reskins-lib-customize-tier-colors")

-- Set input parameters
local inputs = {
    type = "splitter",
    icon_name = "splitter",
    base_entity = "splitter",
    mod = "lib",
    group = "base",
    particles = {["medium"] = 1, ["big"] = 4},
}

-- Handle belt tier labels
inputs.tier_labels = reskins.lib.setting("reskins-bobs-do-belt-entity-tier-labeling") and true or false

local tier_map = {
    ["basic-splitter"] = {tier = 0, sprite_variant = 1},
    ["splitter"] = {tier = 1, sprite_variant = 1, recolor = use_custom_colors},
    ["fast-splitter"] = {tier = 2, sprite_variant = 2, recolor = use_custom_colors},
    ["express-splitter"] = {tier = 3, sprite_variant = 2, recolor = use_custom_colors},
    ["turbo-splitter"] = {tier = 4, sprite_variant = 2},
    ["ultimate-splitter"] = {tier = 5, sprite_variant = 2},
}

-- Reskin entities
for name, map in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Determine what tint we're using
    inputs.tint = reskins.lib.belt_tint_index[map.tier]

    -- Check if we're doing reskin operations on the vanilla splitters
    if map.recolor == false then
        reskins.lib.append_tier_labels_to_vanilla_icon(name, map.tier, inputs)
        goto continue
    end

    reskins.lib.setup_standard_entity(name, map.tier, inputs)

    -- Fetch remnant
    local remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin remnants
    remnant.animation = {
        layers = {
            -- Base
            {
                filename = reskins.lib.directory.."/graphics/entity/base/splitter/remnants/splitter-remnants-base.png",
                line_length = 1,
                width = 96,
                height = 96,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 4,
                shift = util.by_pixel(4, 1.5),
                hr_version = {
                    filename = reskins.lib.directory.."/graphics/entity/base/splitter/remnants/hr-splitter-remnants-base.png",
                    line_length = 1,
                    width = 190,
                    height = 190,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 4,
                    shift = util.by_pixel(3.5, 1.5),
                    scale = 0.5,
                },
            },
            -- Mask
            {
                filename = reskins.lib.directory.."/graphics/entity/base/splitter/remnants/splitter-remnants-mask.png",
                line_length = 1,
                width = 96,
                height = 96,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 4,
                tint = inputs.tint,
                shift = util.by_pixel(4, 1.5),
                hr_version = {
                    filename = reskins.lib.directory.."/graphics/entity/base/splitter/remnants/hr-splitter-remnants-mask.png",
                    line_length = 1,
                    width = 190,
                    height = 190,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 4,
                    tint = inputs.tint,
                    shift = util.by_pixel(3.5, 1.5),
                    scale = 0.5,
                },
            },
            -- Highlights
            {
                filename = reskins.lib.directory.."/graphics/entity/base/splitter/remnants/splitter-remnants-highlights.png",
                line_length = 1,
                width = 96,
                height = 96,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 4,
                blend_mode = reskins.lib.blend_mode,
                shift = util.by_pixel(4, 1.5),
                hr_version = {
                    filename = reskins.lib.directory.."/graphics/entity/base/splitter/remnants/hr-splitter-remnants-highlights.png",
                    line_length = 1,
                    width = 190,
                    height = 190,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 4,
                    blend_mode = reskins.lib.blend_mode,
                    shift = util.by_pixel(3.5, 1.5),
                    scale = 0.5,
                },
            }
        }
    }

    -- Reskin entities
    entity.structure = {
        north = {
            layers = {
                -- Base
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/splitter/north/splitter-north-base.png",
                    frame_count = 32,
                    line_length = 8,
                    priority = "extra-high",
                    width = 82,
                    height = 36,
                    shift = util.by_pixel(6, 0),
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/splitter/north/hr-splitter-north-base.png",
                        frame_count = 32,
                        line_length = 8,
                        priority = "extra-high",
                        width = 160,
                        height = 70,
                        shift = util.by_pixel(7, 0),
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/splitter/north/splitter-north-mask.png",
                    frame_count = 32,
                    line_length = 8,
                    priority = "extra-high",
                    width = 82,
                    height = 36,
                    shift = util.by_pixel(6, 0),
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/splitter/north/hr-splitter-north-mask.png",
                        frame_count = 32,
                        line_length = 8,
                        priority = "extra-high",
                        width = 160,
                        height = 70,
                        shift = util.by_pixel(7, 0),
                        tint = inputs.tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/splitter/north/splitter-north-highlights.png",
                    frame_count = 32,
                    line_length = 8,
                    priority = "extra-high",
                    width = 82,
                    height = 36,
                    shift = util.by_pixel(6, 0),
                    blend_mode = reskins.lib.blend_mode,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/splitter/north/hr-splitter-north-highlights.png",
                        frame_count = 32,
                        line_length = 8,
                        priority = "extra-high",
                        width = 160,
                        height = 70,
                        shift = util.by_pixel(7, 0),
                        blend_mode = reskins.lib.blend_mode,
                        scale = 0.5
                    }
                }
            }
        },
        east = {
            layers = {
                -- Base
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/splitter/east/splitter-east-base.png",
                    frame_count = 32,
                    line_length = 8,
                    priority = "extra-high",
                    width = 46,
                    height = 44,
                    shift = util.by_pixel(4, 12),
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/splitter/east/hr-splitter-east-base.png",
                        frame_count = 32,
                        line_length = 8,
                        priority = "extra-high",
                        width = 90,
                        height = 84,
                        shift = util.by_pixel(4, 13),
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/splitter/east/splitter-east-mask.png",
                    frame_count = 32,
                    line_length = 8,
                    priority = "extra-high",
                    width = 46,
                    height = 44,
                    shift = util.by_pixel(4, 12),
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/splitter/east/hr-splitter-east-mask.png",
                        frame_count = 32,
                        line_length = 8,
                        priority = "extra-high",
                        width = 90,
                        height = 84,
                        shift = util.by_pixel(4, 13),
                        tint = inputs.tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/splitter/east/splitter-east-highlights.png",
                    frame_count = 32,
                    line_length = 8,
                    priority = "extra-high",
                    width = 46,
                    height = 44,
                    shift = util.by_pixel(4, 12),
                    blend_mode = reskins.lib.blend_mode,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/splitter/east/hr-splitter-east-highlights.png",
                        frame_count = 32,
                        line_length = 8,
                        priority = "extra-high",
                        width = 90,
                        height = 84,
                        shift = util.by_pixel(4, 13),
                        blend_mode = reskins.lib.blend_mode,
                        scale = 0.5
                    }
                }
            }
        },
        south = {
            layers = {
                -- Base
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/splitter/south/splitter-south-base.png",
                    frame_count = 32,
                    line_length = 8,
                    priority = "extra-high",
                    width = 82,
                    height = 32,
                    shift = util.by_pixel(4, 0),
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/splitter/south/hr-splitter-south-base.png",
                        frame_count = 32,
                        line_length = 8,
                        priority = "extra-high",
                        width = 164,
                        height = 64,
                        shift = util.by_pixel(4, 0),
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/splitter/south/splitter-south-mask.png",
                    frame_count = 32,
                    line_length = 8,
                    priority = "extra-high",
                    width = 82,
                    height = 32,
                    shift = util.by_pixel(4, 0),
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/splitter/south/hr-splitter-south-mask.png",
                        frame_count = 32,
                        line_length = 8,
                        priority = "extra-high",
                        width = 164,
                        height = 64,
                        shift = util.by_pixel(4, 0),
                        tint = inputs.tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/splitter/south/splitter-south-highlights.png",
                    frame_count = 32,
                    line_length = 8,
                    priority = "extra-high",
                    width = 82,
                    height = 32,
                    shift = util.by_pixel(4, 0),
                    blend_mode = reskins.lib.blend_mode,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/splitter/south/hr-splitter-south-highlights.png",
                        frame_count = 32,
                        line_length = 8,
                        priority = "extra-high",
                        width = 164,
                        height = 64,
                        shift = util.by_pixel(4, 0),
                        blend_mode = reskins.lib.blend_mode,
                        scale = 0.5
                    }
                }
            }
        },
        west = {
            layers = {
                -- Base
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/splitter/west/splitter-west-base.png",
                    frame_count = 32,
                    line_length = 8,
                    priority = "extra-high",
                    width = 46,
                    height = 44,
                    shift = util.by_pixel(6, 12),
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/splitter/west/hr-splitter-west-base.png",
                        frame_count = 32,
                        line_length = 8,
                        priority = "extra-high",
                        width = 94,
                        height = 86,
                        shift = util.by_pixel(5, 12),
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/splitter/west/splitter-west-mask.png",
                    frame_count = 32,
                    line_length = 8,
                    priority = "extra-high",
                    width = 46,
                    height = 44,
                    shift = util.by_pixel(6, 12),
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/splitter/west/hr-splitter-west-mask.png",
                        frame_count = 32,
                        line_length = 8,
                        priority = "extra-high",
                        width = 94,
                        height = 86,
                        shift = util.by_pixel(5, 12),
                        tint = inputs.tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/splitter/west/splitter-west-highlights.png",
                    frame_count = 32,
                    line_length = 8,
                    priority = "extra-high",
                    width = 46,
                    height = 44,
                    shift = util.by_pixel(6, 12),
                    blend_mode = reskins.lib.blend_mode,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/splitter/west/hr-splitter-west-highlights.png",
                        frame_count = 32,
                        line_length = 8,
                        priority = "extra-high",
                        width = 94,
                        height = 86,
                        shift = util.by_pixel(5, 12),
                        blend_mode = reskins.lib.blend_mode,
                        scale = 0.5
                    }
                }
            }
        }
    }

    entity.structure_patch =
    {
        north = util.empty_sprite(),
        east = {
            layers = {
                -- Base
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/splitter/east/splitter-east-top_patch-base.png",
                    frame_count = 32,
                    line_length = 8,
                    priority = "extra-high",
                    width = 46,
                    height = 52,
                    shift = util.by_pixel(4, -20),
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/splitter/east/hr-splitter-east-top_patch-base.png",
                        frame_count = 32,
                        line_length = 8,
                        priority = "extra-high",
                        width = 90,
                        height = 104,
                        shift = util.by_pixel(4, -20),
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/splitter/east/splitter-east-top_patch-mask.png",
                    frame_count = 32,
                    line_length = 8,
                    priority = "extra-high",
                    width = 46,
                    height = 52,
                    shift = util.by_pixel(4, -20),
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/splitter/east/hr-splitter-east-top_patch-mask.png",
                        frame_count = 32,
                        line_length = 8,
                        priority = "extra-high",
                        width = 90,
                        height = 104,
                        shift = util.by_pixel(4, -20),
                        tint = inputs.tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/splitter/east/splitter-east-top_patch-highlights.png",
                    frame_count = 32,
                    line_length = 8,
                    priority = "extra-high",
                    width = 46,
                    height = 52,
                    shift = util.by_pixel(4, -20),
                    blend_mode = reskins.lib.blend_mode,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/splitter/east/hr-splitter-east-top_patch-highlights.png",
                        frame_count = 32,
                        line_length = 8,
                        priority = "extra-high",
                        width = 90,
                        height = 104,
                        shift = util.by_pixel(4, -20),
                        blend_mode = reskins.lib.blend_mode,
                        scale = 0.5
                    }
                }
            }
        },
        south = util.empty_sprite(),
        west = {
            layers = {
                -- Base
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/splitter/west/splitter-west-top_patch-base.png",
                    frame_count = 32,
                    line_length = 8,
                    priority = "extra-high",
                    width = 46,
                    height = 48,
                    shift = util.by_pixel(6, -18),
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/splitter/west/hr-splitter-west-top_patch-base.png",
                        frame_count = 32,
                        line_length = 8,
                        priority = "extra-high",
                        width = 94,
                        height = 96,
                        shift = util.by_pixel(5, -18),
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/splitter/west/splitter-west-top_patch-mask.png",
                    frame_count = 32,
                    line_length = 8,
                    priority = "extra-high",
                    width = 46,
                    height = 48,
                    shift = util.by_pixel(6, -18),
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/splitter/west/hr-splitter-west-top_patch-mask.png",
                        frame_count = 32,
                        line_length = 8,
                        priority = "extra-high",
                        width = 94,
                        height = 96,
                        shift = util.by_pixel(5, -18),
                        tint = inputs.tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/splitter/west/splitter-west-top_patch-highlights.png",
                    frame_count = 32,
                    line_length = 8,
                    priority = "extra-high",
                    width = 46,
                    height = 48,
                    shift = util.by_pixel(6, -18),
                    blend_mode = reskins.lib.blend_mode,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/splitter/west/hr-splitter-west-top_patch-highlights.png",
                        frame_count = 32,
                        line_length = 8,
                        priority = "extra-high",
                        width = 94,
                        height = 96,
                        shift = util.by_pixel(5, -18),
                        blend_mode = reskins.lib.blend_mode,
                        scale = 0.5
                    }
                }
            }
        }
    }

    -- Apply belt set
    entity.belt_animation_set = reskins.lib.transport_belt_animation_set(inputs.tint, map.sprite_variant)

    -- Label to skip to next iteration
    ::continue::
end
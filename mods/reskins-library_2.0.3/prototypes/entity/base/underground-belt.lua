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
    type = "underground-belt",
    icon_name = "underground-belt",
    base_entity = "underground-belt",
    mod = "lib",
    group = "base",
    particles = {["medium"] = 3, ["small"] = 2},
}

-- Handle belt tier labels
inputs.tier_labels = reskins.lib.setting("reskins-bobs-do-belt-entity-tier-labeling") and true or false

local tier_map = {
    ["basic-underground-belt"] = {tier = 0, sprite_variant = 1},
    ["underground-belt"] = {tier = 1, sprite_variant = 1, recolor = use_custom_colors},
    ["fast-underground-belt"] = {tier = 2, sprite_variant = 2, recolor = use_custom_colors},
    ["express-underground-belt"] = {tier = 3, sprite_variant = 2, recolor = use_custom_colors},
    ["turbo-underground-belt"] = {tier = 4, sprite_variant = 2},
    ["ultimate-underground-belt"] = {tier = 5, sprite_variant = 2},
}

-- Reskin entities
for name, map in pairs(tier_map) do
    -- Initialize paths
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
        layers= {
            -- Base
            {
                filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/remnants/underground-belt-remnants-base.png",
                line_length = 1,
                width = 78,
                height = 72,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 8,
                shift = util.by_pixel(10, 3),
                hr_version = {
                    filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/remnants/hr-underground-belt-remnants-base.png",
                    line_length = 1,
                    width = 156,
                    height = 144,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 8,
                    shift = util.by_pixel(10.5, 3),
                    scale = 0.5,
                },
            },
            -- Mask
            {
                filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/remnants/underground-belt-remnants-mask.png",
                line_length = 1,
                width = 78,
                height = 72,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 8,
                tint = inputs.tint,
                shift = util.by_pixel(10, 3),
                hr_version = {
                    filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/remnants/hr-underground-belt-remnants-mask.png",
                    line_length = 1,
                    width = 156,
                    height = 144,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 8,
                    tint = inputs.tint,
                    shift = util.by_pixel(10.5, 3),
                    scale = 0.5,
                },
            },
            -- Highlights
            {
                filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/remnants/underground-belt-remnants-highlights.png",
                line_length = 1,
                width = 78,
                height = 72,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 8,
                blend_mode = reskins.lib.blend_mode,
                shift = util.by_pixel(10, 3),
                hr_version = {
                    filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/remnants/hr-underground-belt-remnants-highlights.png",
                    line_length = 1,
                    width = 156,
                    height = 144,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 8,
                    blend_mode = reskins.lib.blend_mode,
                    shift = util.by_pixel(10.5, 3),
                    scale = 0.5,
                },
            }
        }
    }

    -- Reskin entities
    entity.structure = {
        direction_in = {
            sheets = {
                -- Base
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/underground-belt-structure.png",
                    priority = "extra-high",
                    width = 96,
                    height = 96,
                    y = 96,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/hr-underground-belt-structure.png",
                        priority = "extra-high",
                        width = 192,
                        height = 192,
                        y = 192,
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/underground-belt-structure-mask.png",
                    priority = "extra-high",
                    width = 96,
                    height = 96,
                    y = 96,
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/hr-underground-belt-structure-mask.png",
                        priority = "extra-high",
                        width = 192,
                        height = 192,
                        y = 192,
                        tint = inputs.tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/underground-belt-structure-highlights.png",
                    priority = "extra-high",
                    width = 96,
                    height = 96,
                    y = 96,
                    blend_mode = reskins.lib.blend_mode,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/hr-underground-belt-structure-highlights.png",
                        priority = "extra-high",
                        width = 192,
                        height = 192,
                        y = 192,
                        blend_mode = reskins.lib.blend_mode,
                        scale = 0.5
                    }
                }
            }
        },
        direction_out = {
            sheets = {
                -- Base
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/underground-belt-structure.png",
                    priority = "extra-high",
                    width = 96,
                    height = 96,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/hr-underground-belt-structure.png",
                        priority = "extra-high",
                        width = 192,
                        height =192,
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/underground-belt-structure-mask.png",
                    priority = "extra-high",
                    width = 96,
                    height = 96,
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/hr-underground-belt-structure-mask.png",
                        priority = "extra-high",
                        width = 192,
                        height =192,
                        tint = inputs.tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/underground-belt-structure-highlights.png",
                    priority = "extra-high",
                    width = 96,
                    height = 96,
                    blend_mode = reskins.lib.blend_mode,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/hr-underground-belt-structure-highlights.png",
                        priority = "extra-high",
                        width = 192,
                        height =192,
                        blend_mode = reskins.lib.blend_mode,
                        scale = 0.5
                    }
                }
            }
        },
        direction_in_side_loading = {
            sheets = {
                -- Base
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/underground-belt-structure.png",
                    priority = "extra-high",
                    width = 96,
                    height = 96,
                    y = 96*3,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/hr-underground-belt-structure.png",
                        priority = "extra-high",
                        width = 192,
                        height = 192,
                        y = 192*3,
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/underground-belt-structure-mask.png",
                    priority = "extra-high",
                    width = 96,
                    height = 96,
                    y = 96*3,
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/hr-underground-belt-structure-mask.png",
                        priority = "extra-high",
                        width = 192,
                        height = 192,
                        y = 192*3,
                        tint = inputs.tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/underground-belt-structure-highlights.png",
                    priority = "extra-high",
                    width = 96,
                    height = 96,
                    y = 96*3,
                    blend_mode = reskins.lib.blend_mode,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/hr-underground-belt-structure-highlights.png",
                        priority = "extra-high",
                        width = 192,
                        height = 192,
                        y = 192*3,
                        blend_mode = reskins.lib.blend_mode,
                        scale = 0.5
                    }
                }
            }
        },
        direction_out_side_loading = {
            sheets = {
                -- Base
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/underground-belt-structure.png",
                    priority = "extra-high",
                    width = 96,
                    height = 96,
                    y = 96*2,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/hr-underground-belt-structure.png",
                        priority = "extra-high",
                        width = 192,
                        height = 192,
                        y = 192*2,
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/underground-belt-structure-mask.png",
                    priority = "extra-high",
                    width = 96,
                    height = 96,
                    y = 96*2,
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/hr-underground-belt-structure-mask.png",
                        priority = "extra-high",
                        width = 192,
                        height = 192,
                        y = 192*2,
                        tint = inputs.tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/underground-belt-structure-highlights.png",
                    priority = "extra-high",
                    width = 96,
                    height = 96,
                    y = 96*2,
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/hr-underground-belt-structure-highlights.png",
                        priority = "extra-high",
                        width = 192,
                        height = 192,
                        y = 192*2,
                        tint = inputs.tint,
                        scale = 0.5
                    }
                }
            }
        },
        back_patch = {
            sheet = {
                filename = "__base__/graphics/entity/express-underground-belt/express-underground-belt-structure-back-patch.png",
                priority = "extra-high",
                width = 96,
                height = 96,
                hr_version = {
                    filename = "__base__/graphics/entity/express-underground-belt/hr-express-underground-belt-structure-back-patch.png",
                    priority = "extra-high",
                    width = 192,
                    height = 192,
                    scale = 0.5
                }
            }
        },
        front_patch = {
            sheet = {
                filename = "__base__/graphics/entity/express-underground-belt/express-underground-belt-structure-front-patch.png",
                priority = "extra-high",
                width = 96,
                height = 96,
                hr_version = {
                    filename = "__base__/graphics/entity/express-underground-belt/hr-express-underground-belt-structure-front-patch.png",
                    priority = "extra-high",
                    width = 192,
                    height = 192,
                    scale = 0.5
                }
            }
        }
    }

    -- Apply belt set
    -- entity.belt_animation_set = reskins.lib.transport_belt_animation_set(inputs.tint, map.sprite_variant)

    -- Label to skip to next iteration
    ::continue::
end
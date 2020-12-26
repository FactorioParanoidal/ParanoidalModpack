-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["boblogistics"] then return end
if reskins.lib.setting("reskins-bobs-do-boblogistics") == false then return end

-- We reskin the base entities only if we're doing custom colors
local custom_colors = true
if reskins.lib.setting("reskins-lib-customize-tier-colors") == false then
    custom_colors = false
end

-- Set input parameters
local inputs = {
    type = "underground-belt",
    icon_name = "underground-belt",
    base_entity = "underground-belt",
    mod = "bobs",
    group = "logistics",
    particles = {["medium"] = 3, ["small"] = 2},
    icon_layers = 2,
}

-- Handle belt tier labels
if reskins.lib.setting("reskins-bobs-do-belt-entity-tier-labeling") == true then
    inputs.tier_labels = true
end

local tier_map = {
    ["basic-underground-belt"] = {0, 1, true, true},
    ["underground-belt"] = {1, 1, custom_colors},
    ["fast-underground-belt"] = {2, 2, custom_colors},
    ["express-underground-belt"] = {3, 2, custom_colors},
    ["turbo-underground-belt"] = {4, 2, true},
    ["ultimate-underground-belt"] = {5, 2, true},
}

-- Reskin entities
for name, map in pairs(tier_map) do
    -- Initialize paths
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Parse map
    local tier = map[1]
    local variant = map[2]
    local do_reskin = map[3]

    -- Determine what tint we're using
    inputs.tint = reskins.bobs.belt_tint_handling(name, tier)

    -- Check if we're doing reskin operations on the vanilla splitters
    if do_reskin == false then
        reskins.lib.append_tier_labels_to_vanilla_icon(name, tier, inputs)
        goto continue
    end

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Fetch remnant
    local remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin remnants
    remnant.animation = {
        layers= {
            -- Base
            {
                filename = reskins.bobs.directory.."/graphics/entity/logistics/underground-belt/remnants/underground-belt-remnants-base.png",
                line_length = 1,
                width = 78,
                height = 72,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 8,
                shift = util.by_pixel(10, 3),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/underground-belt/remnants/hr-underground-belt-remnants-base.png",
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
                filename = reskins.bobs.directory.."/graphics/entity/logistics/underground-belt/remnants/underground-belt-remnants-mask.png",
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
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/underground-belt/remnants/hr-underground-belt-remnants-mask.png",
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
            }
        }
    }

    -- Reskin entities
    entity.structure = {
        direction_in = {
            sheets = {
                -- Base
                {
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/underground-belt/underground-belt-structure.png",
                    priority = "extra-high",
                    width = 96,
                    height = 96,
                    y = 96,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/logistics/underground-belt/hr-underground-belt-structure.png",
                        priority = "extra-high",
                        width = 192,
                        height = 192,
                        y = 192,
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/underground-belt/underground-belt-structure-mask.png",
                    priority = "extra-high",
                    width = 96,
                    height = 96,
                    y = 96,
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/logistics/underground-belt/hr-underground-belt-structure-mask.png",
                        priority = "extra-high",
                        width = 192,
                        height = 192,
                        y = 192,
                        tint = inputs.tint,
                        scale = 0.5
                    }
                }
            }
        },
        direction_out = {
            sheets = {
                -- Base
                {
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/underground-belt/underground-belt-structure.png",
                    priority = "extra-high",
                    width = 96,
                    height = 96,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/logistics/underground-belt/hr-underground-belt-structure.png",
                        priority = "extra-high",
                        width = 192,
                        height =192,
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/underground-belt/underground-belt-structure-mask.png",
                    priority = "extra-high",
                    width = 96,
                    height = 96,
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/logistics/underground-belt/hr-underground-belt-structure-mask.png",
                        priority = "extra-high",
                        width = 192,
                        height =192,
                        tint = inputs.tint,
                        scale = 0.5
                    }
                }
            }
        },
        direction_in_side_loading = {
            sheets = {
                -- Base
                {
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/underground-belt/underground-belt-structure.png",
                    priority = "extra-high",
                    width = 96,
                    height = 96,
                    y = 96*3,
                    hr_version =
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/logistics/underground-belt/hr-underground-belt-structure.png",
                        priority = "extra-high",
                        width = 192,
                        height = 192,
                        y = 192*3,
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/underground-belt/underground-belt-structure-mask.png",
                    priority = "extra-high",
                    width = 96,
                    height = 96,
                    y = 96*3,
                    tint = inputs.tint,
                    hr_version =
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/logistics/underground-belt/hr-underground-belt-structure-mask.png",
                        priority = "extra-high",
                        width = 192,
                        height = 192,
                        y = 192*3,
                        tint = inputs.tint,
                        scale = 0.5
                    }
                }
            }
        },
        direction_out_side_loading = {
            sheets = {
                -- Base
                {
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/underground-belt/underground-belt-structure.png",
                    priority = "extra-high",
                    width = 96,
                    height = 96,
                    y = 96*2,
                    hr_version =
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/logistics/underground-belt/hr-underground-belt-structure.png",
                        priority = "extra-high",
                        width = 192,
                        height = 192,
                        y = 192*2,
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/entity/logistics/underground-belt/underground-belt-structure-mask.png",
                    priority = "extra-high",
                    width = 96,
                    height = 96,
                    y = 96*2,
                    tint = inputs.tint,
                    hr_version =
                    {
                        filename = reskins.bobs.directory.."/graphics/entity/logistics/underground-belt/hr-underground-belt-structure-mask.png",
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
                hr_version =
                {
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
                hr_version =
                {
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
    entity.belt_animation_set = reskins.bobs.transport_belt_animation_set(inputs.tint, variant)

    -- Label to skip to next iteration
    ::continue::
end
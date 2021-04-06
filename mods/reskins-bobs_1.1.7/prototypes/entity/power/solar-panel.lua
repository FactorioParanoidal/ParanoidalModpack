-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.power.entities) then return end
if reskins.lib.setting("bobmods-power-solar") == false then return end

-- Set input parameters
local inputs = {
    type = "solar-panel",
    base_entity = "solar-panel",
    mod = "bobs",
    group = "power",
    particles = {["small"] = 2},
}

local tier_map = {
    ["solar-panel-small"] = {1, 2},
    ["solar-panel-small-2"] = {2, 3},
    ["solar-panel-small-3"] = {3, 4},
    ["solar-panel"] = {1, 2},
    ["solar-panel-2"] = {2, 3},
    ["solar-panel-3"] = {3, 4},
    ["solar-panel-large"] = {1, 2},
    ["solar-panel-large-2"] = {2, 3},
    ["solar-panel-large-3"] = {3, 4},
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

    -- Setup icon name details
    if string.find(name, "small", 1, true) then
        inputs.icon_name = "solar-panel-small"
    elseif string.find(name, "large", 1, true) then
        inputs.icon_name = "solar-panel-large"
    else
        inputs.icon_name = "solar-panel"
    end

    -- Setup additional icon details
    inputs.icon_extras = {
        -- Type indicator
        {
            icon = reskins.bobs.directory.."/graphics/icons/power/"..inputs.icon_name.."/"..inputs.icon_name.."-icon-type.png"
        },
        {
            icon = reskins.bobs.directory.."/graphics/icons/power/"..inputs.icon_name.."/"..inputs.icon_name.."-icon-type.png",
            tint = reskins.lib.adjust_alpha(reskins.lib.tint_index[tier], 0.75)
        }
    }

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index[tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Fetch remnants
    local remnant = data.raw["corpse"][name.."-remnants"]

    -- Reskin entities
    if inputs.icon_name == "solar-panel-small" then
        -- Reskin remnants
        remnant.animation = make_rotated_animation_variations_from_sheet (2, {
            layers = {
                -- Base
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-small/remnants/small-solar-panel-remnants-base.png",
                    line_length = 1,
                    width = 123,
                    height = 99,
                    frame_count = 1,
                    variation_count = 1,
                    direction_count = 1,
                    shift = util.by_pixel(-1, -0.5),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-small/remnants/hr-small-solar-panel-remnants-base.png",
                        line_length = 1,
                        width = 246,
                        height = 198,
                        frame_count = 1,
                        variation_count = 1,
                        direction_count = 1,
                        shift = util.by_pixel(-1, -0.5),
                        scale = 0.5,
                    },
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-small/remnants/small-solar-panel-remnants-mask.png",
                    line_length = 1,
                    width = 123,
                    height = 99,
                    frame_count = 1,
                    variation_count = 1,
                    direction_count = 1,
                    shift = util.by_pixel(-1, -0.5),
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-small/remnants/hr-small-solar-panel-remnants-mask.png",
                        line_length = 1,
                        width = 246,
                        height = 198,
                        frame_count = 1,
                        variation_count = 1,
                        direction_count = 1,
                        shift = util.by_pixel(-1, -0.5),
                        tint = inputs.tint,
                        scale = 0.5,
                    },
                },
                -- Highlights
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-small/remnants/small-solar-panel-remnants-highlights.png",
                    line_length = 1,
                    width = 123,
                    height = 99,
                    frame_count = 1,
                    variation_count = 1,
                    direction_count = 1,
                    shift = util.by_pixel(-1, -0.5),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-small/remnants/hr-small-solar-panel-remnants-highlights.png",
                        line_length = 1,
                        width = 246,
                        height = 198,
                        frame_count = 1,
                        variation_count = 1,
                        direction_count = 1,
                        shift = util.by_pixel(-1, -0.5),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5,
                    },
                }
            }
        })

        -- Overwrite picture table in target entity
        entity.picture = {
            layers = {
                -- Base
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-small/base/solar-panel-small.png",
                    priority = "high",
                    width = 90,
                    height = 75,
                    shift = util.by_pixel(5, 0.5),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-small/base/hr-solar-panel-small.png",
                        priority = "high",
                        width = 180,
                        height = 150,
                        shift = util.by_pixel(5, 0.5),
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-small/solar-panel-small-mask.png",
                    priority = "high",
                    width = 90,
                    height = 75,
                    shift = util.by_pixel(5, 0.5),
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-small/hr-solar-panel-small-mask.png",
                        priority = "high",
                        width = 180,
                        height = 150,
                        shift = util.by_pixel(5, 0.5),
                        tint = inputs.tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-small/solar-panel-small-highlights.png",
                    priority = "high",
                    width = 90,
                    height = 75,
                    shift = util.by_pixel(5, 0.5),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-small/hr-solar-panel-small-highlights.png",
                        priority = "high",
                        width = 180,
                        height = 150,
                        shift = util.by_pixel(5, 0.5),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5
                    }
                },
                -- Shadow
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-small/base/solar-panel-small-shadow.png",
                    priority = "high",
                    width = 90,
                    height = 75,
                    shift = util.by_pixel(5, 0.5),
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-small/base/hr-solar-panel-small-shadow.png",
                        priority = "high",
                        width = 180,
                        height = 150,
                        shift = util.by_pixel(5, 0.5),
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                }
            }
        }

        -- Overwrite or create overlay table in target entity
        entity.overlay = {
            layers = {
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-small/base/solar-panel-small-shadow-overlay.png",
                    priority = "high",
                    width = 90,
                    height = 75,
                    shift = util.by_pixel(5, 0.5),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-small/base/hr-solar-panel-small-shadow-overlay.png",
                        priority = "high",
                        width = 180,
                        height = 150,
                        shift = util.by_pixel(5, 0.5),
                        scale = 0.5
                    }
                }
            }
        }
    elseif inputs.icon_name == "solar-panel" then
        -- Reskin remnants
        remnant.animation = make_rotated_animation_variations_from_sheet (2, {
            layers = {
                -- Base
                {
                    filename = "__base__/graphics/entity/solar-panel/remnants/solar-panel-remnants.png",
                    line_length = 1,
                    width = 146,
                    height = 142,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(4, 0),
                    hr_version = {
                        filename = "__base__/graphics/entity/solar-panel/remnants/hr-solar-panel-remnants.png",
                        line_length = 1,
                        width = 290,
                        height = 282,
                        frame_count = 1,
                        variation_count = 1,
                        axially_symmetrical = false,
                        direction_count = 1,
                        shift = util.by_pixel(3.5, 0),
                        scale = 0.5,
                    },
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel/remnants/solar-panel-remnants-mask.png",
                    line_length = 1,
                    width = 146,
                    height = 142,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(4, 0),
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel/remnants/hr-solar-panel-remnants-mask.png",
                        line_length = 1,
                        width = 290,
                        height = 282,
                        frame_count = 1,
                        variation_count = 1,
                        axially_symmetrical = false,
                        direction_count = 1,
                        shift = util.by_pixel(3.5, 0),
                        tint = inputs.tint,
                        scale = 0.5,
                    },
                },
                -- Highlights
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel/remnants/solar-panel-remnants-highlights.png",
                    line_length = 1,
                    width = 146,
                    height = 142,
                    frame_count = 1,
                    variation_count = 1,
                    axially_symmetrical = false,
                    direction_count = 1,
                    shift = util.by_pixel(4, 0),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel/remnants/hr-solar-panel-remnants-highlights.png",
                        line_length = 1,
                        width = 290,
                        height = 282,
                        frame_count = 1,
                        variation_count = 1,
                        axially_symmetrical = false,
                        direction_count = 1,
                        shift = util.by_pixel(3.5, 0),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5,
                    },
                }

            }
        })

        -- Overwrite picture table in target entity
        entity.picture = {
            layers = {
                -- Base
                {
                    filename = "__base__/graphics/entity/solar-panel/solar-panel.png",
                    priority = "high",
                    width = 116,
                    height = 112,
                    shift = util.by_pixel(-3, 3),
                    hr_version = {
                        filename = "__base__/graphics/entity/solar-panel/hr-solar-panel.png",
                        priority = "high",
                        width = 230,
                        height = 224,
                        shift = util.by_pixel(-3, 3.5),
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel/solar-panel-mask.png",
                    priority = "high",
                    width = 116,
                    height = 112,
                    shift = util.by_pixel(-3, 3),
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel/hr-solar-panel-mask.png",
                        priority = "high",
                        width = 230,
                        height = 224,
                        shift = util.by_pixel(-3, 3.5),
                        tint = inputs.tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel/solar-panel-highlights.png",
                    priority = "high",
                    width = 116,
                    height = 112,
                    shift = util.by_pixel(-3, 3),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel/hr-solar-panel-highlights.png",
                        priority = "high",
                        width = 230,
                        height = 224,
                        shift = util.by_pixel(-3, 3.5),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5
                    }
                },
                -- Shadow
                {
                    filename = "__base__/graphics/entity/solar-panel/solar-panel-shadow.png",
                    priority = "high",
                    width = 112,
                    height = 90,
                    shift = util.by_pixel(10, 6),
                    draw_as_shadow = true,
                    hr_version = {
                        filename = "__base__/graphics/entity/solar-panel/hr-solar-panel-shadow.png",
                        priority = "high",
                        width = 220,
                        height = 180,
                        shift = util.by_pixel(9.5, 6),
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                }
            }
        }

        -- Overwrite or create overlay table in target entity
        entity.overlay = {
            layers = {
                {
                    filename = "__base__/graphics/entity/solar-panel/solar-panel-shadow-overlay.png",
                    priority = "high",
                    width = 108,
                    height = 90,
                    shift = util.by_pixel(11, 6),
                    hr_version = {
                        filename = "__base__/graphics/entity/solar-panel/hr-solar-panel-shadow-overlay.png",
                        priority = "high",
                        width = 214,
                        height = 180,
                        shift = util.by_pixel(10.5, 6),
                        scale = 0.5
                    }
                }
            }
        }
    elseif inputs.icon_name == "solar-panel-large" then
        -- TODO: Large remnants

        -- Overwrite picture table in target entity
        entity.picture = {
            layers = {
                -- Base
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-large/base/solar-panel-large.png",
                    priority = "high",
                    width = 154,
                    height = 137,
                    shift = util.by_pixel(5, 3.5),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-large/base/hr-solar-panel-large.png",
                        priority = "high",
                        width = 308,
                        height = 274,
                        shift = util.by_pixel(5, 3.5),
                        scale = 0.5
                    }
                },
                -- Mask
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-large/solar-panel-large-mask.png",
                    priority = "high",
                    width = 154,
                    height = 137,
                    shift = util.by_pixel(5, 3.5),
                    tint = inputs.tint,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-large/hr-solar-panel-large-mask.png",
                        priority = "high",
                        width = 308,
                        height = 274,
                        shift = util.by_pixel(5, 3.5),
                        tint = inputs.tint,
                        scale = 0.5
                    }
                },
                -- Highlights
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-large/solar-panel-large-highlights.png",
                    priority = "high",
                    width = 154,
                    height = 137,
                    shift = util.by_pixel(5, 3.5),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-large/hr-solar-panel-large-highlights.png",
                        priority = "high",
                        width = 308,
                        height = 274,
                        shift = util.by_pixel(5, 3.5),
                        blend_mode = reskins.lib.blend_mode, -- "additive",
                        scale = 0.5
                    }
                },
                -- Shadow
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-large/base/solar-panel-large-shadow.png",
                    priority = "high",
                    width = 154,
                    height = 137,
                    shift = util.by_pixel(5, 3.5),
                    draw_as_shadow = true,
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-large/base/hr-solar-panel-large-shadow.png",
                        priority = "high",
                        width = 308,
                        height = 274,
                        shift = util.by_pixel(5, 3.5),
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                }
            }
        }

        -- Overwrite or create overlay table in target entity
        entity.overlay = {
            layers = {
                {
                    filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-large/base/solar-panel-large-shadow-overlay.png",
                    priority = "high",
                    width = 154,
                    height = 137,
                    shift = util.by_pixel(5, 3.5),
                    hr_version = {
                        filename = reskins.bobs.directory.."/graphics/entity/power/solar-panel-large/base/hr-solar-panel-large-shadow-overlay.png",
                        priority = "high",
                        width = 308,
                        height = 274,
                        shift = util.by_pixel(5, 3.5),
                        scale = 0.5
                    }
                }
            }
        }
    end

    -- Label to skip to next iteration
    ::continue::
end
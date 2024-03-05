-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

---Provides vanilla-style sprite definition for underground belt corpse `animation` field. See [Prototype/Corpse](https://wiki.factorio.com/Prototype/Corpse).
---@param tint table # [Types/Color](https://wiki.factorio.com/Types/Color)
---@return table animation # [Types/RotatedAnimation](https://wiki.factorio.com/Types/RotatedAnimation)
local function corpse_animation(tint)
    return
    {
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
                tint = tint,
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
                    tint = tint,
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
end

---Provides vanilla-style sprite definition for underground belt `structure` field. See [Prototype/UndergroundBelt](https://wiki.factorio.com/Prototype/UndergroundBelt).
---@param tint table # [Types/Color](https://wiki.factorio.com/Types/Color)
---@return table structure # [UndergroundBelt structure](https://wiki.factorio.com/Prototype/UndergroundBelt#structure)
local function entity_structure(tint)
    return
    {
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
                    tint = tint,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/hr-underground-belt-structure-mask.png",
                        priority = "extra-high",
                        width = 192,
                        height = 192,
                        y = 192,
                        tint = tint,
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
                    tint = tint,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/hr-underground-belt-structure-mask.png",
                        priority = "extra-high",
                        width = 192,
                        height =192,
                        tint = tint,
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
                    tint = tint,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/hr-underground-belt-structure-mask.png",
                        priority = "extra-high",
                        width = 192,
                        height = 192,
                        y = 192*3,
                        tint = tint,
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
                    tint = tint,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/hr-underground-belt-structure-mask.png",
                        priority = "extra-high",
                        width = 192,
                        height = 192,
                        y = 192*2,
                        tint = tint,
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
                    tint = tint,
                    hr_version = {
                        filename = reskins.lib.directory.."/graphics/entity/base/underground-belt/hr-underground-belt-structure-highlights.png",
                        priority = "extra-high",
                        width = 192,
                        height = 192,
                        y = 192*2,
                        tint = tint,
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
end

---Reskins the named underground-belt with vanilla-style underground belt sprites and color masking, and sets up appropriate corpse, explosion, and particle prototypes
---@param name string # [Prototype name](https://wiki.factorio.com/PrototypeBase#name)
---@param tier integer # 1-6 are supported, 0 to disable
---@param tint? table # [Types/Color](https://wiki.factorio.com/Types/Color)
---@param make_tier_labels? boolean
---@param reskin_vanilla_entity? boolean
function reskins.lib.apply_skin.underground_belt(name, tier, tint, make_tier_labels, reskin_vanilla_entity)
    ---@type inputs.setup_standard_entity
    local inputs = {
        type = "underground-belt",
        icon_name = "underground-belt",
        base_entity_name = "underground-belt",
        mod = "lib",
        group = "base",
        particles = {["medium"] = 3, ["small"] = 2},
        tier_labels = make_tier_labels or false,
        tint = tint and tint or reskins.lib.belt_tint_index[tier]
    }

    local entity = data.raw[inputs.type][name]
    if not entity then return end

    if reskin_vanilla_entity == false then
        reskins.lib.append_tier_labels_to_vanilla_icon(name, tier, inputs)
        return
    end

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Fetch corpse
    local corpse = data.raw["corpse"][name.."-remnants"]

    -- Reskin corpse
    corpse.animation = corpse_animation(inputs.tint)

    -- Reskin entity
    entity.structure = entity_structure(inputs.tint)
end
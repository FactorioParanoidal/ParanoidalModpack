-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["vanilla-loaders-hd"] then return end
if reskins.bobs and (reskins.bobs.triggers.logistics.entities == false) then return end

-- Set input parameters
local inputs = {
    type = "loader",
    icon_name = "loader",
    base_entity_name = "splitter",
    mod = "compatibility",
    group = "vanilla-loaders-hd",
    particles = {["medium"] = 1, ["big"] = 4},
    make_remnants = false,
}

-- Handle belt tier labels
inputs.tier_labels = reskins.lib.setting("reskins-bobs-do-belt-entity-tier-labeling") and true or false

local tier_map = {
    ["basic-loader"] = {tier = 0, sprite_variation = 1},
    ["loader"] = {tier = 1, sprite_variation = 1},
    ["fast-loader"] = {tier = 2, sprite_variation = 2},
    ["express-loader"] = {tier = 3, sprite_variation = 2},
    ["purple-loader"] = {tier = 4, sprite_variation = 2},
    ["green-loader"] = {tier = 5, sprite_variation = 2},
}

-- Reskin entities
for name, map in pairs(tier_map) do
    -- Fetch entity, item
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Determine what tint we're using
    inputs.tint = reskins.lib.belt_tint_index[map.tier]

    reskins.lib.setup_standard_entity(name, map.tier, inputs)

    -- Retint the entity mask
    entity.structure.direction_in.sheets = {
        -- Base
        {
            filename = reskins.compatibility.directory.."/graphics/entity/vanilla-loaders-hd/loader/loader-structure-base.png",
            priority = "extra-high",
            width = 106,
            height = 96,
            hr_version = {
                filename = reskins.compatibility.directory.."/graphics/entity/vanilla-loaders-hd/loader/hr-loader-structure-base.png",
                priority = "extra-high",
                width = 212,
                height = 192,
                scale = 0.5,
            }
        },
        -- Mask
        {
            filename = reskins.compatibility.directory.."/graphics/entity/vanilla-loaders-hd/loader/loader-structure-mask.png",
            priority = "extra-high",
            width = 106,
            height = 96,
            tint = inputs.tint,
            hr_version = {
                filename = reskins.compatibility.directory.."/graphics/entity/vanilla-loaders-hd/loader/hr-loader-structure-mask.png",
                priority = "extra-high",
                width = 212,
                height = 192,
                tint = inputs.tint,
                scale = 0.5,
            }
        },
        -- Highlights
        {
            filename = reskins.compatibility.directory.."/graphics/entity/vanilla-loaders-hd/loader/loader-structure-highlights.png",
            priority = "extra-high",
            width = 106,
            height = 96,
            blend_mode = "additive",
            hr_version = {
                filename = reskins.compatibility.directory.."/graphics/entity/vanilla-loaders-hd/loader/hr-loader-structure-highlights.png",
                priority = "extra-high",
                width = 212,
                height = 192,
                blend_mode = "additive",
                scale = 0.5,
            }
        },
        -- Shadow
        {
            filename = "__vanilla-loaders-hd__/graphics/entity/loader/loader-structure-shadow.png",
            priority = "extra-high",
            width = 106,
            height = 96,
            draw_as_shadow = true,
            hr_version = {
                filename = "__vanilla-loaders-hd__/graphics/entity/loader/hr-loader-structure-shadow.png",
                priority = "extra-high",
                width = 212,
                height = 192,
                draw_as_shadow = true,
                scale = 0.5,
            }
        }
    }

    entity.structure.direction_out.sheets = {
        -- Base
        {
            filename = reskins.compatibility.directory.."/graphics/entity/vanilla-loaders-hd/loader/loader-structure-base.png",
            priority = "extra-high",
            width = 106,
            height = 96,
            y = 96,
            hr_version = {
                filename = reskins.compatibility.directory.."/graphics/entity/vanilla-loaders-hd/loader/hr-loader-structure-base.png",
                priority = "extra-high",
                width = 212,
                height = 192,
                y = 192,
                scale = 0.5,
            }
        },
        -- Mask
        {
            filename = reskins.compatibility.directory.."/graphics/entity/vanilla-loaders-hd/loader/loader-structure-mask.png",
            priority = "extra-high",
            width = 106,
            height = 96,
            y = 96,
            tint = inputs.tint,
            hr_version = {
                filename = reskins.compatibility.directory.."/graphics/entity/vanilla-loaders-hd/loader/hr-loader-structure-mask.png",
                priority = "extra-high",
                width = 212,
                height = 192,
                y = 192,
                tint = inputs.tint,
                scale = 0.5,
            }
        },
        -- Highlights
        {
            filename = reskins.compatibility.directory.."/graphics/entity/vanilla-loaders-hd/loader/loader-structure-highlights.png",
            priority = "extra-high",
            width = 106,
            height = 96,
            y = 96,
            blend_mode = "additive",
            hr_version = {
                filename = reskins.compatibility.directory.."/graphics/entity/vanilla-loaders-hd/loader/hr-loader-structure-highlights.png",
                priority = "extra-high",
                width = 212,
                height = 192,
                y = 192,
                blend_mode = "additive",
                scale = 0.5,
            }
        },
        -- Shadow
        {
            filename = "__vanilla-loaders-hd__/graphics/entity/loader/loader-structure-shadow.png",
            priority = "extra-high",
            width = 106,
            height = 96,
            y = 96,
            draw_as_shadow = true,
            hr_version = {
                filename = "__vanilla-loaders-hd__/graphics/entity/loader/hr-loader-structure-shadow.png",
                priority = "extra-high",
                width = 212,
                height = 192,
                y = 192,
                draw_as_shadow = true,
                scale = 0.5,
            }
        }
    }

    -- Apply belt set
    -- entity.belt_animation_set = reskins.lib.transport_belt_animation_set(inputs.tint, map.sprite_variant)

    -- Label to skip to next iteration
    ::continue::
end
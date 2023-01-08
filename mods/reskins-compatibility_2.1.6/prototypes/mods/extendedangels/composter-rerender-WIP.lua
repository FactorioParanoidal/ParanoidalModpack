-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["extendedangels"] then return end
if not (reskins.angels and reskins.angels.triggers.bioprocessing.entities) then return end

-- Set input parameters
local inputs = {
    type = "furnace",
    icon_name = "composter",
    base_entity_name = "assembling-machine-1",
    mod = "angels",
    particles = {["big"] = 1, ["medium"] = 2},
    group = "bioprocessing",
    make_remnants = false,
}

local tier_map = {
    ["composter"] = {tier = 1},
    ["composter-2"] = {tier = 2},
    ["composter-3"] = {tier = 3},
}

local function composter_base()
    return
    {
        filename = reskins.angels.directory.."/graphics/entity/bioprocessing/composter/composter-base.png",
        priority = "extra-high",
        width = 117,
        height = 129,
        shift = util.by_pixel(0, 0),
        hr_version = {
            filename = reskins.angels.directory.."/graphics/entity/bioprocessing/composter/hr-composter-base.png",
            priority = "extra-high",
            width = 234,
            height = 252,
            shift = util.by_pixel(0, 0),
            scale = 0.5,
        }
    }
end

local function composter_mask(tint)
    return
    {
        filename = reskins.angels.directory.."/graphics/entity/bioprocessing/composter/composter-mask.png",
        priority = "extra-high",
        width = 117,
        height = 129,
        shift = util.by_pixel(0, 0),
        tint = tint,
        hr_version = {
            filename = reskins.angels.directory.."/graphics/entity/bioprocessing/composter/hr-composter-mask.png",
            priority = "extra-high",
            width = 234,
            height = 252,
            shift = util.by_pixel(0, 0),
            tint = tint,
            scale = 0.5,
        }
    }
end

local function composter_highlights()
    return
    {
        filename = reskins.angels.directory.."/graphics/entity/bioprocessing/composter/composter-highlights.png",
        priority = "extra-high",
        width = 117,
        height = 129,
        shift = util.by_pixel(0, 0),
        blend_mode = reskins.lib.blend_mode,
        hr_version = {
            filename = reskins.angels.directory.."/graphics/entity/bioprocessing/composter/hr-composter-highlights.png",
            priority = "extra-high",
            width = 234,
            height = 252,
            shift = util.by_pixel(0, 0),
            blend_mode = reskins.lib.blend_mode,
            scale = 0.5,
        }
    }
end

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Handle tier
    local tier = map.tier
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map.prog_tier or map.tier
    end

    -- Determine what tint we're using
    inputs.tint = map.tint or reskins.lib.tint_index[tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Reskin entities
    entity.animation = {
        layers = {
            composter_base(),
            composter_mask(inputs.tint),
            composter_highlights(),
        }
    }

    entity.idle_animation = {
        layers = {
            composter_base(),
            composter_mask(inputs.tint),
            composter_highlights(),
            -- Idle outputs
            {
                filename = reskins.angels.directory.."/graphics/entity/bioprocessing/composter/composter-idle.png",
                priority = "extra-high",
                width = 111,
                height = 41,
                shift = util.by_pixel(0, 0),
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/bioprocessing/composter/hr-composter-idle.png",
                    priority = "extra-high",
                    width = 222,
                    height = 79,
                    shift = util.by_pixel(0, 0),
                    scale = 0.5,
                }
            },
        }
    }

    entity.working_visualisations = {
        -- Animation
        {
            animation = {
                filename = reskins.angels.directory.."/graphics/entity/bioprocessing/composter/composter-animation.png",
                priority = "extra-high",
                width = 111,
                height = 41,
                frame_count = 25,
                line_length = 5,
                shift = util.by_pixel(0, 0),
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/bioprocessing/composter/hr-composter-animation.png",
                    priority = "extra-high",
                    width = 222,
                    height = 79,
                    frame_count = 25,
                    line_length = 5,
                    shift = util.by_pixel(0, 0),
                    scale = 0.5,
                }
            }
        },

        -- Shadow
        {
            always_draw = true,
            animation = {
                filename = reskins.angels.directory.."/graphics/entity/bioprocessing/composter/composter-shadow.png",
                priority = "extra-high",
                width = 145,
                height = 84,
                shift = util.by_pixel(0, 0),
                -- draw_as_shadow = true,
                hr_version = {
                    filename = reskins.angels.directory.."/graphics/entity/bioprocessing/composter/hr-composter-shadow.png",
                    priority = "extra-high",
                    width = 287,
                    height = 165,
                    shift = util.by_pixel(0, 0),
                    -- draw_as_shadow = true,
                    scale = 0.5,
                }
            }
        },
    }

    -- Label to skip to next iteration
    ::continue::
end
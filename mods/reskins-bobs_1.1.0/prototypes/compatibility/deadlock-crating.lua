-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["DeadlockCrating"] then return end
if not mods["boblogistics"] then return end
if reskins.lib.setting("reskins-bobs-do-boblogistics") == false then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    base_entity = "assembling-machine-1",
    mod = "bobs",
    particles = {["big"] = 1, ["medium"] = 2},
    make_icons = false,
    make_remnants = false,
}

local tier_map = {
    ["deadlock-crating-machine-1"] = 1,
    ["deadlock-crating-machine-2"] = 2,
    ["deadlock-crating-machine-3"] = 3,
    ["deadlock-crating-machine-4"] = 4,
    ["deadlock-crating-machine-5"] = 5,
}

local function light_tint(tint)
    local white = 0.95
    return {r = (tint.r + white)/2, g = (tint.g + white)/2, b = (tint.b + white)/2}
end

-- Reskin entities
for name, tier in pairs(tier_map) do

    -- Fetch entity, item
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Determine what tint we're using
    inputs.tint = reskins.bobs.belt_tint_handling(name, tier)

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Retint the mask
    entity.animation.layers[2].tint = inputs.tint
    entity.animation.layers[2].hr_version.tint = inputs.tint
    entity.working_visualisations[1].animation.tint = light_tint(inputs.tint)
    entity.working_visualisations[1].animation.hr_version.tint = light_tint(inputs.tint)
    entity.working_visualisations[1].light.color = light_tint(inputs.tint)

    -- Icon handling
    inputs.icon = {
        {
            icon = "__DeadlockCrating__/graphics/icons/mipmaps/crating-icon-base.png"
        },
        {
            icon = "__DeadlockCrating__/graphics/icons/mipmaps/crating-icon-mask.png",
            tint = inputs.tint,
        }
    }

    inputs.icon_picture = {
        layers = {
            {
                filename = "__DeadlockCrating__/graphics/icons/mipmaps/crating-icon-base.png",
                size = 64,
                scale = 0.25,
                mipmaps = 4,
            },
            {
                filename = "__DeadlockCrating__/graphics/icons/mipmaps/crating-icon-mask.png",
                size = 64,
                scale = 0.25,
                mipmaps = 4,
                tint = inputs.tint
            }
        }
    }

    reskins.lib.append_tier_labels(tier, inputs)
    reskins.lib.assign_icons(name, inputs)

    -- Tech handling
    local technology = data.raw.technology[string.gsub(name, "machine%-", "")]
    if not technology then goto continue end

    technology.icons[2].tint = inputs.tint

    -- Label to skip to next iteration
    ::continue::
end
-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.refining.entities) then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "ore-crusher",
    base_entity = "assembling-machine-1",
    mod = "angels",
    particles = {["big"] = 1, ["medium"] = 2},
    group = "refining",
    make_remnants = false,
}

local tier_map = {
    ["burner-ore-crusher"] = {tier = 0, tint = util.color("262626")},
    ["ore-crusher"] = {tier = 1},
    ["ore-crusher-2"] = {tier = 2},
    ["ore-crusher-3"] = {tier = 3},

    -- Extended Angels
    ["ore-crusher-4"] = {tier = 4},
}

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
            -- Base
            {
                filename = "__angelsrefining__/graphics/entity/ore-crusher/1ore-crusher.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                frame_count = 16,
                line_length = 4,
                shift = {0.45, -0.25},
                animation_speed = 0.5,
            },
            -- Mask
            {
                filename = reskins.angels.directory.."/graphics/entity/refining/ore-crusher/ore-crusher-mask.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                repeat_count = 16,
                shift = {0.45, -0.25},
                animation_speed = 0.5,
                tint = inputs.tint,
            },
            -- Highlights
            {
                filename = reskins.angels.directory.."/graphics/entity/refining/ore-crusher/ore-crusher-highlights.png",
                priority = "extra-high",
                width = 128,
                height = 128,
                repeat_count = 16,
                shift = {0.45, -0.25},
                animation_speed = 0.5,
                blend_mode = reskins.lib.blend_mode,
            },
        }
    }

    -- Label to skip to next iteration
    ::continue::
end
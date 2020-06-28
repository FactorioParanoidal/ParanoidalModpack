-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobplates"] then return end
if reskins.lib.setting("reskins-bobs-do-bobplates") == false then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "water-pump",
    base_entity = "chemical-plant",
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "plates",
    particles = {["big"] = 1, ["medium"] = 2},
    make_remnants = false,
    make_icons = false,
}

local tier_map = {
    ["water-pump"] = 1,
    ["water-pump-2"] = 2,
    ["water-pump-3"] = 3,
    ["water-pump-4"] = 4,
}

-- Reskin entities, create and assign extra details
for name, tier in pairs(tier_map) do
    -- Fetch entity
    entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index["tier-"..tier]
  
    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Reskin entities
    entity.animation = make_4way_animation_from_spritesheet({
        layers = {
            {
                filename = inputs.directory.."/graphics/entity/plates/water-pump/water-pump-base.png",
                width = 96,
                height = 96,
                frame_count = 4,
                line_length = 4,
                frame_sequence = {1, 2, 3, 4, 3, 2},
                shift = util.by_pixel(0, 0),
                hr_version = {
                    filename = inputs.directory.."/graphics/entity/plates/water-pump/hr-water-pump-base.png",
                    width = 192,
                    height = 192,
                    frame_count = 4,
                    line_length = 4,
                    frame_sequence = {1, 2, 3, 4, 3, 2},
                    shift = util.by_pixel(0, 0),
                    scale = 0.5,
                }
            }
        }
    })

    entity.working_visualisations = nil

    -- Label to skip to next iteration
    ::continue::
end
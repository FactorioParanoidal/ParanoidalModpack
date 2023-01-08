-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.assembly.entities) then return end

-- Flag available for Mini-Machines compatibility pass
if reskins.compatibility then reskins.compatibility.triggers.minimachines.electrolysers = true end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "electrolyser",
    base_entity_name = "chemical-plant",
    mod = "bobs",
    group = "assembly",
    particles = {["big"] = 1, ["medium"] = 2},
    make_remnants = false,
}

local tier_map = {
    ["electrolyser"] = {1, 1},
    ["electrolyser-2"] = {2, 2},
    ["electrolyser-3"] = {3, 3},
    ["electrolyser-4"] = {4, 3},
    ["electrolyser-5"] = {5, 5}
}

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Parse map
    local tier = map[1]
    local shadow = map[2]

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index[tier]

    -- Handle unique icons
    inputs.icon_base = "electrolyser-"..tier
    inputs.icon_mask = inputs.icon_base
    inputs.icon_highlights = inputs.icon_base

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Reskin entities
    entity.animation = reskins.lib.make_4way_animation_from_spritesheet({
        layers = {
            -- Base
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/electrolyser/electrolyser-"..tier.."-base.png",
                width = 136,
                height = 130,
                frame_count = 1,
                shift = util.by_pixel(17, 0),
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/electrolyser/hr-electrolyser-"..tier.."-base.png",
                    width = 272,
                    height = 260,
                    frame_count = 1,
                    shift = util.by_pixel(17, 0),
                    scale = 0.5
                }
            },
            -- Mask
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/electrolyser/electrolyser-"..tier.."-mask.png",
                width = 136,
                height = 130,
                frame_count = 1,
                shift = util.by_pixel(17, 0),
                tint = inputs.tint,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/electrolyser/hr-electrolyser-"..tier.."-mask.png",
                    width = 272,
                    height = 260,
                    frame_count = 1,
                    shift = util.by_pixel(17, 0),
                    tint = inputs.tint,
                    scale = 0.5
                }
            },
            -- Highlights
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/electrolyser/electrolyser-"..tier.."-highlights.png",
                width = 136,
                height = 130,
                frame_count = 1,
                shift = util.by_pixel(17, 0),
                blend_mode = reskins.lib.blend_mode, -- "additive",
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/electrolyser/hr-electrolyser-"..tier.."-highlights.png",
                    width = 272,
                    height = 260,
                    frame_count = 1,
                    shift = util.by_pixel(17, 0),
                    blend_mode = reskins.lib.blend_mode, -- "additive",
                    scale = 0.5
                }
            },
            -- Shadow
            {
                filename = reskins.bobs.directory.."/graphics/entity/assembly/electrolyser/electrolyser-"..shadow.."-shadow.png",
                width = 136,
                height = 130,
                frame_count = 1,
                shift = util.by_pixel(17, 0),
                draw_as_shadow = true,
                hr_version = {
                    filename = reskins.bobs.directory.."/graphics/entity/assembly/electrolyser/hr-electrolyser-"..shadow.."-shadow.png",
                    width = 272,
                    height = 260,
                    frame_count = 1,
                    shift = util.by_pixel(17, 0),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        }
    })

    entity.water_reflection = util.copy(data.raw["storage-tank"]["storage-tank"].water_reflection)

    -- Label to skip to next iteration
    ::continue::
end
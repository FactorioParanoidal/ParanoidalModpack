-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.warfare.entities) then return end

-- Set input parameters
local inputs = {
    type = "land-mine",
    mod = "bobs",
    group = "warfare",
    make_icons = false,
    make_explosions = false,
    make_remnants = false,
}

local tier_map = {
    "distractor-mine",
    "poison-mine",
    "slowdown-mine",
}

-- Reskin entities, create and assign extra details
for _, name in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    reskins.lib.setup_standard_entity(name, 0, inputs)

    -- Reskin entities
    entity.picture_safe = {
        filename = reskins.bobs.directory.."/graphics/entity/warfare/"..name.."/hr-"..name..".png",
        priority = "medium",
        width = 64,
        height = 64,
        scale = 0.5
    }

    entity.picture_set = {
        filename = reskins.bobs.directory.."/graphics/entity/warfare/"..name.."/hr-"..name.."-set.png",
        priority = "medium",
        width = 64,
        height = 64,
        scale = 0.5
    }

    -- Label to skip to next iteration
    ::continue::
end
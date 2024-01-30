-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.warfare.entities) then return end

-- Set input parameters
local inputs = {
    type = "artillery-wagon",
    icon_name = "artillery-wagon",
    base_entity_name = "artillery-wagon",
    mod = "bobs",
    group = "warfare",
    particles = { ["big"] = 4 },
}

local tier_map = {
    ["artillery-wagon"] = { 1, 3 },
    ["bob-artillery-wagon-2"] = { 2, 4 },
    ["bob-artillery-wagon-3"] = { 3, 5 },
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

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index[tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- TODO: Reskin remnants?

    -- TODO: Reskin entity?

    -- Label to skip to next iteration
    ::continue::
end

-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobwarfare"] then return end
if reskins.lib.setting("reskins-bobs-do-bobwarfare") == false then return end 

-- Set input parameters
local inputs = {
    type = "car",
    icon_name = "tank",
    base_entity = "tank",
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "warfare",
    particles = {["medium"] = 2},
}

local tier_map = {
    ["tank"] = {1, 2},
    ["bob-tank-2"] = {2, 4},
    ["bob-tank-3"] = {3, 5},
}

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
    -- Fetch entity
    entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Parse map
    if reskins.lib.setting("reskins-lib-tier-mapping") == "name-map" then
        tier = map[1]
    else
        tier = map[2]
    end

    -- Determine what tint we're using
    inputs.tint = reskins.lib.tint_index["tier-"..tier]

        reskins.lib.setup_standard_entity(name, tier, inputs)

    -- TODO: Reskin remnants?

    -- TODO: Reskin entity?

    -- Label to skip to next iteration
    ::continue::
end
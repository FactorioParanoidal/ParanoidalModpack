-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["vanilla-loaders-hd"] then return end

-- We reskin the base entities only if we're doing custom colors
local custom_colors = true
if reskins.lib.setting("reskins-lib-customize-tier-colors") == false then
    custom_colors = false
end

-- Set input parameters
local inputs = {
    type = "loader",
    icon_name = "loader",
    base_entity = "splitter",
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "compatibility",
    subgroup = "vanilla-loaders-hd",
    particles = {["medium"] = 1, ["big"] = 4},
    icon_layers = 2,
    make_remnants = false,
}

-- Handle belt tier labels
if reskins.lib.setting("reskins-bobs-do-belt-entity-tier-labeling") == true then
    inputs.tier_labels = true
end

local tier_map = {
    ["basic-loader"] = {0, 1, true},
    ["loader"] = {1, 1, custom_colors},
    ["fast-loader"] = {2, 2, custom_colors},
    ["express-loader"] = {3, 2, custom_colors},
    ["purple-loader"] = {4, 2, true},
    ["green-loader"] = {5, 2, true},
}

-- Reskin entities
for name, map in pairs(tier_map) do
    -- Fetch entity, item
    entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Parse map
    tier = map[1]
    variant = map[2]
    do_reskin = map[3]

    -- Determine what tint we're using
    inputs.tint = reskins.bobs.belt_tint_handling(name, tier)

    reskins.lib.setup_standard_entity(name, tier, inputs)    
    
    if do_reskin then
        -- Retint the entity mask
        entity.structure.direction_in.sheets[2].tint = inputs.tint
        entity.structure.direction_in.sheets[2].hr_version.tint = inputs.tint
        entity.structure.direction_out.sheets[2].tint = inputs.tint
        entity.structure.direction_out.sheets[2].hr_version.tint = inputs.tint

        -- Apply belt set
        entity.belt_animation_set = reskins.bobs.transport_belt_animation_set(inputs.tint, variant)
    end

    -- Label to skip to next iteration
    ::continue::
end
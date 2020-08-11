-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobplates"] then return end

-- Setup inputs
local inputs = {
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "plates",
    type = "technology",
    flat_icon = true,
}

local technology = {
    -- Nuclear
    ["thorium-processing"] = {subgroup = "nuclear"},
    ["thorium-fuel-reprocessing"] = {subgroup = "nuclear"},
    ["deuterium-fuel-reprocessing"] = {subgroup = "nuclear", image = "deuterium-fuel-reprocessing-pink"},
    ["bobingabout-enrichment-process"] = {subgroup = "nuclear"},
}

-- Handle nuclear update
if reskins.lib.setting("bobmods-plates-nuclearupdate") == true then
    technology["nuclear-fuel-reprocessing"] = {subgroup = "nuclear", defer_to_data_updates = true}

    -- Handle deuterium's default process color
    if reskins.lib.setting("bobmods-plates-bluedeuterium") == true then
        technology["deuterium-fuel-reprocessing"].image = "deuterium-fuel-reprocessing-blue"
    end
else
    technology["thorium-fuel-reprocessing"].image = "thorium-fuel-reprocessing-alternate"

    -- Handle deuterium's alternate process color
    if reskins.lib.setting("bobmods-plates-bluedeuterium") == true then
        technology["deuterium-fuel-reprocessing"].image = "deuterium-fuel-reprocessing-alternate-blue"
    else
        technology["deuterium-fuel-reprocessing"].image = "deuterium-fuel-reprocessing-alternate-pink"
    end
    
end

reskins.lib.create_icons_from_list(technology, inputs)
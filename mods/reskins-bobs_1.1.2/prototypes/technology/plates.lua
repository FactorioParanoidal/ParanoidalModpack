-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobplates"] then return end

-- Setup inputs
local inputs = {
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

    -- Smelting
    ["alloy-processing-1"] = {subgroup = "smelting"},
    ["chemical-processing-1"] = {subgroup = "smelting"},

    ["advanced-material-processing"] = {subgroup = "smelting"}, -- yellow steel
    ["fluid-furnace"] = {subgroup = "smelting"}, -- yellow fluid steel
    ["steel-mixing-furnace"] = {subgroup = "smelting"}, -- blue steel
    ["fluid-mixing-furnace"] = {subgroup = "smelting"}, -- blue fluid steel
    ["steel-chemical-furnace"] = {subgroup = "smelting"}, -- red steel
    ["fluid-chemical-furnace"] = {subgroup = "smelting"}, -- red fluid steel

    ["advanced-material-processing-2"] = {subgroup = "smelting"}, -- yellow electric
    ["advanced-material-processing-3"] = {flat_icon = false, tier = 4, icon_name = "advanced-material-processing"}, -- yellow electric
    ["advanced-material-processing-4"] = {flat_icon = false, tier = 5, icon_name = "advanced-material-processing"}, -- yellow electric
    ["electric-chemical-furnace"] = {subgroup = "smelting"}, -- red electric
    ["electric-mixing-furnace"] = {subgroup = "smelting"}, -- blue electric
    ["multi-purpose-furnace-1"] = {flat_icon = false, tier = 4, icon_name = "multi-purpose-furnace"}, -- purple electric; needs color mask support
    ["multi-purpose-furnace-2"] = {flat_icon = false, tier = 5, icon_name = "multi-purpose-furnace"}, -- green electric; needs color mask support

    -- Barreling pumps
    ["water-bore-1"] = {flat_icon = false, tier = 1, prog_tier = 2, icon_name = "water-bore"},
    ["water-bore-2"] = {flat_icon = false, tier = 2, prog_tier = 3, icon_name = "water-bore"},
    ["water-bore-3"] = {flat_icon = false, tier = 3, prog_tier = 4, icon_name = "water-bore"},
    ["water-bore-4"] = {flat_icon = false, tier = 4, prog_tier = 5, icon_name = "water-bore"},

    -- Air compressors
    ["air-compressor-1"] = {flat_icon = false, tier = 1, prog_tier = 2, icon_name = "air-compressor"},
    ["air-compressor-2"] = {flat_icon = false, tier = 2, prog_tier = 3, icon_name = "air-compressor"},
    ["air-compressor-3"] = {flat_icon = false, tier = 3, prog_tier = 4, icon_name = "air-compressor"},
    ["air-compressor-4"] = {flat_icon = false, tier = 4, prog_tier = 5, icon_name = "air-compressor"},


    -- Plates
    -- ["aluminium-processing"] = {subgroup = "plates"},
    -- ["gold-processing"] = {subgroup = "plates"},
    -- ["zinc-processing"] = {subgroup = "plates"},

    -- Fluid Handling
    ["fluid-handling"] = {flat_icon = false, tier = 1, prog_tier = 2, icon_name = "fluid-handling"},
    ["bob-fluid-handling-2"] = {flat_icon = false, tier = 2, prog_tier = 3, icon_name = "fluid-handling"},
    ["bob-fluid-handling-3"] = {flat_icon = false, tier = 3, prog_tier = 4, icon_name = "fluid-handling"},
    ["bob-fluid-handling-4"] = {flat_icon = false, tier = 4, prog_tier = 5, icon_name = "fluid-handling"},

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
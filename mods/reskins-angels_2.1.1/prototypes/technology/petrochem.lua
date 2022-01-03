-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.petrochem.technologies) then return end

-- Setup standard inputs
local inputs = {
    mod = "angels",
    group = "petrochem",
    type = "technology",
    technology_icon_size = 256,
    technology_icon_mipmaps = 2,
}

local technologies = {
    -- Gas Processing (Gas Refinery)
    ["gas-processing"] = {tier = 1, prog_tier = 2, icon_name = "gas-processing", technology_icon_mipmaps = 4},

    -- Advanced Chemistry
    -- ["angels-advanced-chemistry-1"] = {tier = 1, prog_tier = 2, icon_name = "advanced-chemistry"},
    -- ["angels-advanced-chemistry-2"] = {tier = 2, prog_tier = 3, icon_name = "advanced-chemistry"},
    -- ["angels-advanced-chemistry-3"] = {tier = 3, prog_tier = 4, icon_name = "advanced-chemistry"},
    -- ["angels-advanced-chemistry-4"] = {tier = 4, prog_tier = 5, icon_name = "advanced-chemistry"},

    -- Flare stack
    ["angels-flare-stack"] = {icon_name = "flare-stack", technology_icon_layers = 1, technology_icon_mipmaps = 4},

    -- Advanced Gas Processing
    ["angels-advanced-gas-processing"] = {tier = 1, prog_tier = 3, icon_name = "advanced-gas-processing"},
    ["angels-advanced-gas-processing-2"] = {tier = 4, prog_tier = 6, icon_name = "advanced-gas-processing"}, -- Added by Extended Angels
}

reskins.lib.create_icons_from_list(technologies, inputs)
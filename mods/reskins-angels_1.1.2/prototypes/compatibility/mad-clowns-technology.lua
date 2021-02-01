-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not reskins.angels.triggers.mad_clowns.is_active then return end

-- Setup standard inputs
local inputs = {
    mod = "angels",
    group = "compatibility/mad-clowns",
    type = "technology",
    technology_icon_size = 256,
    technology_icon_mipmaps = 4,
    flat_icon = true,
}

local technologies = {
    ["advanced-depleted-uranium-smelting-1"] = {subgroup = "casting", image = "casting-depleted-uranium-technology-icon"},
    ["advanced-depleted-uranium-smelting-2"] = {subgroup = "casting", image = "casting-depleted-uranium-technology-icon"},
    ["advanced-magnesium-smelting"] = {subgroup = "casting", image = "casting-magnesium-technology-icon"},
    ["advanced-osmium-smelting"] = {subgroup = "casting", image = "casting-osmium-technology-icon"},
}

reskins.lib.create_icons_from_list(technologies, inputs)
-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.smelting.technologies) then return end

-- Setup standard inputs
local inputs = {
    mod = "angels",
    group = "smelting",
    type = "technology",
    technology_icon_size = 256,
    technology_icon_mipmaps = 4,
    flat_icon = true,
}

local technologies = {}

reskins.lib.create_icons_from_list(technologies, inputs)
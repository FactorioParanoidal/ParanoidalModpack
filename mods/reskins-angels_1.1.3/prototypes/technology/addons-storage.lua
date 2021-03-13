-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.storage.technologies) then return end

-- Setup standard inputs
local inputs = {
    mod = "angels",
    group = "addons-storage",
    type = "technology",
    technology_icon_size = 256,
    technology_icon_mipmaps = 2,
    flat_icon = true,
}

local technologies = {}

-- Reskin warehouse technologies
technologies["angels-logistic-warehouses"] = {subgroup = "warehouses"}
technologies["angels-warehouses"] = {subgroup = "warehouses"}

-- Reskin silo technologies
-- technologies["logistic-silos"] = {subgroup = "silos"}
-- technologies["ore-silos"] = {subgroup = "silos"}

reskins.lib.create_icons_from_list(technologies, inputs)
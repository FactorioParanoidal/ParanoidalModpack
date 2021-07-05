-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["extendedangels"] then return end
if not (reskins.angels and reskins.angels.triggers.storage.technologies) then return end

-- Setup standard inputs
local inputs = {
    mod = "compatibility",
    group = "extendedangels",
    type = "technology",
    technology_icon_size = 256,
    technology_icon_mipmaps = 2,
    flat_icon = true,
}

local technologies = {}

-- Reskin warehouse technologies
technologies["logistic-warehouses-2"] = {mod = "angels", group = "addons-storage", subgroup = "warehouses", image = "angels-logistic-warehouses"}
technologies["logistic-warehouses-3"] = {mod = "angels", group = "addons-storage", subgroup = "warehouses", image = "angels-logistic-warehouses"}
technologies["logistic-warehouses-4"] = {mod = "angels", group = "addons-storage", subgroup = "warehouses", image = "angels-logistic-warehouses"}
technologies["warehouses-2"] = {mod = "angels", group = "addons-storage", subgroup = "warehouses", image = "angels-warehouses"}
technologies["warehouses-3"] = {mod = "angels", group = "addons-storage", subgroup = "warehouses", image = "angels-warehouses"}
technologies["warehouses-4"] = {mod = "angels", group = "addons-storage", subgroup = "warehouses", image = "angels-warehouses"}

-- Reskin silo technologies
-- technologies["logistic-silos"] = {subgroup = "silos"}
-- technologies["ore-silos"] = {subgroup = "silos"}

reskins.lib.create_icons_from_list(technologies, inputs)
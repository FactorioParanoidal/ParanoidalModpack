-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.logistics.technologies) then return end

-- Setup standard inputs
local inputs = {
    mod = "bobs",
    group = "logistics",
    type = "technology",
}

local technologies = {
    -- Repair packs
    ["bob-repair-pack-2"] = {tier = 2, icon_name = "repair-pack"},
    ["bob-repair-pack-3"] = {tier = 3, icon_name = "repair-pack"},
    ["bob-repair-pack-4"] = {tier = 4, icon_name = "repair-pack"},
    ["bob-repair-pack-5"] = {tier = 5, icon_name = "repair-pack"},
}

reskins.lib.create_icons_from_list(technologies, inputs)
-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["boblogistics"] then return end

-- Setup standard inputs
local inputs = {
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "logistics",
    type = "technology",
}

local technologies = {
    ["logistics-0"] = {tier = 0, icon_name = "logistics"},
    ["logistics"] = {tier = 1, icon_name = "logistics"},
    ["logistics-2"] = {tier = 2, icon_name = "logistics"},
    ["logistics-3"] = {tier = 3, icon_name = "logistics"},
    ["logistics-4"] = {tier = 4, icon_name = "logistics"},
    ["logistics-5"] = {tier = 5, icon_name = "logistics"},
}

reskins.lib.create_icons_from_list(technologies, inputs)
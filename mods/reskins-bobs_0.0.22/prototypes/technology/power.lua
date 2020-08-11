-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobpower"] then return end

-- Setup standard inputs
local inputs = {
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "power",
    type = "technology",
}

-- Solar Energy
local technologies = {
    ["solar-energy"] = {tier = 1, prog_tier = 2, icon_name = "solar-energy"},
    ["bob-solar-energy-2"] = {tier = 1, prog_tier = 2, icon_name = "solar-energy"},
    ["bob-solar-energy-3"] = {tier = 2, prog_tier = 3, icon_name = "solar-energy"},
    ["bob-solar-energy-4"] = {tier = 3, prog_tier = 4, icon_name = "solar-energy"},
}

reskins.lib.create_icons_from_list(technologies, inputs)
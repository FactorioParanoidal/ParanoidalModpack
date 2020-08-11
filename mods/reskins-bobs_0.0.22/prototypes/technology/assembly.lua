-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobassembly"] then return end

-- Setup standard inputs
local inputs = {
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "assembly",
    type = "technology",
}

-- Automation (Assembling Machines)
local technologies = {    
    ["automation"] = {tier = 0, icon_name = "automation"},
    ["automation-2"] = {tier = 1, icon_name = "automation"},
    ["automation-3"] = {tier = 2, icon_name = "automation"},
    ["automation-4"] = {tier = 3, icon_name = "automation"},
    ["automation-5"] = {tier = 4, icon_name = "automation"},
    ["automation-6"] = {tier = 5, icon_name = "automation"},
}

reskins.lib.create_icons_from_list(technologies, inputs)
-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobtech"] then return end

-- Setup standard inputs
local inputs = {
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "technology",
    type = "technology",
}

-- Automation (Assembling Machines)
local technologies = {
    -- Automation
    ["basic-automation"] = {group = "assembly", icon_name = "automation", tint = util.color("262626")},
    ["steam-automation"] = {group = "assembly", icon_name = "automation", tint = util.color("d9d9d9")},

    -- Science Packs
    ["advanced-logistic-science-pack"] = {icon_name = "science-pack", tint = util.color("de00a3")}
}

-- Color overhaul for science packs
if reskins.lib.setting("bobmods-tech-colorupdate") == true and reskins.lib.setting("reskins-lib-customize-tier-colors") == true then
    technologies["automation-science-pack"] = {tier = 1, icon_name = "science-pack"}
    technologies["logistic-science-pack"] = {tier = 2, icon_name = "science-pack"}
    technologies["chemical-science-pack"] = {tier = 3, icon_name = "science-pack"}
    technologies["production-science-pack"] = {tier = 4, icon_name = "science-pack"}
    technologies["utility-science-pack"] = {tier = 5, icon_name = "science-pack"}
end

reskins.lib.create_icons_from_list(technologies, inputs)
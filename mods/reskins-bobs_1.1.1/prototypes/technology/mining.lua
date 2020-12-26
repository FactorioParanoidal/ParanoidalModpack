-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobmining"] then return end

-- Setup standard inputs
local inputs = {
    mod = "bobs",
    group = "mining",
    type = "technology",
}

-- Automation (Assembling Machines)
local technologies = {
    -- Standard Drills
    ["bob-drills-1"] = {tier = 2, icon_name = "mining-drill"},
    ["bob-drills-2"] = {tier = 3, icon_name = "mining-drill"},
    ["bob-drills-3"] = {tier = 4, icon_name = "mining-drill"},
    ["bob-drills-4"] = {tier = 5, icon_name = "mining-drill"},

    -- Area Drills
    ["bob-area-drills-1"] = {tier = 1, prog_tier = 2, icon_name = "mining-drill", icon_base = "area-mining-drill"},
    ["bob-area-drills-2"] = {tier = 2, prog_tier = 3, icon_name = "mining-drill", icon_base = "area-mining-drill"},
    ["bob-area-drills-3"] = {tier = 3, prog_tier = 4, icon_name = "mining-drill", icon_base = "area-mining-drill"},
    ["bob-area-drills-4"] = {tier = 4, prog_tier = 5, icon_name = "mining-drill", icon_base = "area-mining-drill"},

}

if mods["aai-industry"] then
    technologies["electric-mining"] = {tier = 1, icon_name = "mining-drill"}
end

reskins.lib.create_icons_from_list(technologies, inputs)
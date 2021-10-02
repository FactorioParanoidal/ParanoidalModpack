-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.modules.technologies) then return end

-- Setup inputs
local inputs = {
    mod = "bobs",
    group = "modules",
    type = "technology",
    technology_icon_size = 256,
    technology_icon_mipmaps = 4,
    flat_icon = true,
}

local technologies = {
    -- Module unlocks
    ["modules"] = {}, -- Basics (Blue/Red/Yellow)
    ["module-merging"] = {}, -- Pures/Raws (Cyan/Pink/Green)

    -- Beacons
    -- ["effect-transmission"] = {tier = 1, prog_tier = 3}, -- t3 beacon
    -- ["effect-transmission-2"] = {tier = 2, prog_tier = 4}, -- t4 beacon
    -- ["effect-transmission-3"] = {tier = 3, prog_tier = 5}, -- t5 beacon
}

if mods["CircuitProcessing"] then
    technologies["modules"] = nil
    technologies["module-merging"] = nil
end

reskins.lib.create_icons_from_list(technologies, inputs)
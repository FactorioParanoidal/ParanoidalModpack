-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.classes.technologies) then return end

-- Setup standard inputs
local inputs = {
    mod = "bobs",
    group = "classes",
    type = "technology",
}

local technologies = {
    -- ["builder-body"] = {}, -- builder (hamme,r wrench, screwdriver icon)
    -- ["builder-body-2"] = {},
    -- ["fighter-body"] = {}, -- guns
    -- ["fighter-body-2"] = {},
    -- ["miner-body"] = {}, -- pickaxe
    -- ["miner-body-2"] = {},
    -- ["bodies"] = {}, -- generic body
    -- ["bodies-2"] = {}, -- generic 2x, parts
    -- ["engineer-body"] = {},
    -- ["prospector-body"] = {},
}

reskins.lib.create_icons_from_list(technologies, inputs)
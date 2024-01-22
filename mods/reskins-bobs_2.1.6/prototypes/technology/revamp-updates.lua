-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.revamp.technologies) then return end

-- Setup standard inputs
local inputs = {
    mod = "bobs",
    group = "revamp",
    type = "technology",
}

local technologies = {
    -- Chemical plant
    ["chemical-plant"] = {group = "assembly", tier = 1, prog_tier = 2, icon_name = "chemical-plant"},
}

reskins.lib.create_icons_from_list(technologies, inputs)
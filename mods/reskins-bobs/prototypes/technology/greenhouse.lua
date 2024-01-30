-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.greenhouse.technologies) then return end

-- Setup inputs
local inputs = {
    mod = "bobs",
    group = "greenhouse",
    type = "technology",
    flat_icon = true,
    technology_icon_size = 256,
    technology_icon_mipmaps = 4,
}

local technologies = {
    ["bob-fertiliser"] = {},
    ["bob-greenhouse"] = {}, -- greenhouse, recipies
}

reskins.lib.create_icons_from_list(technologies, inputs)
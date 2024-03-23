-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.greenhouse.items) then return end

-- Setup inputs
local inputs = {
    mod = "bobs",
    group = "greenhouse",
    make_icon_pictures = false,
    flat_icon = true,
}

local intermediates = {
    ["seedling"] = {subgroup = "items"},
    ["fertiliser"] = {subgroup = "items"},
    ["wood-pellets"] = {subgroup = "items"},
    ["bob-basic-greenhouse-cycle"] = {type = "recipe", subgroup = "recipes"},
    ["bob-advanced-greenhouse-cycle"] = {type = "recipe", subgroup = "recipes"},
}

reskins.lib.create_icons_from_list(intermediates, inputs)
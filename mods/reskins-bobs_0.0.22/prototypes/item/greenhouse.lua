-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobgreenhouse"] then return end

-- Setup inputs
local inputs = {
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "greenhouse",
    make_icon_pictures = false,
    flat_icon = true,
}

local intermediaries = {
    ["seedling"] = {subgroup = "items"},
    ["fertiliser"] = {subgroup = "items"},
    ["wood-pellets"] = {subgroup = "items"},
    ["bob-basic-greenhouse-cycle"] = {type = "recipe", subgroup = "recipes"},
    ["bob-advanced-greenhouse-cycle"] = {type = "recipe", subgroup = "recipes"},
}

reskins.lib.create_icons_from_list(intermediaries, inputs)
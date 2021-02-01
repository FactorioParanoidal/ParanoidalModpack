-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Setup inputs and constants
local inputs = {
    mod = "angels",
    group = "refining",
    make_icon_pictures = false,
    flat_icon = true,
}

local shift = reskins.angels.constants.recipe_corner_shift
local scale = reskins.angels.constants.recipe_corner_scale

-- Check to see if reskinning needs to be done.
if not mods["angelssmelting"] then return end

local intermediaries = {
    ----------------------------------------------------------------------------------------------------
    -- Intermediaries
    ----------------------------------------------------------------------------------------------------
    -- Miscellaneous
    ["solid-limestone"] = {subgroup = "intermediaries"},
    ["slag"] = {subgroup = "intermediaries"},
}

reskins.lib.create_icons_from_list(intermediaries, inputs)

-- local composite_recipes = {}

-- for name, sources in pairs(composite_recipes) do
--     reskins.lib.composite_existing_icons(name, "recipe", sources)
-- end
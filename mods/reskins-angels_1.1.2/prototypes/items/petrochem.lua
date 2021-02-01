-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["angelspetrochem"] then return end

-- Setup inputs
local inputs = {
    mod = "angels",
    group = "petrochem",
    make_icon_pictures = false,
    flat_icon = true,
}

local intermediaries = {
    ----------------------------------------------------------------------------------------------------
    -- Intermediaries
    ----------------------------------------------------------------------------------------------------
    -- Miscellaneous
    ["pellet-coke"] = {subgroup = "intermediaries"},

    ----------------------------------------------------------------------------------------------------
    -- Recipes
    ----------------------------------------------------------------------------------------------------
    -- Miscellaneous
    ["bob-rubber"] = {type = "recipe", mod = "lib", group = "shared", subgroup = "items", image = "rubber", icon_extras = reskins.angels.num_tier(1, inputs.group)}, -- "1"
    ["solid-rubber"] = {type = "recipe", mod = "lib", group = "shared", subgroup = "items", image = "rubber", icon_extras = reskins.angels.num_tier(2, inputs.group)}, -- "2"
}

if mods["reskins-bobs"] then
    intermediaries["bob-resin-wood"] = {type = "recipe", mod = "bobs", group = "plates", subgroup = "items", image = "resin", icon_extras = reskins.angels.num_tier(1, inputs.group)}
    intermediaries["solid-resin"] = {type = "recipe", mod = "bobs", group = "plates", subgroup = "items", image = "resin"}
end

if not data.raw.recipe["bob-rubber"] then
    intermediaries["solid-rubber"].icon_extras = nil
    intermediaries["solid-rubber"].type = nil
end

reskins.lib.create_icons_from_list(intermediaries, inputs)

local shift = reskins.angels.constants.recipe_corner_shift
local scale = reskins.angels.constants.recipe_corner_scale

local composite_recipes = {
    ["bio-resin-wood-reprocessing"] = {["resin"] = {}, ["wood"] = {scale = 0.5, shift = {-8, -8}}},
}

for name, sources in pairs(composite_recipes) do
    reskins.lib.composite_existing_icons(name, "recipe", sources)
end
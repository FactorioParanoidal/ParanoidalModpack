-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.petrochem.items) then return end

-- Setup inputs
local inputs = {
    mod = "angels",
    group = "petrochem",
    make_icon_pictures = false,
    flat_icon = true,
}

local intermediates = {
    ----------------------------------------------------------------------------------------------------
    -- Intermediates
    ----------------------------------------------------------------------------------------------------
    -- Miscellaneous
    ["pellet-coke"] = {subgroup = "intermediates"},

    ----------------------------------------------------------------------------------------------------
    -- Recipes
    ----------------------------------------------------------------------------------------------------
    -- Miscellaneous
    ["bob-rubber"] = {type = "recipe", mod = "lib", group = "shared", subgroup = "items", image = "rubber", icon_extras = reskins.angels.num_tier(1, inputs.group)}, -- "1"
    ["solid-rubber"] = {type = "recipe", mod = "lib", group = "shared", subgroup = "items", image = "rubber", icon_extras = reskins.angels.num_tier(2, inputs.group)}, -- "2"
}

if mods["reskins-bobs"] then
    intermediates["bob-resin-wood"] = {type = "recipe", mod = "bobs", group = "plates", subgroup = "items", image = "resin", icon_extras = reskins.angels.num_tier(1, inputs.group)}
    intermediates["solid-resin"] = {type = "recipe", mod = "bobs", group = "plates", subgroup = "items", image = "resin"}
end

if not data.raw.recipe["bob-rubber"] then
    intermediates["solid-rubber"].icon_extras = nil
    intermediates["solid-rubber"].type = nil
end

reskins.lib.create_icons_from_list(intermediates, inputs)

local shift = reskins.angels.constants.recipe_corner_shift
local scale = reskins.angels.constants.recipe_corner_scale

local composite_recipes = {
    ["bio-resin-wood-reprocessing"] = {["resin"] = {}, ["wood"] = {scale = 0.5, shift = {-8, -8}}},
}

for name, sources in pairs(composite_recipes) do
    reskins.lib.composite_existing_icons(name, "recipe", sources)
end
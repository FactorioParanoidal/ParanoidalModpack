-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["angelspetrochem"] then return end

local inputs = {
    directory = reskins.angels.directory,
    mod = "angels",
    icon = "__base__/graphics/icons/sulfur.png",
}

reskins.lib.parse_inputs(inputs)
reskins.lib.assign_icons("sulfur", inputs)

-- Fix recipe icons, but in the lazy hard-coded way we'll come back to later.
-- TO-DO: Make this a more general, robust process rather than a one-off
if data.raw.recipe["solid-sulfur"] and data.raw.recipe["solid-sulfur"].icons and data.raw.recipe["solid-sulfur"].icons[5] then
    data.raw.recipe["solid-sulfur"].icons[5] = {
        icon = inputs.icon,
        icon_size = 64,
        icon_mipmaps = 4,
        scale = 0.16,
        shift = {-11.5, 12},
    }
end

if data.raw.recipe["yellow-waste-water-purification"] and data.raw.recipe["yellow-waste-water-purification"].icons and data.raw.recipe["yellow-waste-water-purification"].icons[12] then
    data.raw.recipe["yellow-waste-water-purification"].icons[12] = {
        icon = inputs.icon,
        icon_size = 64,
        icon_mipmaps = 4,
        scale = 0.16,
        shift = {0, 12},
    }
end
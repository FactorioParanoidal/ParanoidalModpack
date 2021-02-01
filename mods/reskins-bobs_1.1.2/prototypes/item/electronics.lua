-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobelectronics"] then return end

-- Setup inputs
local inputs = {
    mod = "bobs",
    group = "electronics",
    make_icon_pictures = false,
    flat_icon = true,
}

local intermediaries = {
    -- Wires
    ["gilded-copper-cable"] = {mod = "lib", group = "shared", subgroup = "items"},
    ["tinned-copper-cable"] = {subgroup = "wires",},
    ["insulated-cable"] = {subgroup = "wires"},

    -- Intermediaries
    ["solder"] = {mod = "lib", group = "shared", subgroup = "items"},
}

-- Items and recipes shared with other mods within Bob's suite
if not mods["bobplates"] then
    -- Intermediaries
    intermediaries["solder-alloy"] = {mod = "lib", group = "shared", subgroup = "items"}
    intermediaries["rubber"] = {mod = "lib", group = "shared", subgroup = "items"}
    intermediaries["resin"] = {group = "plates", subgroup = "items"}
    intermediaries["ferric-chloride-solution"] = {type = "fluid", group = "plates", subgroup = "fluids"}
    intermediaries["silicon-wafer"] = {mod = "lib", group = "shared", subgroup = "items"}

    -- Recipes
    intermediaries["coal-cracking"] = {type = "recipe", group = "plates", subgroup = "recipes"}
    intermediaries["synthetic-wood"] = {type = "recipe", group = "plates", subgroup = "recipes"}
    intermediaries["bob-resin-wood"] = {type = "recipe", group = "plates", subgroup = "recipes"}
    intermediaries["bob-resin-oil"] = {type = "recipe", group = "plates", subgroup = "recipes"}
end

reskins.lib.create_icons_from_list(intermediaries, inputs)
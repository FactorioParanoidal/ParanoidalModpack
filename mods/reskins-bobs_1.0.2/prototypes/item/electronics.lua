-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobelectronics"] then return end

-- Setup inputs
local inputs = {
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "electronics",
    make_icon_pictures = false,
    flat_icon = true,
}

local intermediaries = {
    -- Wires
    ["gilded-copper-cable"] = {subgroup = "wires", defer_to_data_final_fixes = true}, -- Angels
    ["tinned-copper-cable"] = {subgroup = "wires", defer_to_data_final_fixes = true}, -- Angels
    ["insulated-cable"] = {subgroup = "wires"},
}

-- Items and recipes shared with other mods within Bob's suite
if not mods["bobplates"] then
    -- Intermediaries
    intermediaries["solder-alloy"] = {group = "plates", subgroup = "plates", defer_to_data_final_fixes = true} -- Angels
    intermediaries["rubber"] = {group = "plates", subgroup = "items"}
    intermediaries["resin"] = {group = "plates", subgroup = "items"}
    intermediaries["ferric-chloride-solution"] = {type = "fluid", group = "plates", subgroup = "fluids"}

    -- Recipes
    intermediaries["coal-cracking"] = {type = "recipe", group = "plates", subgroup = "recipes"}
    intermediaries["synthetic-wood"] = {type = "recipe", group = "plates", subgroup = "recipes"}
    intermediaries["bob-resin-wood"] = {type = "recipe", group = "plates", subgroup = "recipes"}
    intermediaries["bob-resin-oil"] = {type = "recipe", group = "plates", subgroup = "recipes"}
end

reskins.lib.create_icons_from_list(intermediaries, inputs)
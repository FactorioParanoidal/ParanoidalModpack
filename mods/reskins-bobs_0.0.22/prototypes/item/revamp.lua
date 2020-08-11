-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobrevamp"] then return end

-- Setup inputs
local inputs = {
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "revamp",
    make_icon_pictures = false,
    flat_icon = true,
}

local intermediaries = {
    ["brine"] = {type = "fluid", subgroup = "fluids"},
    ["ammoniated-brine"] = {type = "fluid", subgroup = "fluids"},
}

-- Items and recipes shared with other mods within Bob's suite
if not mods["bobplates"] then
    intermediaries["solid-fuel-from-sour-gas"] = {type = "recipe", group = "plates", subgroup = "recipes"}
end

reskins.lib.create_icons_from_list(intermediaries, inputs)